@isTest (SeeAllData=true)
public class AddCommunityUserToPublicGroupTest {
    @isTest
    public static void test() {
        user U1 = [select id from user where /*ProfileId='00e6A000000JXOi'*/ Profile.Name = 'Community: Alliance Portal' and IsActive=true limit 1];
        user U2 = [select id from user where /*ProfileId='00e6A000000vI1M'*/ Profile.Name = 'Community: Fintech Portal' and IsActive=true limit 1];
        update U1;
        update U2;
    }
    @isTest
    public static void test2() {
        User u = new User(LastName='test', email='test123@test.com');
        
        account a = new account(name = 'te1st2');
        insert a;
        
        Contact cont = new Contact();
        cont.LastName = u.LastName;
        cont.Email = u.Email;
        cont.AccountId = a.Id;
        cont.FTA__c = false;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(cont, dml);

        
        ID canapiConnectProfileId = [select id,name from Profile where name ='Community: Alliance Portal' limit 1].Id;

        Document__c doc = new Document__c (Name__c='test',Account__c=a.Id,Shared_with_Users_from_this_account__c=true);
        insert doc;
        
        u.ContactId = sr.id;
        u.Username = u.Email + '.all';
        DateTime currentTime = System.now(); 
        Long timeInMili = currentTime.getTime()/1000;
        u.CommunityNickname = u.LastName + timeInMili;
        u.Alias = 'all' + u.LastName.codePointAt(0);
        u.TimeZoneSidKey = '' + UserInfo.getTimeZone();
        u.LocaleSidKey = UserInfo.getLocale(); // Required
        u.EmailEncodingKey = 'ISO-8859-1'; // Required
        u.LanguageLocaleKey = UserInfo.getLanguage(); // Required
        u.ProfileId = canapiConnectProfileId;
        /*Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        u.setOptions(dlo);*/
        insert u;

        test.starttest();
        

        AddCommunityUserToPublicGroupScheduler sch = new AddCommunityUserToPublicGroupScheduler ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched' + String.valueOf(Datetime.now()), chron, sch);
        
        test.stopTest();

        cont.FTA__c = true;
        update cont;

        cont.FTA__c = false;
        update cont;
        
    }
}