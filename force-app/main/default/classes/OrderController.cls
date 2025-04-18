public with sharing class OrderController {
    @AuraEnabled(cacheable=true)    
    public static Decimal getSumOrdersByAccount(Id accountId) {
        AggregateResult groupedResults = [SELECT SUM(TotalAmount) total 
            FROM Order 
            WHERE AccountId = :accountId AND Status = 'Activated'];
        return (Decimal)groupedResults.get('total');
    }

        // Méthode à appeler dans le trigger before update
    public static void updateOrderNetAmounts(List<Order> orders) {
        for (Order o : orders) {
            Decimal total = (o.TotalAmount == null) ? 0 : o.TotalAmount;
            Decimal shipmentCost = (o.ShipmentCost__c == null) ? 0 : o.ShipmentCost__c;
            o.NetAmount__c = total - shipmentCost;
        }
    }

    // Méthode à appeler dans le trigger after update
    public static void updateAccountsAfterOrders(List<Order> orders) {
        // Collecte les AccountId concernés
        Set<Id> accountIds = new Set<Id>();
        for (Order o : orders) {
            if (o.AccountId != null) {
                accountIds.add(o.AccountId);
            }
        }
        
        // Récupère les comptes en une seule requête
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds]
        );
        
        // Cumule le TotalAmount pour chaque compte
        for (Order o : orders) {
            if (o.AccountId != null && accountMap.containsKey(o.AccountId)) {
                Account acc = accountMap.get(o.AccountId);
                Decimal currentCA = (acc.Chiffre_d_affaire__c == null) ? 0 : acc.Chiffre_d_affaire__c;
                acc.Chiffre_d_affaire__c = currentCA + o.TotalAmount;
            }
        }
        
        // Mise à jour unique des comptes modifiés
        update accountMap.values();
    }

}
