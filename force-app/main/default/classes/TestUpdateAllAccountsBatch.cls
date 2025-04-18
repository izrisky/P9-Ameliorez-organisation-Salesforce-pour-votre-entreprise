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