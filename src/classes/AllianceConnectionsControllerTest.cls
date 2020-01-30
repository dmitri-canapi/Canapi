@isTest public class AllianceConnectionsControllerTest {
    static testMethod void testMethod1() {
        UserContactTag__c tag = new UserContactTag__c(Name = 'Test',Hierarchy_Level__c = 1);
        insert tag;
        UserContactTagAssociation__c ucta = new UserContactTagAssociation__c();
        ucta.User__c = UserInfo.getUserId();
        ucta.UserContactTag__c = tag.Id;
        insert ucta;
        AllianceConnectionsController.getContacts('test','Name');
    }
}