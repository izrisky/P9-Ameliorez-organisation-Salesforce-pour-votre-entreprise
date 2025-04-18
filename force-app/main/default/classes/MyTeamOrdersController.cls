public with sharing class MyTeamOrdersController {
    //Test pipeline
    //Test pipeline
    //Test pipeline
    @AuraEnabled(cacheable=true)    
    public static Decimal getSumOrdersByAccount(Id accountId) {
        AggregateResult groupedResults = [SELECT SUM(TotalAmount) total 
            FROM Order 
            WHERE AccountId = :accountId AND Status = 'Activated'];
        return (Decimal)groupedResults.get('total');
    }
}
