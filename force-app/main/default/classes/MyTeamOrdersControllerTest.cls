/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
    //Test pipeline
@isTest(seeAllData=true)
public class MyTeamOrdersControllerTest {

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
    Decimal sumActivated = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
    
    // Calcul de la somme attendue via les TotalAmount calculés sur les Orders activés
    Decimal expected = (activatedOrder1.TotalAmount != null ? activatedOrder1.TotalAmount : 0) +
                       (activatedOrder2.TotalAmount != null ? activatedOrder2.TotalAmount : 0);
    System.assertEquals(expected, sumActivated, 'La somme des Orders activés doit être égale à la somme des TotalAmount des orders activés.');
}

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
    Decimal sumActivated = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
    System.assertEquals(null, sumActivated, 'Aucun Order activé doit renvoyer null.');
}
}