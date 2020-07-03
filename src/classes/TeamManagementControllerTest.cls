@isTest public class TeamManagementControllerTest {
    static testMethod void testMethod1() {
        CollaborationGroup cg = new CollaborationGroup(Name = 'Alliance Leads', CollaborationType='Public');
        insert cg;
        User u = new User(LastName='test123', FirstName='alliancetest', email='test-all@test.com');
        account a = new account (name='Canapi');
        insert a;

        Portal_User_Suffix__mdt pref = new Portal_User_Suffix__mdt(DeveloperName = 'test', MasterLabel = 'test');
		TeamManagementController.saveRecordContr (JSON.serialize(u), 'Invite to Portal', null);
        
        TeamManagementController.getUsers(null);
        TeamManagementController contr = new TeamManagementController();
        contr.getData();
        contr.dummyMethod();
        
        TeamManagementController.createNewUser('test4545', 'test565656', 'test87878', 'test2-alliance@test.com', null);

        TeamManagementController.getTags();

        contact c = new contact(LastName='test2',AccountId = a.Id);
        insert c;


        TeamManagementController.updateRecord(c.Id, 'name', 'test3');
        TeamManagementController.updateRecord(UserInfo.getUserId(), 'phone', '555555');

        TeamManagementController.fetchLookUpValues('test','Contact','FirstName', a.Id);
        TeamManagementController.fetchLookUpValues('test','Contact','Title', a.Id);

        UserContactTag__c tag = new UserContactTag__c(name = 'test');
        insert tag;

        TeamManagementController.applyTag(UserInfo.getUserId(), tag.Id);
        TeamManagementController.applyTag(c.Id, tag.Id);
        TeamManagementController.getContact(c.Id);

        

        TeamManagementController.sendIntro(c.Id);
        TeamManagementController.sendRemind(UserInfo.getUserId());

        

        TeamManagementController.getGridData(a.Id,'test3');
        TeamManagementController.removeTagAssociation([select id from UserContactTagAssociation__c limit 1].Id);
        TeamManagementController.deleteSFobject(c.Id);
        
    }
}