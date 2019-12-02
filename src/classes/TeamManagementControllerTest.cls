@isTest public class TeamManagementControllerTest {
    static testMethod void testMethod1() {
        User u = new User(LastName='test', email='test@test.com');
        account a = new account (name='Canapi');
        insert a;
		TeamManagementController.saveRecordContr (JSON.serialize(u));
        
        TeamManagementController.getUsers();
    }
}