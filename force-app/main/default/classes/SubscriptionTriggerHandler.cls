public class SubscriptionTriggerHandler {
    
    public void beforeInsert(List<Subscription__c> newSubs) {
        SubscriptionTriggerHandlerUtil.processOverlappingCheck(newSubs, null);
        SubscriptionTriggerHandlerUtil.updateSubscriptionStatus(newSubs, null);
    }
    
    public void beforeUpdate(List<Subscription__c> newSubs, Map<Id, Subscription__c> oldMap) {
        SubscriptionTriggerHandlerUtil.processOverlappingCheck(newSubs, oldMap);
        SubscriptionTriggerHandlerUtil.updateSubscriptionStatus(newSubs, oldMap);
    }
}
