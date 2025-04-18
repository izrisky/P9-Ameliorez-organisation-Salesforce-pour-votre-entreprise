@isTest
private class UpdateAllAccountsBatchTest {
    @TestSetup
static void setup() {
    DataFactory.createTestData();
}
    @isTest 
    static void testBatchUpdate() {         
     // Récupérer plusieurs comptes créés via DataFactory
     List<Account> accountsBefore = [SELECT Id, Name, Chiffre_d_affaire__c FROM Account WHERE Name LIKE 'Test Account %'];
    System.assert(accountsBefore.size() > 0, 'Au moins un compte doit être créé.');

        
    Test.startTest();
        // Exécuter le batch
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch, 200);
    Test.stopTest();
    
        // Vérifier pour chaque compte que le chiffre d'affaires a bien été mis à jour.
    // Chaque compte possède 100 commandes avec un OrderItem fixé à 10, donc CA attendu = 100 x 10 = 1000.
    for (Account accBefore : accountsBefore) {
        Account accAfter = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :accBefore.Id];
        System.assertEquals(1000, accAfter.Chiffre_d_affaire__c,'Le CA pour ' + accBefore.Name + ' devrait être 1000 après exécution du batch.');
    }    
    }

    @isTest
    static void testBatchPerformance() {
        // Capture le temps de départ
        Long startTime = System.currentTimeMillis();
        
        System.debug('Début de l\'éxecution du batch  de mise à jours des accounts sur un benchmark de 3 accounts avec chacun une comande qui contient 100 produits.');
        
        Test.startTest();
            // Par exemple, exécution du batch qui effectue les mises à jour de CA
            UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
            Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Capture le temps à la fin
        Long endTime = System.currentTimeMillis();
        Long duration = endTime - startTime;
        
        System.debug('Durée d’exécution du batch (ms) : ' + duration);
        
        // Optionnel : on peut déclarer un seuil maximum (par exemple, 5000 ms) pour valider l'optimisation
        System.assert(duration < 5000, 'Le batch doit s’exécuter en moins de 5000 ms. Durée mesurée : ' + duration);
    }
}