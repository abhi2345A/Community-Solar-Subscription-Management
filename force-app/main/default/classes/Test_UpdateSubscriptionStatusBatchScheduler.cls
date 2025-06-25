@isTest
private class Test_UpdateSubsStatusBatchScheduler {

    @testSetup
    static void setupData() {

        Date today = Date.today();

        Customer__c customer = new Customer__c(Name = 'Test Customer');
        insert customer;

        Shared_Solar_System__c solarSystem = new Shared_Solar_System__c(Name = 'Test Solar System');
        insert solarSystem;

        insert new List<Subscription__c>{
            new Subscription__c(
                Name = 'ToActivate',
                Customer__c = customer.Id,
                Shared_Solar_System__c = solarSystem.Id,
                Start_Date__c = today.addDays(-2),
                End_Date__c = today.addDays(2),
                Status__c = 'Inactive'
            ),
            new Subscription__c(
                Name = 'ToInactivate',
                Customer__c = customer.Id,
                Shared_Solar_System__c = solarSystem.Id,
                Start_Date__c = today.addDays(-10),
                End_Date__c = today.addDays(-1),
                Status__c = 'Active'
            )
        };
    }

    @isTest
    static void testScheduleExecution() {
        
        Test.startTest();
        String jobId = System.schedule('SubStatusJob', '0 0 0 * * ?', new UpdateSubscriptionStatusBatchScheduler());
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Scheduled job should return a job ID');
        
        
    }
    
    @isTest
    static void testBatchExecution() {
        
        Test.startTest();
        Database.executeBatch(new UpdateSubscriptionStatusBatchScheduler(), 200);
        Test.stopTest();
        
        for (Subscription__c sub :  [ SELECT Name, Status__c FROM Subscription__c]){
            if(sub.Name=='ToActivate') {
                System.assertEquals('Active', sub.Status__c, 'Should be Active');
            }else if(sub.Name=='ToInactivate'){
                System.assertEquals('Inactive', sub.Status__c, 'Should be Inactive');
            }
        }
    }
}
