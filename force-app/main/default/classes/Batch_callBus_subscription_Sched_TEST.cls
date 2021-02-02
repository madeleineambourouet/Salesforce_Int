@isTest
public class Batch_callBus_subscription_Sched_TEST {
    static testmethod void testSchedulable() {        
        Test.startTest();
        Batch_callBus_subscription_Schedulable sh1 = new Batch_callBus_subscription_Schedulable();
		sh1.execute(null);
        Test.stopTest();
    }
}