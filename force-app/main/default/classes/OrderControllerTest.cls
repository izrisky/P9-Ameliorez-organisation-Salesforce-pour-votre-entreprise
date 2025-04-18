@isTest
private class OrderControllerTest {

    @TestSetup
    static void setup() {
        // Création des données de test
        Pricebook2 pb = new Pricebook2(Name = 'Test Pricebook');
        insert pb;

        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Création des commandes
        List<Order> orders = new List<Order>();
        orders.add(new Order(
            AccountId = acc.Id,
            Status = 'Activated',
            EffectiveDate = System.today(),
            Pricebook2Id = pb.Id
        ));
        orders.add(new Order(
            AccountId = acc.Id,
            Status = 'Activated',
            EffectiveDate = System.today(),
            Pricebook2Id = pb.Id
        ));
        insert orders;

        // Création des lignes de commande
        List<OrderItem> items = new List<OrderItem>();
        items.add(new OrderItem(
            OrderId = orders[0].Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        ));
        items.add(new OrderItem(
            OrderId = orders[1].Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 100
        ));
        insert items;
    }

    @isTest
    static void testGetSumOrdersByAccount_WithActivatedOrders() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        Decimal sum = OrderController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();
        System.assertEquals(300, sum, 'La somme devrait être 300 (100 + 200)');
    }

    // Les autres tests restent similaires mais doivent utiliser OrderItem pour définir les montants
    @isTest
    static void testUpdateAccountsAfterOrders_SingleOrder() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Activated',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;

        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        OrderItem item = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 3,
            UnitPrice = 100
        );
        insert item;

        Test.startTest();
        OrderController.updateAccountsAfterOrders(new List<Order>{ord});
        Test.stopTest();

        Account updatedAcc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(300, updatedAcc.Chiffre_d_affaire__c, 'Le CA devrait être 300');
    }
}