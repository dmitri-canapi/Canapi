global  without sharing class TeamManagementController {
    @AuraEnabled
    global static List<User> getUsers(){
        if (TeamManagementController.getCommunityAccId() != null){
            String accId = TeamManagementController.getCommunityAccId();
            return [Select Id, Name,Title, Phone, Email, Account_Id__c, fullphotourl from User where Account_Id__c =: accId and IsActive = true]; 
        }
        return [Select Id, Name,Title, Phone, Email, Account_Id__c, fullphotourl from User where Account_Id__c != null and CreatedById = : UserInfo.getUserId() and IsActive = true]; 
    }
    
     global static string getCommunityAccId(){
		return [select id,Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
     }
    
    private Static String createContact(User u, String accountId){

        Contact cont = new Contact();
        cont.FirstName = u.FirstName;
        cont.LastName = u.LastName;
        cont.Email = u.Email;
        cont.Phone = u.Phone;
        cont.MobilePhone = u.MobilePhone;
        cont.AccountId = accountId;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(cont, dml);
        return sr.id;
        
    }
    
    @AuraEnabled
     public static void saveRecordContr(String UserRec){
         User u;
         try{
             UserRec=UserRec.replace('[','').replaceAll(']','');
             u = (User)JSON.deserialize(UserRec, User.class);
             
             Id ContactId = createContact(u,TeamManagementController.getCommunityAccId());
             if(Site.getSiteId()!=null){
             	u.ContactId = ContactId;
             }
             u.Username = u.Email + '.all';
             DateTime currentTime = System.now(); 
             Long timeInMili = currentTime.getTime()/1000;
             u.CommunityNickname = u.LastName + timeInMili;
             u.Alias = 'all' + u.LastName.codePointAt(0);
             u.TimeZoneSidKey = '' + UserInfo.getTimeZone();
             u.LocaleSidKey = UserInfo.getLocale(); // Required
             u.EmailEncodingKey = 'ISO-8859-1'; // Required
             u.LanguageLocaleKey = UserInfo.getLanguage(); // Required
             u.ProfileId = UserInfo.getProfileId();
             Database.DMLOptions dlo = new Database.DMLOptions();
             dlo.EmailHeader.triggerUserEmail= true;
             u.setOptions(dlo);
             insert u;
           
         } catch(exception e){ 
              if(e.getDmlType(0) == StatusCode.DUPLICATE_USERNAME || e.getDmlType(0) == StatusCode.DUPLICATE_COMM_NICKNAME){
                    
                    throw new AuraHandledException('A User With This Email Address Already Exists');
              }else if(e.getDmlType(0) == StatusCode.INVALID_EMAIL_ADDRESS){
                    throw new AuraHandledException('"'+u.Email+'" is not a valid email address');
              }else{
                  throw new AuraHandledException(e.getMessage());
              }
         }
     }
}