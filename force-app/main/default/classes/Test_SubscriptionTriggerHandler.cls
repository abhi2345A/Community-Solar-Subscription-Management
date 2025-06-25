@isTest
private class Test_SubscriptionTriggerHandler {
    
    private static Customer__c customer;
    private static Shared_Solar_System__c solarSystem;
    
    @testSetup
    static void setupData() {
        customer = new Customer__c(Name = 'Test Customer');
        insert customer;
        
        solarSystem = new Shared_Solar_System__c(Name = 'Test Solar System');
        insert solarSystem;
        
        // Insert existing subscription for overlap test
        Subscription__c existing = new Subscription__c(
            Name = 'Existing Sub',
            Customer__c = customer.Id,
            Shared_Solar_System__c = solarSystem.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(10),
            Status__c = 'Inactive'
        );
        insert existing;
    }
    
    @isTest
    static void testInsertNonOverlapping() {
        
        Customer__c customer = [Select Id from Customer__c limit 1];
        Shared_Solar_System__c solarSystem = [Select Id from Shared_Solar_System__c limit 1];
        Subscription__c newSub = new Subscription__c(
            Name = 'Non-Overlapping',
            Customer__c = customer.Id,
            Shared_Solar_System__c = solarSystem.Id,
            Start_Date__c = Date.today().addDays(11),
            End_Date__c = Date.today().addDays(20)
        );
        
        Test.startTest();
        insert newSub;
        Test.stopTest();
        
        Subscription__c subRetr = [Select Status__c FROM Subscription__c WHERE Id = :newSub.Id];
        System.assertEquals('Inactive', subRetr.Status__c);
    }
    
    @isTest
    static void testInsertOverlappingThrowsError() {
        
        Customer__c customer = [Select Id from Customer__c limit 1];
        Shared_Solar_System__c solarSystem = [Select Id from Shared_Solar_System__c limit 1];
        
        Subscription__c overlapping = new Subscription__c(
            Name = 'Overlapping',
            Customer__c = customer.Id,
            Shared_Solar_System__c = solarSystem.Id,
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(15)
        );
        
        Test.startTest();
        try {
            insert overlapping;
            System.assert(false, 'Expected overlap validation error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('overlap'), 'Should throw overlap error');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCausesOverlapThrowsError() {
        Customer__c customer = [SELECT Id FROM Customer__c LIMIT 1];
        Shared_Solar_System__c solarSystem = [SELECT Id FROM Shared_Solar_System__c LIMIT 1];
        
        Subscription__c subToUpdate = new Subscription__c(
            Name = 'ToUpdate',
            Customer__c = customer.Id,
            Shared_Solar_System__c = solarSystem.Id,
            Start_Date__c = Date.today().addDays(11),
            End_Date__c = Date.today().addDays(20)
        );
        insert subToUpdate;
        
        subToUpdate.Start_Date__c = Date.today().addDays(-2); 
        
        Test.startTest();
        try {
            update subToUpdate;
            System.assert(false, 'Expected overlap validation error during update');
        } catch (DmlException e) {
            System.debug('Caught expected error: ' + e.getMessage());
            System.assert(e.getMessage().toLowerCase().contains('overlap'), 'Should throw overlap error');
        }
        Test.stopTest();
    }
    
    
}
