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
@isTest(seeAllData=true)
private class DataFactoryTest {

    @isTest
    static void testCreateAccount() {
        Account acc = DataFactory.createAccount('Test Account');
        System.assertNotEquals(null, acc.Id, 'L\'account doit être inséré correctement.');
    }
    
    @isTest
    static void testCreateOpportunity() {
        Account acc = DataFactory.createAccount('Opportunity Account');
        Opportunity opp = DataFactory.createOpportunity(acc, 'Prospecting', Date.today().addDays(30));
        System.assertNotEquals(null, opp.Id, 'L\'opportunité doit être insérée.');
        System.assertEquals(acc.Id, opp.AccountId, 'L\'AccountId de l\'opportunité doit correspondre à celui de l\'account.');
        System.assertEquals('Prospecting', opp.StageName, 'Le StageName doit être correctement assigné.');
    }
    
    @isTest
    static void testCreateProduct() {
        Product2 prod = DataFactory.createProduct('Test Product', 'Test Family');
        System.assertNotEquals(null, prod.Id, 'Le produit doit être inséré.');
    }
    
    @isTest
    static void testGetPricebookId() {
        // Dans le contexte de test, la méthode doit retourner le standard Pricebook Id
        Id pbId = DataFactory.getPricebookId();
        System.assertEquals(Test.getStandardPricebookId(), pbId, 
            'La méthode getPricebookId doit retourner le Pricebook Id standard en mode test.');
    }
    
    @isTest
    static void testCreatePricebookEntry() {
        Product2 prod = DataFactory.createProduct('Product for PBE', 'Test Family');
        PricebookEntry pbe = DataFactory.createPricebookEntry(prod, 100);
        System.assertNotEquals(null, pbe.Id, 'Le PricebookEntry doit être inséré.');
        System.assertEquals(prod.Id, pbe.Product2Id, 'Le PricebookEntry doit référencer le bon produit.');
        System.assertEquals(100, pbe.UnitPrice, 'Le UnitPrice doit être correctement assigné.');
        System.assertEquals(true, pbe.IsActive, 'Le PricebookEntry doit être actif.');
    }
    
    @isTest
    static void testCreateOrder() {
        Account acc = DataFactory.createAccount('Account for Order');
        Order ord = DataFactory.createOrder(acc);
        System.assertNotEquals(null, ord.Id, 'L\'order doit être inséré.');
        System.assertEquals(acc.Id, ord.AccountId, 'L\'Order doit être rattaché à l\'account correspondant.');
        System.assertEquals('Draft', ord.Status, 'Le statut de l\'Order doit être "Draft".');
        System.assertNotEquals(null, ord.Pricebook2Id, 'L\'Order doit contenir un Pricebook2Id.');
    }
    
    @isTest
    static void testCreateOrderItem() {
        Account acc = DataFactory.createAccount('Account for OrderItem');
        Order ord = DataFactory.createOrder(acc);
        Product2 prod = DataFactory.createProduct('Product for OrderItem', 'Test Family');
        PricebookEntry pbe = DataFactory.createPricebookEntry(prod, 200);
        OrderItem oi = DataFactory.createOrderItem(ord, pbe, 2);
        
        System.assertNotEquals(null, oi.Id, 'L\'OrderItem doit être inséré.');
        System.assertEquals(ord.Id, oi.OrderId, 'L\'OrderItem doit être rattaché au bon Order.');
        System.assertEquals(pbe.Id, oi.PricebookEntryId, 'L\'OrderItem doit référencer le bon PricebookEntry.');
        System.assertEquals(2, oi.Quantity, 'La quantité de l\'OrderItem doit être 2.');
        System.assertEquals(200, oi.UnitPrice, 'Le UnitPrice de l\'OrderItem doit être correctement assigné.');
    }
}