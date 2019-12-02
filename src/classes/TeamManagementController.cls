public  without sharing class TeamManagementController {
    @AuraEnabled
    public static UsersData getUsers(){
        List <User> users = new List <User>();
        List <contact> contacts = new List <contact>();
        //if (TeamManagementController.getCommunityAccId() != null){
            String accId = TeamManagementController.getCommunityAccId();
            users = [Select Id, Name,Title, Phone, Email, Account_Id__c, fullphotourl from User where Account_Id__c =: accId and IsActive = true]; 
            contacts = [Select id, Name, FirstName, LastName, Title, Phone, Email, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c from Contact where Account.Id =: accId and id not in (select  ContactID from User) order by name asc limit 100];
        /*} else {
            ID canapiAccId = [select id from Account where name = 'Canapi' limit 1].Id;
            users = [Select Id, Name,Title, Phone, Email, Account_Id__c, fullphotourl from User where Account_Id__c =: canapiAccId and IsActive = true]; 
            contacts = [Select id, Name, FirstName, LastName, Title, Phone, Email, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c from Contact where Account.Id =: canapiAccId and id not in (select  ContactID from User) order by name asc limit 100];
        }*/
                
        return new UsersData(users, contacts);
    }
    
     public static string getCommunityAccId(){
         String accId = [select id,Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
         if (accId == null)
          accId = [select id from Account where name = 'Canapi' limit 1].Id;
		return accId;
     }
    
    private Static String createContact(User u, String accountId){

        Contact cont = new Contact();
        try{
            cont = [select id, AccountId from contact where (id =: u.ContactId or (FirstName =: u.FirstName and LastName =: u.LastName) ) limit 1];
        } catch (exception e){

        }
        cont.FirstName = u.FirstName;
        cont.LastName = u.LastName;
        cont.Email = u.Email;
        cont.Phone = u.Phone;
        cont.MobilePhone = u.MobilePhone;
        cont.Title = u.Title;
        cont.AccountId = cont.Id == null ?  accountId : cont.AccountId;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true; 
        if (cont.Id == null){
            Database.SaveResult sr = Database.insert(cont, dml);
            return sr.id;
        } else {
            update cont;
            return cont.Id;
        }
        
    }
    
    @AuraEnabled
     public static void saveRecordContr(String UserRec){
         User u;
         try{
             UserRec=UserRec.replace('[','').replaceAll(']','');
             u = (User)JSON.deserialize(UserRec, User.class);
             
             List <User> dupUsers = [select id from User where LastName =: u.LastName and FirstName =: u.FirstName and ContactId != null];
             if (dupUsers.size() > 0){
                 throw new MyException ('Contact ' + u.FirstName + ' ' + u.LastName + ' is already a Portal User. Please contact support if they\'re having trouble logging in');
             } else {
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
             }
           
         } catch(exception e){ 
             throw new AuraHandledException(e.getMessage());
              /*if(e.getDmlType(0) == StatusCode.DUPLICATE_USERNAME || e.getDmlType(0) == StatusCode.DUPLICATE_COMM_NICKNAME){
                    
                    throw new AuraHandledException('A User With This Email Address Already Exists');
              }else if(e.getDmlType(0) == StatusCode.INVALID_EMAIL_ADDRESS){
                    throw new AuraHandledException('"'+u.Email+'" is not a valid email address');
              }else{
                  //throw new AuraHandledException(e.getMessage());
              }*/
         }
     }

    public class UsersData {
    @AuraEnabled public List <User> users { get; set;}
    @AuraEnabled public List <Contact> contacts { get; set;}
        public UsersData (List <User> users, List <Contact> contacts){
            this.users = users;
            this.contacts = contacts;
        }
    }   

    public class MyException extends Exception {}
}