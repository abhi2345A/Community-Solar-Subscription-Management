trigger restrictOverlappingSubscriptions on Subscription__c (before insert, before update) {
    SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
