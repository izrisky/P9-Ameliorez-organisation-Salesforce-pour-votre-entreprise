@isTest
private class UpdateAllAccountsBatchTest {
    @TestSetup
    static void setup() {
        // 1. Create Account
        Account acc = new Account(Name = 'Test Account Batch');
        insert acc;
    
        // 2. Create Product
        Product2 prod = new Product2(
            Name = 'Test Product', 
            IsActive = true
        );
        insert prod;
    
        // 3. Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        // 4. Create PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
    
        // 5. Create Orders
        List<Order> orderList = new List<Order>();
        for (Integer i = 0; i < 3; i++){
            Order ord = new Order(
                AccountId = acc.Id,
                Status = 'Draft',
                Name = 'Order N° ' + (i + 1),
                EffectiveDate = Date.today(),
                Pricebook2Id = pricebookId
            );
            orderList.add(ord);
        }
        insert orderList;
    
        // 6. Add OrderItems with correct index
        List<OrderItem> itemList = new List<OrderItem>();
        for (Integer i = 0; i < orderList.size(); i++) {
            Order ord = orderList[i];
            OrderItem item = new OrderItem(
                OrderId = ord.Id,
                PricebookEntryId = pbe.Id,
                Quantity = i + 1, 
                UnitPrice = 50 + (50 * i),
                ServiceDate = Date.today()
            );
            itemList.add(item);
        }   
        insert itemList;
    
        // 7. Activate Orders
        for (Order ord : orderList) {
            ord.Status = 'Activated';
        }
        update orderList;
    }
    
    @isTest 
    static void testBatchUpdate() {         
        Test.startTest();
            UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
            Database.executeBatch(batch, 1);
        Test.stopTest();
        
        // Requery Account to get updated value
        Account updatedAcc = [SELECT Chiffre_d_affaire__c FROM Account WHERE  Name = 'Test Account Batch'];
        
        // Expected total: 50 (1*50) + 200 (2*100) + 450 (3*150) = 700
        System.assertEquals(700, updatedAcc.Chiffre_d_affaire__c, 
            'Le champ Chiffre_d_affaire__c doit être mis à jour à 700.');
    }
}