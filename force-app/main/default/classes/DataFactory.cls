public with sharing class DataFactory {
    ///Ce commentaire est ajouter pour tester la pipeline !!!!!!
    ///Ce commentaire est ajouter pour tester la pipeline !!!!!!
    public static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }
    public static Opportunity createOpportunity(Account acc, String stageName, Date closeDate) {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = stageName
        );
        insert opp;
        return opp;
    }

    public static Product2 createProduct(String name, String family) {
        Product2 prod = new Product2(Name = name, Family = family);
        insert prod;
        return prod;
    }

    public static PricebookEntry createPricebookEntry(Product2 product, Decimal unitPrice) {
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert pbe;
        return pbe;
    }

    public static Order createOrder(Account acc) {
        Order order = new Order(
            AccountId = acc.Id,
            Status = 'Draft'
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