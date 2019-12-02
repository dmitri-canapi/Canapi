@isTest public class GetCompanyLogoTest {
	static testMethod void testMethod1() {
        
        test.starttest();
        account a = new account();
        a.name = 'test';
        //a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('prospect').getRecordTypeId();
        a.Organization_Name_URL__c = 'test.com';
        insert a;
        system.debug(a);
        GetCompanyLogoScheduler sch = new GetCompanyLogoScheduler ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, sch);
        test.stopTest();
        GetCompanyLogoBatch b = new GetCompanyLogoBatch(); 
        database.executebatch(b,10);
    }
}