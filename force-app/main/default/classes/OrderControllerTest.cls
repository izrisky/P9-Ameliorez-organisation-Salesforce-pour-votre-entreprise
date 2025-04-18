@isTest
private class OrderControllerTest {

// Utilisation de @testSetup pour créer des données communes à plusieurs tests
@testSetup 
static void setupData(){
    // Création d'un compte de test
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    
    // Création de plusieurs commandes associées à ce compte
    // Deux commandes avec le statut Activated et une autre avec un statut différent pour simuler un cas filtré
    Order order1 = new Order(
        AccountId = acc.Id, 
        TotalAmount = 100, 
        ShipmentCost__c = 10, 
        Status = 'Activated'
    );
    Order order2 = new Order(
        AccountId = acc.Id, 
        TotalAmount = 200, 
        ShipmentCost__c = 20, 
        Status = 'Activated'
    );
    Order order3 = new Order(
        AccountId = acc.Id, 
        TotalAmount = 300, 
        ShipmentCost__c = 30, 
        Status = 'Draft'
    );
    insert new List<Order>{order1, order2, order3};
}

// Test de la méthode getSumOrdersByAccount qui calcule la somme des commandes activées
static testMethod void testGetSumOrdersByAccount(){
    // Récupération du compte créé dans la méthode @testSetup
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Decimal sumOrders = OrderController.getSumOrdersByAccount(acc.Id);
    // La somme attendue est 100 + 200 = 300 (la commande au statut Draft doit être ignorée)
    System.assertEquals(300, sumOrders, 'La somme des commandes activées doit être égale à 300');
}

// Test de la méthode updateOrderNetAmounts qui calcule le NetAmount__c
static testMethod void testUpdateOrderNetAmounts(){
    // Création d'une liste en mémoire (sans insert) afin de simuler un before update
    List<Order> orders = new List<Order>{
        new Order(TotalAmount = 100, ShipmentCost__c = 10),
        new Order(TotalAmount = 200, ShipmentCost__c = 20),
        // Cas où TotalAmount est null – on considère par défaut 0
        new Order(TotalAmount = null, ShipmentCost__c = 30)
    };
    OrderController.updateOrderNetAmounts(orders);
    System.assertEquals(90, orders[0].NetAmount__c, '100 - 10 doit donner 90');
    System.assertEquals(180, orders[1].NetAmount__c, '200 - 20 doit donner 180');
    System.assertEquals(-30, orders[2].NetAmount__c, '0 - 30 doit donner -30');
}

// Test de la méthode updateAccountsAfterOrders qui actualise le Chiffre_d_affaire__c sur les Comptes
static testMethod void testUpdateAccountsAfterOrders(){
    // Création d'un compte spécifique pour ce test
    Account acc = new Account(Name = 'Account for Update');
    insert acc;
    
    // Création de commandes associées à ce compte (simulateur d'après update)
    Order order1 = new Order(
        AccountId = acc.Id, 
        TotalAmount = 150
    );
    Order order2 = new Order(
        AccountId = acc.Id, 
        TotalAmount = 250
    );
    List<Order> orders = new List<Order>{order1, order2};

    Test.startTest();
        // Appel de la méthode qui effectue l'update des comptes à partir des commandes
        OrderController.updateAccountsAfterOrders(orders);
    Test.stopTest();
    
    // Vérifier que le compte a bien été mis à jour : 150 + 250 = 400
    Account updatedAcc = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
    System.assertEquals(400, updatedAcc.Chiffre_d_affaire__c, 'La somme totale sur le compte doit être égale à 400');
}
}