global class UpdateSubscriptionStatusBatchScheduler implements Database.Batchable<SObject>, Database.Stateful, Schedulable{

    List<App_Log__c> failedLogs = new List<App_Log__c>();

    global void execute(SchedulableContext sc){

        Database.executeBatch(this, 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Start_Date__c, End_Date__c, Status__c
            FROM Subscription__c
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Subscription__c> scope) {

        List<Subscription__c> subscriptionsToBeUpdated = new List<Subscription__c>();
        Date today = Date.today();
        String expectedStatus;

        for (Subscription__c sub : scope) {
            
            String expectedStatus = (today >= sub.Start_Date__c && today <= sub.End_Date__c) ? 'Active' : 'Inactive';

            if(sub.Status__c!=expectedStatus){

                sub.Status__c = expectedStatus;
                subscriptionsToBeUpdated.add(sub);
            }

        }

        if (!subscriptionsToBeUpdated.isEmpty()) {
            Database.SaveResult[] results = Database.update(subscriptionsToBeUpdated, false);

            Integer idx = 0;

            for (Database.SaveResult result : results) {

                if (!result.isSuccess()) {
                    String errorMsg = result.getErrors().isEmpty() ? 'Unknown error' : result.getErrors()[0].getMessage();
                    String stackTrace = result.getErrors().isEmpty() ? '' : result.getErrors()[0].getStackTraceString();

                    failedLogs.add(new App_Log__c(
                        Name = 'Subscription Status Update Failed',
                        Subscription__c = subscriptionsToBeUpdated[idx].Id,
                        Message__c = errorMsg,
                        Stack_Trace__c = stackTrace,
                        Timestamp__c = System.now()
                    ));
                }

                idx++;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

        if (!failedLogs.isEmpty()) {
            insert failedLogs;
        }
    }
}
