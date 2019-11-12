@IsTest(SeeAllData=true)
public class JoinCommunityGroupTest {
	@IsTest
    private static void test() {
        User u = [SELECT Id, name, ContactId from user where (Profile.Id='00e6A000000JXOi' or Profile.Id='00e6A000000vI1M') and IsActive=true limit 1];
        Contact c = new Contact (id=u.ContactId);
        update c;
        
        c.FTA__c=true;
        update c;
        
    }
}