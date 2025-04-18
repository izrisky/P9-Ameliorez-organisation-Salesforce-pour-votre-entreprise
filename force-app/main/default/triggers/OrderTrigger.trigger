trigger OrderTrigger on SOBJECT (before insert) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderController.handleBeforeUpdate(Trigger.new);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        OrderController.handleAfterUpdate(Trigger.new);
    }
}