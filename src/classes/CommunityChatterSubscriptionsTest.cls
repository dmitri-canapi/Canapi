@isTest
private class CommunityChatterSubscriptionsTest {
	
	@isTest static void test_method_one() {
		//NEW FOR THE CONSTRUCTOR
    	CommunityChatterSubscriptionsController testInstance = new CommunityChatterSubscriptionsController();

    	//Call methods
    	CommunityChatterSubscriptionsController.GetCategories();
    	CommunityChatterSubscriptionsController.GetPeople();
    	CommunityChatterSubscriptionsController.GetGroups();
    	

    	//Insert user
    	User u = new User();
		u.Alias = 'teswet';
		u.Email = 'tesqewet@test.com';
		u.FirstName = 'firstname';
		u.LastName = 'lastname';
		u.Username = 'test@acme.com23432';
		u.CommunityNickname = 'tesqqwt';
		u.EmailEncodingKey = 'UTF-8';
		u.LanguageLocaleKey = 'en_US';
		u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/New_York';
        u.PortalRole = 'Executive';
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        u.ProfileId = p.Id;
    	insert U;

    	
        CommunityChatterSubscriptionsController.Subscribe(U.Id);
        CommunityChatterSubscriptionsController.Unsubscribe(U.Id);
    	CommunityChatterSubscriptionsController.GetGroupsByUser();
    	CommunityChatterSubscriptionsController.GetPeopleByUser();
	}//End test metod one
}//End test class