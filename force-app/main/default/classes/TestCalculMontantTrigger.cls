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
@isTest
private class TestCalculMontantTrigger {
@isTest
static void testCalculMontantCalculation() {
// Création d'un compte pour l'Order
Account acc = new Account(Name = 'Test Compte');
insert acc;

    // Récupération du Pricebook standard requis pour créer un Order
    Id pbId = Test.getStandardPricebookId();
    
    // Création initiale de l'Order en utilisant des assignations dynamiques pour contourner la non-écriture
    Order ord = new Order(
        AccountId = acc.Id,
        EffectiveDate = Date.today(),
        Status = 'Draft',
        Pricebook2Id = pbId
    );
    // Utilisation de put pour définir des valeurs sur TotalAmount et ShipmentCost__c
    ord.put('TotalAmount', 100);
    ord.put('ShipmentCost__c', 20);
    insert ord;
    
    // Préparation d'une mise à jour pour déclencher le trigger "CalculMontant"
    // Pour modifier ces champs non modifiables par assignation classique, on utilise également put()
    Order ordToUpdate = [SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Id = :ord.Id];
    ordToUpdate.put('TotalAmount', 150);
    ordToUpdate.put('ShipmentCost__c', 30);
    update ordToUpdate;
    
    // Vérifier que NetAmount__c correspond à TotalAmount - ShipmentCost__c après déclenchement du trigger
    Order updatedOrder = [SELECT TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Id = :ord.Id];
    Decimal expected = (Decimal)updatedOrder.get('TotalAmount') - (Decimal)updatedOrder.get('ShipmentCost__c');
    System.assertEquals(expected, updatedOrder.get('NetAmount__c'), 
        'Le trigger doit calculer NetAmount__c en faisant TotalAmount - ShipmentCost__c.');
}
}