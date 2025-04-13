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
private class DataFactoryTest {

    @isTest static void testCreateAccount() {
        // Créer un compte test
        Account acc = DataFactory.createAccount('Test Account');
        // Vérifier que l'enregistrement a été inséré
        System.assertNotEquals(null, acc.Id, 'Account ID should not be null');
        System.assertEquals('Test Account', acc.Name, 'Account name should match');
    }
    
    @isTest static void testCreateProduct() {
        // Créer un produit test
        Product2 prod = DataFactory.createProduct('Test Product', 'Category');
        // Vérifier que le produit a été inséré
        System.assertNotEquals(null, prod.Id, 'Product ID should not be null');
        System.assertEquals('Test Product', prod.Name, 'Product name should match');
    }
    
    @isTest static void testCreatePricebookEntry() {
        // Setup
        Product2 prod = DataFactory.createProduct('Test Product', 'Category');
        // Créer une entrée de catalogue de prix test
        PricebookEntry pbe = DataFactory.createPricebookEntry(prod, 100);
        // Vérifier que l'enregistrement a été inséré
        System.assertNotEquals(null, pbe.Id, 'PricebookEntry ID should not be null');
        System.assertEquals(100, pbe.UnitPrice, 'Unit price should match');
    }
    
    @isTest static void testCreateOrder() {
        // Setup
        Account acc = DataFactory.createAccount('Test Account');
        // Créer une commande test
        Order ord = DataFactory.createOrder(acc);
        // Vérifier que la commande a été insérée
        System.assertNotEquals(null, ord.Id, 'Order ID should not be null');
        System.assertEquals('Draft', ord.Status, 'Order status should match');
    }
    
    @isTest static void testCreateOrderItem() {
        // Setup
        Account acc = DataFactory.createAccount('Test Account');
        Product2 prod = DataFactory.createProduct('Test Product', 'Category');
        PricebookEntry pbe = DataFactory.createPricebookEntry(prod, 100);
        Order ord = DataFactory.createOrder(acc);
        // Créer un élément de commande test
        OrderItem oi = DataFactory.createOrderItem(ord, pbe, 5);
        // Vérifier que l'élément de commande a été inséré
        System.assertNotEquals(null, oi.Id, 'OrderItem ID should not be null');
        System.assertEquals(5, oi.Quantity, 'Quantity should match');
    }
    @isTest static void testCreateOpportunity() {
        Account acc = DataFactory.createAccount('Test Account');
        Date closeDate = Date.today().addDays(30);
        Opportunity opp = DataFactory.createOpportunity(acc, 'Prospecting', closeDate);
        System.assertNotEquals(null, opp.Id, 'Opportunity ID should not be null');
        System.assertEquals('Prospecting', opp.StageName, 'Stage name should match');
        System.assertEquals(closeDate, opp.CloseDate, 'Close date should match');
    }
}