global class UpdateAllAccounts implements Database.Batchable<sObject>{

    //Test pipeline
    //Test pipeline
    global Database.QueryLocator start(Database.BatchableContext info){ 
        //Requeter seulement les comptes qui ont au moins une commande avec le Status 'Activated'
        return Database.getQueryLocator('SELECT Id FROM Account');
 
    }     
    global void execute(Database.BatchableContext info, List<Account> scope){
        Set<Id> setAccountIds = (new Map<Id,SObject>(scope)).keySet();
        // Appeler une class qui va faire la logique du code;
    }         
    global void finish(Database.BatchableContext info){     
        
    } 
 }