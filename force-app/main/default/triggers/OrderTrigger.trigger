trigger OrderTrigger on Order (before insert, before update, after update) {
    // Before Insert/Update : Calcul du NetAmount
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        OrderController.updateOrderNetAmounts(Trigger.new);
    }

    // After Update : Mise à jour des comptes
    if (Trigger.isAfter && Trigger.isUpdate) {
        OrderController.updateAccountsAfterOrders(Trigger.new, Trigger.old);
    }
}