@isTest
public with sharing class DataFactory {
    public static void createTestData() {
    // 1. Création du compte de test
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    // 2. Création du produit de test
    Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
    insert prod;
    
    // 3. Récupération du pricebook standard via la méthode dédiée
    Id pricebookId = getPricebookId();
    
    // 4. Création de l'entrée PricebookEntry avec un UnitPrice fixé (ici 100)
    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = prod.Id,
        UnitPrice = 100.00,
        IsActive = true,
        UseStandardPrice = false
    );
    insert pbe;
    
    // 5. Création de 100 commandes en mode 'Draft'
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
    
    // 6. Ajout d'un OrderItem à chacune des commandes afin d'obtenir un TotalAmount de 10
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
    
    // 7. Passage de toutes les commandes de 'Draft' à 'Activated'
    for (Order o : orders) {
        o.Status = 'Activated';
    }
    update orders;
}

public static Account createAccount(String name) {
    Account acc = new Account(Name = name);
    insert acc;
    return acc;
}

public static Opportunity createOpportunity(Account acc, String stageName, Date closeDate) {
    Opportunity opp = new Opportunity(
        Name = 'Test Opportunity',
        AccountId = acc.Id,
        StageName = stageName,
        CloseDate = closeDate
    );
    insert opp;
    return opp;
}

public static Product2 createProduct(String name, String family) {
    Product2 prod = new Product2(Name = name, Family = family);
    insert prod;
    return prod;
}

public static Id getPricebookId() {
    if (Test.isRunningTest()) {
        return Test.getStandardPricebookId();
    } else {
        return [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
    }
}

public static PricebookEntry createPricebookEntry(Product2 product, Decimal unitPrice) {
    Id pricebookId = getPricebookId();
    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = product.Id,
        UnitPrice = unitPrice,
        IsActive = true
    );
    insert pbe;
    return pbe;
}

public static Order createOrder(Account acc) {
    Id pricebookId = getPricebookId();
    Order order = new Order(
        AccountId = acc.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = pricebookId
    );
    insert order;
    return order;
}

public static OrderItem createOrderItem(Order order, PricebookEntry pbe, Integer quantity) {
    OrderItem orderItem = new OrderItem(
        OrderId = order.Id,
        PricebookEntryId = pbe.Id,
        Quantity = quantity,
        UnitPrice = pbe.UnitPrice
    );
    insert orderItem;
    return orderItem;
}
}