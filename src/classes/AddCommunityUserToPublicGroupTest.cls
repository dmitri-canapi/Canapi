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
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(cont, dml);
        
        ID canapiConnectProfileId = [select id,name from Profile where name ='Community: Alliance Portal' limit 1].Id;
        
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
        
    }
}