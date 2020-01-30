global  without sharing class TeamManagementController {
    @AuraEnabled
    public static UsersData getUsers(String recordId){
        List <User> users = new List <User>();
        List <contact> contacts = new List <contact>();
        //if (TeamManagementController.getCommunityAccId() != null){
            String accId = recordId != null ? recordId :TeamManagementController.getCommunityAccId();
            users = [Select Id, Name,Title, Phone, Email, Account_Id__c, fullphotourl, LastLoginDate from User where Account_Id__c =: accId and IsActive = true]; 
            contacts = [Select id, Name, FirstName, LastName, Title, Phone, Email, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c from Contact where Account.Id =: accId and id not in (select  ContactID from User) order by name asc limit 100];
        /*} else {
            ID canapiAccId = [select id from Account where name = 'Canapi' limit 1].Id;
            users = [Select Id, Name,Title, Phone, Email, Account_Id__c, fullphotourl from User where Account_Id__c =: canapiAccId and IsActive = true]; 
            contacts = [Select id, Name, FirstName, LastName, Title, Phone, Email, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c from Contact where Account.Id =: canapiAccId and id not in (select  ContactID from User) order by name asc limit 100];
        }*/
                
        return new UsersData(users, contacts);
    }

    public void dummyMethod(){}
    public UsersData getData(){
        String recordId = apexpages.currentpage().getparameters().get('recordId');
        String order = apexpages.currentpage().getparameters().get('order') != null ? apexpages.currentpage().getparameters().get('order') :'Name';
        String filter = apexpages.currentpage().getparameters().get('filterWord');
        system.debug(order);
        system.debug(filter);

        List <User> users = new List <User>();
        List <contact> contacts = new List <contact>();
        String accId = recordId != null ? recordId :TeamManagementController.getCommunityAccId();
        String q ='Select Id, Name,Title, Phone, Email, Account_Id__c, fullphotourl, LastLoginDate, (Select id, UserContactTag__r.Name from UserContactTagAssociations__r order by UserContactTag__r.Name) from User where Account_Id__c =: accId and IsActive = true ';
        if (filter != null && filter != '') q += 'and ' + order + ' like \'%' + filter + '%\'';
        q+= ' order by ' + order + ' asc nulls last';
        users = Database.query(q);
        //users = [Select Id, Name,Title, Phone, Email, Account_Id__c, fullphotourl, LastLoginDate, (Select id, UserContactTag__r.Name from UserContactTagAssociations__r order by UserContactTag__r.Name) from User where Account_Id__c =: accId and IsActive = true]; 
        
        q ='Select id, Name, FirstName, LastName, Title, Phone, Email, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c, (Select id, UserContactTag__r.Name from UserContactTagAssociations__r order by UserContactTag__r.Name) from Contact where Account.Id =: accId and id not in (select  ContactID from User) ';
        if (filter != null && filter != '') q += 'and ' + order + ' like \'%' + filter + '%\'';
        q+= ' order by ' + order + ' asc nulls last limit 100';
        contacts = Database.query(q);
        //contacts = [Select id, Name, FirstName, LastName, Title, Phone, Email, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c, (Select id, UserContactTag__r.Name from UserContactTagAssociations__r order by UserContactTag__r.Name) from Contact where Account.Id =: accId and id not in (select  ContactID from User) order by name asc limit 100];
            
        return new UsersData(users, contacts);
    }

    @RemoteAction
    global static String getGridData(String recordId, String filter){
        List <User> users = new List <User>();
        List <contact> contacts = new List <contact>();
        String accId = recordId != '' ? recordId :TeamManagementController.getCommunityAccId();
        String q ='Select Id, FirstName, LastName,Title, Phone, Email, Account_Id__c, fullphotourl, LastLoginDate, (Select id, UserContactTag__r.Name from UserContactTagAssociations__r order by UserContactTag__r.Name) from User where Account_Id__c =: accId and IsActive = true ';
        if (filter != null && filter != '') q += 'and ( Name like \'%' + filter + '%\')';
        q+= ' order by Name asc nulls last';
        users = Database.query(q);
       
        q ='Select id, FirstName, LastName, Title, Phone, Email, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c, (Select id, UserContactTag__r.Name from UserContactTagAssociations__r order by UserContactTag__r.Name) from Contact where Account.Id =: accId and id not in (select  ContactID from User) ';
        if (filter != null && filter != '') q += 'and ( Name like \'%' + filter + '%\')';
        q+= ' order by Name asc nulls last limit 100';
        contacts = Database.query(q);

        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['

        for (User u: users){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', u.Id);
            List<String> strlist = new List<String>();
            if (u.FirstName != null){
                String link = 'javascript:navigateTo("' + u.Id + '")^_self';
                strlist.add( u.FirstName  + '^' + link );
            } else {
                strlist.add('');
            }
            String link = 'javascript:navigateTo("' + u.Id + '")^_self';
            strlist.add( u.LastName  + '^' + link );
            strlist.add(u.Title);
            strlist.add(string.valueOfGmt(u.LastLoginDate));
            strlist.add('Portal User');
            strlist.add('');
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
            
        return generator.getAsString();

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
     public static void saveRecordContr(String UserRec, String InviteType, String recordId){
         User u;
         try{
            UserRec=UserRec.replace('[','').replaceAll(']','');
            u = (User)JSON.deserialize(UserRec, User.class);
            recordId = recordId != null ? recordId :TeamManagementController.getCommunityAccId();

             
            List <User> dupUsers = [select id from User where LastName =: u.LastName and FirstName =: u.FirstName and Account_Id__c =: recordId];
            List <Contact> dupContacts = [select id from Contact where LastName =: u.LastName and FirstName =: u.FirstName and AccountId =: recordId];

            if (dupUsers.size() > 0 && InviteType == 'Invite to Portal'){
                throw new MyException ('Contact ' + u.FirstName + ' ' + u.LastName + ' is already a Portal User. Please contact support if they\'re having trouble logging in');
            } else if ((dupContacts.size() > 0 || dupUsers.size() > 0) && InviteType == 'New Contact'){
                throw new MyException ('Unable to create contact. Contact ' + u.FirstName + ' ' + u.LastName + ' already exists.');
            } else {

                Id ContactId = createContact(u, recordId); 
                if(/*Site.getSiteId()!=null &&*/ u.ContactId == null){
                    
                    u.ContactId = ContactId;
                    system.debug(ContactId);
                } 
                
                DateTime currentTime = System.now(); 
                Long timeInMili = currentTime.getTime()/1000;
                u.Username = u.Email + '.all' + timeInMili;
                u.CommunityNickname = u.LastName + timeInMili;
                u.Alias = 'all' + u.LastName.codePointAt(0);
                u.TimeZoneSidKey = '' + UserInfo.getTimeZone();
                u.LocaleSidKey = UserInfo.getLocale(); // Required
                u.EmailEncodingKey = 'ISO-8859-1'; // Required
                u.LanguageLocaleKey = UserInfo.getLanguage(); // Required
                u.ProfileId = [select id,name from Profile where name ='Community: Alliance Portal' limit 1].Id;//UserInfo.getProfileId();
                Database.DMLOptions dlo = new Database.DMLOptions();
                dlo.EmailHeader.triggerUserEmail= true;
                u.setOptions(dlo);
                if (InviteType == 'Invite to Portal' /*|| InviteType == 'New Contact'*/) {
                    TeamManagementController.sendIntro(u.ContactId);
                    insert u;
                }

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

    @RemoteAction
    global static void createNewUser(String contName, String title, String phone, String email, String recordId){
        User u = new User();
         try{
            List <String> unames = contName.split(' ');
            
            u.LastName = unames.size() == 2 ? unames[1] : unames[0];
            u.FirstName = unames.size() == 2 ? unames[0] : '';
            u.Email = email;
            u.Phone = phone;
            u.Title = title;

            recordId = (recordId != null && recordId != '') ? recordId :TeamManagementController.getCommunityAccId();
            List <User> dupUsers = [select id from User where LastName =: u.LastName and FirstName =: u.FirstName and Account_Id__c =: recordId];
            List <Contact> dupContacts = [select id from Contact where LastName =: u.LastName and FirstName =: u.FirstName and AccountId =: recordId];
            if (dupUsers.size() > 0 || dupContacts.size() > 0){
                throw new MyException ('Unable to create contact. Contact ' + u.FirstName + ' ' + u.LastName + ' already exists.');
            } else {
             Id ContactId = createContact(u, recordId);
             //if(Site.getSiteId()!=null){
             	u.ContactId = ContactId;
             //}
             
             /*DateTime currentTime = System.now(); 
             Long timeInMili = currentTime.getTime()/1000;
             u.CommunityNickname = u.LastName + timeInMili;
             u.Username = u.Email + '.all' + timeInMili;
             u.Alias = 'all' + u.LastName.codePointAt(0);
             u.TimeZoneSidKey = '' + UserInfo.getTimeZone();
             u.LocaleSidKey = UserInfo.getLocale(); // Required
             u.EmailEncodingKey = 'ISO-8859-1'; // Required
             u.LanguageLocaleKey = UserInfo.getLanguage(); // Required
             u.ProfileId = [select id,name from Profile where name ='Community: Alliance Portal' limit 1].Id;//UserInfo.getProfileId();
             Database.DMLOptions dlo = new Database.DMLOptions();
             dlo.EmailHeader.triggerUserEmail= true;
             u.setOptions(dlo);
             insert u;*/
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

    @AuraEnabled
    public static void resetPass(String UserId){
        System.resetPassword(UserId,true);
    }

    @RemoteAction
    global static void deleteSFobject(String objId){
        if (Id.valueOf(objId).getSObjectType().getDescribe().getName() == 'Contact') {
            Contact c = new Contact (id = objId);
            delete c;
        } else {
            User u = [select id, ContactId from User where id =: objId];
            u.IsActive = false;
            u.IsPortalEnabled = false;
            update u;

            deleteContact(u.ContactId);
        }
    }

    @future
    private static void deleteContact (String cId){
        Contact c = new Contact (id = cId);
        delete c;
    }

    @RemoteAction
    global static List <UserContactTag__c> getTags (){
        return [select id, name, Function__c from UserContactTag__c  order by Function__c desc, Hierarchy_Level__c asc, name asc];
    }

    @RemoteAction
    global static void updateRecord (String recId, String field, String val){
        sObject obj;
        if (Id.valueOf(recId).getSObjectType().getDescribe().getName() == 'Contact') {
            Contact c = new Contact(id = recId);
            obj = c;
        } else {
            User u = new User(id = recId);
            obj = u;
        }
        //obj.put('Id', recId);

        if (field == 'name'){
            List <String> unames = val.split(' ');
            String LastName = unames.size() == 2 ? unames[1] : unames[0];
            String FirstName = unames.size() == 2 ? unames[0] : '';
            obj.put('LastName', LastName);
            obj.put('FirstName', FirstName);
        } else {
            obj.put(field, val);
        }
        update obj;

    }

    @RemoteAction
    global static List <UserContactTagAssociation__c> applyTag (String targetId, String TagId){ 
        List <UserContactTagAssociation__c> retTags = new List <UserContactTagAssociation__c>();

        if ([select id from UserContactTagAssociation__c where (Contact__c =: targetId  or User__c =: targetId) and UserContactTag__c =: TagId].size()==0){
            UserContactTagAssociation__c tagAssoc = new UserContactTagAssociation__c();
            tagAssoc.UserContactTag__c = TagId;
            if (Id.valueOf(targetId).getSObjectType().getDescribe().getName() == 'Contact') {
                tagAssoc.Contact__c = targetId;
            } else {
                tagAssoc.User__c = targetId;
                tagAssoc.Contact__c = [select ContactId from User where id =: targetId].ContactId;
            }
            insert tagAssoc;
        }
        retTags = [select id, UserContactTag__r.Name from UserContactTagAssociation__c where Contact__c =: targetId  or User__c =: targetId order by UserContactTag__r.Name];
        return retTags;
    }

    @RemoteAction
    global static void removeTagAssociation (String tagAssocId){ 
        delete [select id from UserContactTagAssociation__c where id =: tagAssocId];
    }

    @RemoteAction
    global static void sendIntro (String contactId){ 
        EmailTemplate et = [SELECT Id,Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'IntroEmailForContact'];
        String cName = [select FirstName from Contact where id=:contactId].FirstName;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        //mail.setToAddresses(toAddress);
        mail.setSubject(et.subject);
        mail.setHTMLBody(et.HtmlValue.replace('{!Contact.FirstName}', cName != null ? cName : '')); //setTargetObjectId and setWhatId can't be equal :(
        mail.setTargetObjectId(contactId);
        mail.setWhatId(contactId);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        Messaging.sendEmail(allmsg,false);
    }

    @RemoteAction
    global static void sendRemind (String userId){ 
        EmailTemplate et = [SELECT Id,Subject, HtmlValue  FROM EmailTemplate WHERE DeveloperName = 'RemindEmailForUser'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setSubject(et.subject);
        mail.setHTMLBody(et.HtmlValue );
        mail.setTargetObjectId(userId);
        mail.setWhatId(userId);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        Messaging.sendEmail(allmsg,false);

        TeamManagementController.resetPass(userId);
    }

        
    public class UsersData {
    @AuraEnabled public List <User> users { get; set;}
    @AuraEnabled public List <Contact> contacts { get; set;}
    @AuraEnabled public boolean isCommunity { get; set;}
        public UsersData (List <User> users, List <Contact> contacts){
            this.users = users;
            this.contacts = contacts;
            this.isCommunity = Site.getSiteId() != null? true : false;            
        }
    }   

    public class MyException extends Exception {}
}