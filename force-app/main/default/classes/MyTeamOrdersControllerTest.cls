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
@isTest
private class MyTeamOrdersControllerTest {
@isTest static void testGetSumOrdersByAccountWithActivatedOrders() {
// Création d'un compte de test
Account acc = new Account(Name = 'Test Account');
insert acc;

    // Récupérer l'ID Pricebook standard requis pour créer des Orders
    Id pbId = Test.getStandardPricebookId();
    
    // Création d'orders pour le compte avec différents statuts
    Order activatedOrder1 = new Order(
        AccountId = acc.Id,
        TotalAmount = 100,
        Status = 'Activated',
        EffectiveDate = Date.today(),
        Pricebook2Id = pbId
    );
    
    Order activatedOrder2 = new Order(
        AccountId = acc.Id,
        TotalAmount = 150,
        Status = 'Activated',
        EffectiveDate = Date.today(),
        Pricebook2Id = pbId
    );
    
    Order nonActivatedOrder = new Order(
        AccountId = acc.Id,
        TotalAmount = 200,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = pbId
    );
    insert new List<Order>{activatedOrder1, activatedOrder2, nonActivatedOrder};
    
    // Appel de la méthode et vérification que seule la somme des commandes 'Activated' est retournée
    Decimal sumActivated = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
    System.assertEquals(250, sumActivated, 'La somme des orders activés devrait être 250 (100 + 150).');
}

@isTest static void testGetSumOrdersByAccountWithoutActivatedOrders() {
    // Création d'un compte pour lequel aucun Order n'est en statut "Activated"
    Account acc = new Account(Name = 'Test Account No Activated');
    insert acc;
    
    Id pbId = Test.getStandardPricebookId();
    Order nonActivatedOrder = new Order(
        AccountId = acc.Id,
        TotalAmount = 300,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = pbId
    );
    insert nonActivatedOrder;
    
    // Appel de la méthode : la somme devrait être nulle si aucun order n'est activé
    Decimal sumActivated = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
    System.assertEquals(null, sumActivated, 'Aucune order activée ne doit renvoyer null.');
}
}