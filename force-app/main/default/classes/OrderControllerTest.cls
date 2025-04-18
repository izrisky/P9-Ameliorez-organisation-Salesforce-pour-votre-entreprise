@isTest
private class OrderControllerTest {

    @TestSetup
    static void setup() {
        // 1. Création du compte
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // 2. Création du produit
        Product2 prod = new Product2(
            Name = 'Test Product', 
            IsActive = true
        );
        insert prod;

        // 3. Récupération du pricebook standard
        Id pricebookId = Test.getStandardPricebookId();

        // 4. Création de l'entrée pricebook
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;

        // 5. Création de la commande en brouillon
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = pricebookId
        );
        insert ord;

        // 6. Ajout du produit à la commande
        OrderItem item = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100,
            ServiceDate = Date.today()
        );
        insert item;

        // 7. Activation de la commande
        ord.Status = 'Activated';
        update ord;
    }

    @isTest
    static void testGetSumOrdersByAccount() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Decimal result = OrderController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(100, result, 'Le montant total devrait être 100');
    }
}