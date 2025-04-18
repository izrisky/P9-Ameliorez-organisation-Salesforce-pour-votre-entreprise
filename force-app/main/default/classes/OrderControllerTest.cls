@isTest
public class OrderControllerTest {

// Méthode utilitaire pour créer un Order activé avec un Order Item
// Le TotalAmount sera calculé automatiquement par le système (UnitPrice * Quantity)
private static Order createActivatedOrder(Account acc, Decimal unitPrice, Integer quantity) {
    // Création de l'Order via DataFactory (la requête sur Pricebook2 fonctionne avec seeAllData=true)
    Order ord = DataFactory.createOrder(acc);
    
    // Créez un produit et une entrée de Pricebook pour pouvoir créer un OrderItem
    Product2 prod = DataFactory.createProduct('Test Product ' + System.currentTimeMillis(), 'Test');
    PricebookEntry pbe = DataFactory.createPricebookEntry(prod, unitPrice);
    
    // Création d'un OrderItem afin de permettre le calcul du TotalAmount
    DataFactory.createOrderItem(ord, pbe, quantity);
    
    // Mise à jour de l'Order en définissant le statut à 'Activated'
    ord.Status = 'Activated';
    update ord;
    
    // Récupérer l'Order mis à jour avec son TotalAmount calculé
    return [SELECT Id, TotalAmount FROM Order WHERE Id = :ord.Id];
}

@isTest 
static void testGetSumOrdersByAccountWithActivatedOrders() {
    // Création d'un compte de test
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    
    // Création de deux Orders activés avec des Order Items
    Order activatedOrder1 = createActivatedOrder(acc, 100, 1);  // Total attendu = 100
    Order activatedOrder2 = createActivatedOrder(acc, 150, 2);  // Total attendu = 300
    
    // Création d'un Order non activé (statut Draft) qui ne doit pas être comptabilisé
    Order draftOrder = DataFactory.createOrder(acc);
    Product2 prod = DataFactory.createProduct('Draft Product', 'Test');
    PricebookEntry pbe = DataFactory.createPricebookEntry(prod, 200);
    DataFactory.createOrderItem(draftOrder, pbe, 1);
    // draftOrder reste en statut 'Draft'
    
    // Appel de la méthode qui effectue l'agrégation sur les Orders activés
    Decimal sumActivated = OrderController.getSumOrdersByAccount(acc.Id);
    
    // Calcul de la somme attendue via les TotalAmount calculés sur les Orders activés
    Decimal expected = (activatedOrder1.TotalAmount != null ? activatedOrder1.TotalAmount : 0) +
                       (activatedOrder2.TotalAmount != null ? activatedOrder2.TotalAmount : 0);
    System.assertEquals(expected, sumActivated, 'La somme des Orders activés doit être égale à la somme des TotalAmount des orders activés.');
}

    //Test pipeline
    //Test pipeline
    //Test pipeline
@isTest 
static void testGetSumOrdersByAccountWithoutActivatedOrders() {
    // Création d'un compte pour lequel aucun Order n'est activé
    Account acc = new Account(Name = 'Test Account No Activated');
    insert acc;
    
    // Création d'un Order en statut Draft et ajout d'un Order Item
    Order draftOrder = DataFactory.createOrder(acc);
    Product2 prod = DataFactory.createProduct('Non activated Product', 'Test');
    PricebookEntry pbe = DataFactory.createPricebookEntry(prod, 200);
    DataFactory.createOrderItem(draftOrder, pbe, 1);
    // Le statut reste 'Draft'
    
    // Appel de la méthode : aucun Order étant activé, l'agrégation doit renvoyer null
    Decimal sumActivated = OrderController.getSumOrdersByAccount(acc.Id);
    System.assertEquals(null, sumActivated, 'Aucun Order activé doit renvoyer null.');
}
}