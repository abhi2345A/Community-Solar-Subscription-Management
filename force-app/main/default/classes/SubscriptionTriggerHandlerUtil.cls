public class SubscriptionTriggerHandlerUtil {
    
    public static void processOverlappingCheck(List<Subscription__c> newSubs, Map<Id, Subscription__c> oldMap) {
        Set<Id> customerIds = new Set<Id>();
        Set<Id> solarSystemIds = new Set<Id>();
        Map<String, List<Subscription__c>> newSubsMap = new Map<String, List<Subscription__c>>();
        Set<Id> newSubIds = new Set<Id>();
        
        for (Subscription__c sub : newSubs) {
            if (oldMap == null || sub.Start_Date__c != oldMap.get(sub.Id).Start_Date__c || sub.End_Date__c != oldMap.get(sub.Id).End_Date__c) {
                customerIds.add(sub.Customer__c);
                solarSystemIds.add(sub.Shared_Solar_System__c);
                
                String key = buildKey(sub.Customer__c, sub.Shared_Solar_System__c);
                addToMap(newSubsMap, key, sub);
                
                if (sub.Id != null) {
                    newSubIds.add(sub.Id);
                }
            }
        }
        
        if (customerIds.isEmpty() || solarSystemIds.isEmpty()) {
            return;
        }
        
        Map<String, List<Subscription__c>> existingSubsMap = new Map<String, List<Subscription__c>>();
        for (Subscription__c existingSub : [
            SELECT Id, Customer__c, Shared_Solar_System__c, Start_Date__c, End_Date__c
            FROM Subscription__c
            WHERE Customer__c IN :customerIds
            AND Shared_Solar_System__c IN :solarSystemIds
            AND Id NOT IN :newSubIds
        ]) {
            String key = buildKey(existingSub.Customer__c, existingSub.Shared_Solar_System__c);
            addToMap(existingSubsMap, key, existingSub);
        }
        
        for (String key : newSubsMap.keySet()) {
            List<Subscription__c> newSubsList = newSubsMap.get(key);
            List<Subscription__c> existingSubsList = existingSubsMap.get(key);
            
            for (Subscription__c newSub : newSubsList) {
                Date newStart = newSub.Start_Date__c;
                Date newEnd = newSub.End_Date__c;
                
                if (existingSubsList != null) {
                    for (Subscription__c existSub : existingSubsList) {
                        Date existStart = existSub.Start_Date__c;
                        Date existEnd = existSub.End_Date__c;
                        
                        if (existStart == null || existEnd == null) continue;
                        
                        if (newStart <= existEnd && newEnd >= existStart) {
                            newSub.addError('Subscription dates overlap with an existing Subscription (Id: ' + existSub.Id + ').');
                            break;
                        }
                    }
                }
            }
        }
    }
    
    private static String buildKey(Id customerId, Id solarSystemId) {
        return customerId + '_' + solarSystemId;
    }
    
    private static void addToMap(Map<String, List<Subscription__c>> mp, String key, Subscription__c sub) {
        if (!mp.containsKey(key)) {
            mp.put(key, new List<Subscription__c>{sub});
        } else {
            mp.get(key).add(sub);
        }
    }
    
    public static void updateSubscriptionStatus(List<Subscription__c> newSubs, Map<Id, Subscription__c> oldMap){
        
        Date today = Date.today();
        String expectedStatus;
        
        for(Subscription__c sub : newSubs){
            
            if(oldMap == null || sub.Start_Date__c != oldMap.get(sub.Id).Start_Date__c || sub.End_Date__c != oldMap.get(sub.Id).End_Date__c){
                
                expectedStatus = (today >= sub.Start_Date__c && today <= sub.End_Date__c) ? 'Active' : 'Inactive';
                
                if(sub.Status__c!=expectedStatus){
                    
                    sub.Status__c = expectedStatus;
                }
            }
        }
    }
}

/*
OR (ISBLANK(Start_Date__c),
ISBLANK(End_Date__c),
Start_Date__c > End_Date__c)

throw validation error in validation rule.
*/
