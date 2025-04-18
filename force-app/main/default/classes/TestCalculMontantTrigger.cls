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
//Test pipeline
@isTest
private class TestCalculMontantTrigger {
@isTest
static void testCalculMontantCalculation() {
// Création d'un compte pour l'Order
Account acc = new Account(Name = 'Test Compte');
insert acc;

    // Récupération du Pricebook standard requis pour créer un Order
    Id pbId = Test.getStandardPricebookId();
    
    // Création de l'Order en mode "Draft"
    // On définit un ShipmentCost initial (modifiable) et on laisse TotalAmount se calculer via les OrderItems
    Order ord = new Order(
        AccountId = acc.Id,
        EffectiveDate = Date.today(),
        Status = 'Draft',
        Pricebook2Id = pbId,
        ShipmentCost__c = 20
    );
    insert ord;
    
    // Création d'un OrderItem afin que le TotalAmount de l'Order soit calculé (TotalAmount = UnitPrice * Quantity)
    Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
    insert prod;
    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = pbId, 
        Product2Id = prod.Id, 
        UnitPrice = 100, 
        IsActive = true
    );
    insert pbe;
    OrderItem oi = new OrderItem(
        OrderId = ord.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 100
    );
    insert oi;
    
    // Requêter l'Order afin d'obtenir la valeur calculée pour TotalAmount
    Order ordWithAmount = [SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Id = :ord.Id];
    System.assertNotEquals(null, ordWithAmount.TotalAmount, 'Le TotalAmount devrait être calculé automatiquement via les OrderItems.');
    
    // Mise à jour de l'Order : on change uniquement le ShipmentCost__c pour déclencher le trigger
    // Le trigger CalculMontant va alors calculer NetAmount__c = TotalAmount - ShipmentCost__c
    ordWithAmount.ShipmentCost__c = 30;
    update ordWithAmount;
    
    // Requêter le Order mis à jour pour vérifier le calcul de NetAmount__c
    Order updatedOrder = [SELECT TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Id = :ord.Id];
    Decimal expected = updatedOrder.TotalAmount - updatedOrder.ShipmentCost__c;
    System.assertEquals(expected, updatedOrder.NetAmount__c, 
        'Le trigger doit calculer NetAmount__c en faisant TotalAmount - ShipmentCost__c.');
}
}