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
@isTest
static void testGetSumOrdersByAccountWithActivatedOrders() {
// Création d'un compte de test
Account acc = new Account(Name = 'Test Account');
insert acc;

    Id pbId = Test.getStandardPricebookId();
    
    // Création d'un Order "Activated" en utilisant put() pour définir TotalAmount
    Order activatedOrder1 = new Order(
        AccountId = acc.Id,
        Status = 'Activated',
        EffectiveDate = Date.today(),
        Pricebook2Id = pbId
    );
    activatedOrder1.put('TotalAmount', 100);
    
    Order activatedOrder2 = new Order(
        AccountId = acc.Id,
        Status = 'Activated',
        EffectiveDate = Date.today(),
        Pricebook2Id = pbId
    );
    activatedOrder2.put('TotalAmount', 150);
    
    // Création d'un Order avec un autre status (qui ne doit pas être comptabilisé)
    Order nonActivatedOrder = new Order(
        AccountId = acc.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = pbId
    );
    nonActivatedOrder.put('TotalAmount', 200);
    
    insert new List<Order>{activatedOrder1, activatedOrder2, nonActivatedOrder};
    
    // Appel de la méthode en passant l'Id du compte et vérification que seule la somme des Orders "Activated" est retournée
    Decimal sumActivated = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
    System.assertEquals(250, sumActivated, 'La somme des orders activés devrait être égale à 250 (100 + 150).');
}

@isTest 
static void testGetSumOrdersByAccountWithoutActivatedOrders() {
    // Création d'un compte pour lequel aucun Order n'est en statut "Activated"
    Account acc = new Account(Name = 'Test Account No Activated');
    insert acc;
    
    Id pbId = Test.getStandardPricebookId();
    Order nonActivatedOrder = new Order(
        AccountId = acc.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = pbId
    );
    nonActivatedOrder.put('TotalAmount', 300);
    insert nonActivatedOrder;
    
    // Appel de la méthode : la somme devrait être null si aucun order n'est activé
    Decimal sumActivated = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
    System.assertEquals(null, sumActivated, 'Aucun order activé doit retourner null.');
}
}