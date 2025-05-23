@isTest
private class UpdateAllAccountsBatchTest {
    @TestSetup
static void setup() {
    DataFactory.createTestData(20);
}
    @isTest 
    static void testBatchUpdate() {         
     // Récupérer plusieurs comptes créés via DataFactory
     List<Account> accountsBefore = [SELECT Id, Name, Chiffre_d_affaire__c FROM Account WHERE Name LIKE 'Test Account %' LIMIT 3];
    System.assert(accountsBefore.size() > 0, 'Au moins un compte doit être créé.');

    Long startTime = System.currentTimeMillis();
        
    Test.startTest();
        // Exécuter le batch
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch);
    Test.stopTest();
    
        // Capture le temps à la fin
        Long endTime = System.currentTimeMillis();
        Long duration = endTime - startTime;
        
        System.debug('Durée d’exécution du batch (ms) : ' + duration);

        // Mesurer l'impact
        System.debug('=== UpdateAllAccountsBatchTest ===');
        System.debug('CPU: ' + Limits.getCpuTime() + 'ms'); // ✅ Généralement < 1000ms
        System.debug('SOQL: ' + Limits.getQueries());        // ✅ 2 requêtes (Accounts + Orders)
        System.debug('DML: ' + Limits.getDmlStatements());   // ✅ 3 updates (1 par compte)
        // Vérifier pour chaque compte que le chiffre d'affaires a bien été mis à jour.
    // Chaque compte possède 100 commandes avec un OrderItem fixé à 10, donc CA attendu = 100 x 10 = 1000.
    for (Account accBefore : accountsBefore) {
        Account accAfter = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :accBefore.Id];
        System.assertEquals(1000, accAfter.Chiffre_d_affaire__c,'Le CA pour ' + accBefore.Name + ' devrait être 1000 après exécution du batch.');
    }    
    }
}