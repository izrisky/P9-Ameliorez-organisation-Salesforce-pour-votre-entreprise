public with sharing class OrderController {
    //Test pipeline 
    //Test pipeline 
    @AuraEnabled(cacheable=true)    
    // Méthode utiliser dans la le composant LWC Orders
    public static Decimal getSumOrdersByAccount(Id accountId) {
        AggregateResult groupedResults = OrderSelector.getSumAggregateByAccount(accountId);
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
    public static void updateAccountsAfterOrders(List<Order> orders, List<Order> oldOrders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order o : orders) {
            if (o.AccountId != null) {
                accountIds.add(o.AccountId);
            }
        }
        
        Map<Id, Account> accountMap = AccountSelector.getAccountsByIds(accountIds);
        Map<Id, Order> oldOrderMap = new Map<Id, Order>(oldOrders); // Crée une map des anciennes commandes
        
        for (Order newOrder : orders) {
            Order oldOrder = oldOrderMap.get(newOrder.Id);
            Id accId = newOrder.AccountId;
            
            if (accId == null || !accountMap.containsKey(accId)) continue;
            
            Account acc = accountMap.get(accId);
            Decimal currentCA = acc.Chiffre_d_affaire__c != null ? acc.Chiffre_d_affaire__c : 0;
            
            // Soustraire uniquement si l'ancien statut était 'Activated'
            if (oldOrder != null && oldOrder.Status == 'Activated') {
                currentCA -= oldOrder.TotalAmount;
            }            
            // Ajouter uniquement si le nouveau statut est 'Activated'
            if (newOrder.Status == 'Activated') {
                currentCA += newOrder.TotalAmount;
            }
            
            acc.Chiffre_d_affaire__c = currentCA;
        }
        
        update accountMap.values();
    }

}
