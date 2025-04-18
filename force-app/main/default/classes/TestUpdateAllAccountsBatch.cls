/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
    //Test pipeline
@isTest
private class TestUpdateAllAccountsBatch {
@isTest static void testBatchExecution() {
// Création de comptes de test
Account acc1 = new Account(Name = 'Compte Test 1');
Account acc2 = new Account(Name = 'Compte Test 2');
insert new List<Account>{ acc1, acc2 };

    Test.startTest();
    // Exécution du batch en spécifiant une taille de lot adaptée (par exemple 2)
    Database.executeBatch(new UpdateAllAccounts(), 2);
    Test.stopTest();

    // Aucun assert spécifique n'est nécessaire ici, l'objectif est de vérifier que le batch s'exécute sans erreurs
}
}