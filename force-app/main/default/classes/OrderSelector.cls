public with sharing class OrderSelector {
     /** * Retourne le résultat agrégé du total des montants des commandes activées pour un compte donné. */ 
     public static AggregateResult getSumAggregateByAccount(Id accountId)
      {
         return [ SELECT SUM(TotalAmount) total FROM Order WHERE AccountId = :accountId AND Status = 'Activated' ]; 
    } 
}