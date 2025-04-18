@isTest
private class OrderControllerTest {

    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        List<Order> orders = new List<Order>();
        orders.add(new Order(
            AccountId = acc.Id,
            Status = 'Activated',
            TotalAmount = 100,
            EffectiveDate = System.today()
        ));
        orders.add(new Order(
            AccountId = acc.Id,
            Status = 'Activated',
            TotalAmount = 200,
            EffectiveDate = System.today()
        ));
        orders.add(new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            TotalAmount = 300,
            EffectiveDate = System.today()
        ));
        insert orders;
    }

    // Tests pour getSumOrdersByAccount
    @isTest
    static void testGetSumOrdersByAccount_WithActivatedOrders() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        Decimal sum = OrderController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();
        System.assertEquals(300, sum, 'La somme devrait être 300');
    }

    @isTest
    static void testGetSumOrdersByAccount_NoActivatedOrders() {
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;
        Test.startTest();
        Decimal sum = OrderController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();
        System.assertEquals(0, sum, 'La somme devrait être 0 quand il n\'y a pas de commandes activées');
    }

    // Tests pour updateOrderNetAmounts
    @isTest
    static void testUpdateOrderNetAmounts_CalculCorrect() {
        Order ord = new Order(
            TotalAmount = 100,
            ShipmentCost__c = 20,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        Test.startTest();
        OrderController.updateOrderNetAmounts(new List<Order>{ord});
        Test.stopTest();
        System.assertEquals(80, ord.NetAmount__c, 'Le montant net devrait être 80');
    }

    @isTest
    static void testUpdateOrderNetAmounts_ShipmentCostNull() {
        Order ord = new Order(
            TotalAmount = 50,
            ShipmentCost__c = null,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        Test.startTest();
        OrderController.updateOrderNetAmounts(new List<Order>{ord});
        Test.stopTest();
        System.assertEquals(50, ord.NetAmount__c, 'Le montant net devrait être 50');
    }

    @isTest
    static void testUpdateOrderNetAmounts_TotalAmountNull() {
        Order ord = new Order(
            TotalAmount = null,
            ShipmentCost__c = 30,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        Test.startTest();
        OrderController.updateOrderNetAmounts(new List<Order>{ord});
        Test.stopTest();
        System.assertEquals(-30, ord.NetAmount__c, 'Le montant net devrait être -30');
    }

    // Tests pour updateAccountsAfterOrders
    @isTest
    static void testUpdateAccountsAfterOrders_SingleOrder() {
        Account acc = new Account(Name = 'Test Account', Chiffre_d_affaire__c = 100);
        insert acc;

        Order ord = new Order(
            AccountId = acc.Id,
            TotalAmount = 200,
            EffectiveDate = System.today(),
            Status = 'Activated'
        );
        insert ord;

        Test.startTest();
        OrderController.updateAccountsAfterOrders(new List<Order>{ord});
        Test.stopTest();

        Account updatedAcc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(300, updatedAcc.Chiffre_d_affaire__c, 'Le chiffre d\'affaire devrait être 300');
    }

    @isTest
    static void testUpdateAccountsAfterOrders_MultipleOrders() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        List<Order> orders = new List<Order>{
            new Order(
                AccountId = acc.Id,
                TotalAmount = 100,
                EffectiveDate = System.today(),
                Status = 'Activated'
            ),
            new Order(
                AccountId = acc.Id,
                TotalAmount = 200,
                EffectiveDate = System.today(),
                Status = 'Activated'
            )
        };
        insert orders;

        Test.startTest();
        OrderController.updateAccountsAfterOrders(orders);
        Test.stopTest();

        Account updatedAcc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(300, updatedAcc.Chiffre_d_affaire__c, 'Le chiffre d\'affaire devrait être 300');
    }

    @isTest
    static void testUpdateAccountsAfterOrders_OrderWithoutAccount() {
        Order ord = new Order(
            TotalAmount = 200,
            EffectiveDate = System.today(),
            Status = 'Activated'
        );
        insert ord;

        Test.startTest();
        OrderController.updateAccountsAfterOrders(new List<Order>{ord});
        Test.stopTest();

        // Aucun compte ne devrait être mis à jour
        List<Account> accounts = [SELECT Id FROM Account];
        System.assert(accounts.isEmpty(), 'Aucun compte ne devrait être créé/mis à jour');
    }
}