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

    // 5. Création de 100 commandes en mode Draft
    List<Order> orders = new List<Order>();
    for (Integer i = 0; i < 100; i++) {
        orders.add(new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            Name = 'Order ' + (i + 1),
            EffectiveDate = Date.today(),
            Pricebook2Id = pricebookId
        ));
    }
    insert orders;
    
    // 6. Ajout d'un OrderItem à chacune des commandes pour obtenir TotalAmount = 10
    List<OrderItem> items = new List<OrderItem>();
    for (Order o : orders) {
        items.add(new OrderItem(
            OrderId = o.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 10,
            ServiceDate = Date.today().addDays(2)
        ));
    }
    insert items;
    
    // 7. Activation des commandes (passage de Draft à Activated)
    //    Le déclencheur s'exécutera et cumulera pour chaque commande le TotalAmount (10)
    for (Order o : orders) {
        o.Status = 'Activated';
    }
    update orders;
}

@isTest
static void testGetSumOrdersByAccount() {
    // Récupération du compte
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    
    Test.startTest();
        Decimal result = OrderController.getSumOrdersByAccount(acc.Id);
    Test.stopTest();

    // Avec 100 commandes à 10 chacune, le total doit être 1000.
    System.assertEquals(1000, result, 'Le montant total devrait être 1000.');
}

@isTest
static void testUpdateOrderNetAmountsFromSetup() {
    // Récupérer une commande créée dans le TestSetup
    Order orderToTest = [SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c 
                         FROM Order 
                         WHERE AccountId IN (SELECT Id FROM Account WHERE Name = 'Test Account')
                         LIMIT 1];
                         
    // Vérifier que TotalAmount est égal à 10 (défini via l'OrderItem)
    System.assertEquals(10, orderToTest.TotalAmount, 'TotalAmount initial doit être 10.');
    
    // Modifier ShipmentCost__c pour simuler une mise à jour (par exemple, 3)
    orderToTest.ShipmentCost__c = 3;
    
    Test.startTest();
        // Appel de la méthode de mise à jour du NetAmount
        OrderController.updateOrderNetAmounts(new List<Order>{ orderToTest });
    Test.stopTest();
    
    // Le NetAmount__c doit être égal à 10 - 3 = 7
    System.assertEquals(7, orderToTest.NetAmount__c, 'NetAmount__c doit être égal à 7 (10 - 3).');
}

@isTest
static void testUpdateOrderByFashaOnAccountWith100Orders() {
    // Récupération du compte pour vérifier le chiffre d'affaires initial
    Account accBefore = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
    System.assertEquals(1000, accBefore.Chiffre_d_affaire__c, 'Le CA initial devrait être 1000.');
    
    // Création d'un utilisateur représentant le commercial de Fasha
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User fashaUser = new User(
        Alias = 'fasha',
        Email = 'fasha@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Fasha',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        Username = 'fasha' + System.currentTimeMillis() + '@test.com'
    );
    insert fashaUser;
    
    // Récupération d'une commande associée au compte
    Order orderToUpdate = [SELECT Id, EffectiveDate, TotalAmount FROM Order WHERE AccountId = :accBefore.Id LIMIT 1];
    
    Test.startTest();
        // Exécution de la mise à jour sous l'utilisateur Fasha
        System.runAs(fashaUser) {
            orderToUpdate.Status = 'Draft';
            update orderToUpdate;

            //ajout d'un nouveau produit à la commande pour modifier son TotalAmount
            Product2 newProd = new Product2(Name = 'New Test Product', IsActive = true);
            insert newProd;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry newPbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = newProd.Id,
                UnitPrice = 20.00,
                IsActive = true,
                UseStandardPrice = false
            );
            insert newPbe;
            
            OrderItem newItem = new OrderItem(
                OrderId = orderToUpdate.Id,
                PricebookEntryId = newPbe.Id,
                Quantity = 1,
                UnitPrice = 20,
                ServiceDate = Date.today().addDays(2)
            );
            insert newItem;
            
            // Mise à jour de la commande pour provoquer l'exécution du trigger
            orderToUpdate.Status = 'Activated';
            update orderToUpdate;
        
            // Requestionner la commande pour obtenir le TotalAmount actualisé
            orderToUpdate = [SELECT Id, TotalAmount FROM Order WHERE Id = :orderToUpdate.Id];
        }
    Test.stopTest();
    // L'ordre initial comportait un OrderItem de 10, et on vient d'ajouter un nouvel OrderItem de 20,
    // donc le nouveau TotalAmount devrait être 10 + 20 = 30.
    System.assertEquals(30, orderToUpdate.TotalAmount, 'Le nouveau TotalAmount devrait être 30.');

    // Vérifier la mise à jour du chiffre d'affaires du compte
    Account accAfter = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :accBefore.Id];
    Decimal expectedCA = 990 + orderToUpdate.TotalAmount; // 1000-10 + 30 (nouveau total)  = 1020
    System.assertEquals(expectedCA, accAfter.Chiffre_d_affaire__c, 'Le CA du compte devrait être mis à jour à ' + expectedCA + '.');
}
// Optionnel : vous pouvez ajouter des tests unitaires directs pour OrderSelector et AccountSelector si besoin
@isTest
static void testOrderSelector() {
    // Test sur le OrderSelector appelé depuis le controller déjà testé
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    AggregateResult result = OrderSelector.getSumAggregateByAccount(acc.Id);
    Decimal sum = (Decimal)result.get('total');
    System.assertEquals(1000, sum, 'OrderSelector doit retourner 1000 pour la somme des commandes activées.');
}

@isTest
static void testAccountSelector() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    Set<Id> accountIds = new Set<Id>{acc.Id};
    Map<Id, Account> accounts = AccountSelector.getAccountsByIds(accountIds);
    System.assert(accounts.containsKey(acc.Id), 'AccountSelector doit retourner le compte demandé.');
}
}