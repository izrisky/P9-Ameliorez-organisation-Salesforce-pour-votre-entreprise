@isTest
private class UpdateAllAccountsBatchTest {
    @TestSetup
static void setup() {
    DataFactory.createTestData();
}
    @isTest 
    static void testBatchUpdate() {         
    // Récupérer le compte de test créé par DataFactory
    Account accBefore = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
    Test.startTest();
        // Exécuter le batch
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch, 200);
    Test.stopTest();
    
    // Requêter le compte après batch pour vérifier la mise à jour du CA
    Account accAfter = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :accBefore.Id];
    System.assertEquals(1000, accAfter.Chiffre_d_affaire__c, 'Le CA doit être mis à jour à 1000 après exécution du batch.');
    }
}