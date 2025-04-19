public with sharing class AccountSelector {
 /** * Récupère une map d'Accounts à partir d'un ensemble d'Id. */
 public static Map<Id, Account> getAccountsByIds(Set<Id> accountIds)
  {
     return new Map<Id, Account>( [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds] );
     } 
}