@isTest
public class DataFactory {    
    //Test pipeline
    //Test pipeline
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
        Id pricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
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