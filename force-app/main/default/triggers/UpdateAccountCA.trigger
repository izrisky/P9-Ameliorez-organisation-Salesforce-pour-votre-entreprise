trigger UpdateAccountCA on Order (after update) {

// Collecte tous les AccountId concernés
Set<Id> accountIds = new Set<Id>();
for (Order o : Trigger.new) {
    if (o.AccountId != null) {
        accountIds.add(o.AccountId);
    }
}

// Récupère en une seule requête l'ensemble des comptes à mettre à jour
Map<Id, Account> accountMap = new Map<Id, Account>(
    [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds]
);

// Pour chaque commande, cumule le montant dans le champ Chiffre_d_affaire__c de son compte
for (Order o : Trigger.new) {
    if (o.AccountId != null && accountMap.containsKey(o.AccountId)) {
        Account acc = accountMap.get(o.AccountId);
        // Assurez-vous que la valeur initiale n'est pas null
        Decimal currentCA = (acc.Chiffre_d_affaire__c == null) ? 0 : acc.Chiffre_d_affaire__c;
        acc.Chiffre_d_affaire__c = currentCA + o.TotalAmount;
    }
}

// Mise à jour unique de tous les comptes modifiés
update accountMap.values();
}