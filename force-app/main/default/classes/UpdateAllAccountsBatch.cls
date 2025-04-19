global class UpdateAllAccountsBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Ne récupérer que les comptes ayant des commandes actives via une sous-requête
        return Database.getQueryLocator([
            SELECT Id 
            FROM Account 
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Activated')
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        // Faire une agrégation pour récupérer la somme des commandes actives par compte
        Map<Id, Decimal> accountIdToTotal = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT AccountId, SUM(TotalAmount) total
            FROM Order 
            WHERE AccountId IN :scope AND Status = 'Activated'
            GROUP BY AccountId
        ]) {
            accountIdToTotal.put((Id)ar.get('AccountId'), (Decimal)ar.get('total'));
        }
        
        // Mettre à jour le chiffre d’affaires des comptes avec la somme calculée
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : scope) {
            if (accountIdToTotal.containsKey(acc.Id)) {
                acc.Chiffre_d_affaire__c = accountIdToTotal.get(acc.Id);
                accountsToUpdate.add(acc);
            }
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optionnel : ajouter une notification ou un log indiquant la fin du batch.
    }
    }