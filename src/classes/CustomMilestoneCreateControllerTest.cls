@isTest
public class CustomMilestoneCreateControllerTest {
    static testMethod void testMethod1() {
        string s = CustomMilestoneCreateController.getAccountId();
        Account a = new Account (name='test');
        insert a;
        milestone__c ms = new milestone__c();
        ms.name='test';
        ms.Company__c=a.id;
        s = CustomMilestoneCreateController.saveRecordContr (JSON.serialize(ms));
	}
}