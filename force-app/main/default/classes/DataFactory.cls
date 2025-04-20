@isTest
public with sharing class DataFactory {
// Méthode utilitaire pour créer un jeu de données complet de test.
public static void createTestData(Integer accCount) {
    // Création de plusieurs comptes de test (par exemple 3 comptes)
    List<Account> accounts = new List<Account>();
    for(Integer i=1; i<=accCount; i++){
        accounts.add(new Account(Name = 'Test Account ' + i));
    }
    insert accounts;
    
    // On crée un produit commun pour tous les comptes
    Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
    insert prod;
    
    // Récupération du Pricebook standard
    Id pricebookId = Test.getStandardPricebookId();
    
    // Création d'une entrée PricebookEntry
    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = prod.Id,
        UnitPrice = 100.00,
        IsActive = true,
        UseStandardPrice = false
    );
    insert pbe;
    
    // Pour chaque compte, créer 100 commandes et pour chacune un OrderItem
    for(Account acc : accounts) {
        List<Order> orders = new List<Order>();
        for (Integer j = 0; j < 100; j++) {
            orders.add(new Order(
                AccountId = acc.Id,
                Status = 'Draft',
                Name = 'Order ' + (j + 1),
                EffectiveDate = Date.today(),
                Pricebook2Id = pricebookId
            ));
        }
        insert orders;
        
        // Ajout d'un OrderItem à chaque commande pour fixer le TotalAmount à 10
        List<OrderItem> items = new List<OrderItem>();
        for(Order o : orders) {
            items.add(new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 10,
                ServiceDate = Date.today().addDays(2)
            ));
        }
        insert items;
        
        // Activation de toutes les commandes (la logique de trigger va cumuler les 10 par commande)
        for(Order o : orders) {
            o.Status = 'Activated';
        }
        update orders;
    }
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