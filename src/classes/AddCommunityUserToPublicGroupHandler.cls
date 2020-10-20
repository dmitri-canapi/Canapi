public class AddCommunityUserToPublicGroupHandler {
	@future
    public static void subscribe(List<Id> usersIds){
        ID netwkId = [select id from network where name = 'Canapi Connect' limit 1].Id;
        List<EntitySubscription> listEntitySubscription = new List<EntitySubscription>();

        List <Account> portfolios = [SELECT Id FROM Account where recordtype.name='Portfolio Company'];
        //List <User> userToUpdate = new List <User>();
        for (Id uId: usersIds){
            for (Account a: portfolios){
                EntitySubscription ES = new EntitySubscription();
                ES.ParentId = a.Id;
                ES.SubscriberId = uId;
                ES.NetworkId = netwkId;
                listEntitySubscription.add(ES);
            }
            //userToUpdate.add(New User(id = uId, NeedSubscribing__c = true));
        }
        insert listEntitySubscription;
        //system.debug(userToUpdate);
        //update userToUpdate;

        

    }

    @future
    public static void insertDefSharings(List<Id> usersIds){
        String canapiInternalGroup = [select id, name from group where name = 'Canapi Internal' limit 1].Id;
        List <Default_Sharing__c> defSharings = new List <Default_Sharing__c>();
        for (Id uId: usersIds){
            defSharings.add(new Default_Sharing__c(UserOrGroup__c = canapiInternalGroup, Access__c = 'Edit', CreatedBy__c = uId));
        }
        insert defSharings;

    }

    @future
    public static void updateUsers(List<Id> contactIds){
        List <User> users = [select id, ContactId, Phone, MobilePhone, Title, Email, FirstName, Lastname from User where ContactId in: contactIds];
        Map <Id, Contact> contactsMap = new Map <Id, Contact>([select id, Phone, MobilePhone, Title, Email, FirstName, Lastname from Contact where id in: contactIds]);
        for (User u: users){
            if (u.Phone != contactsMap.get(u.ContactId).Phone && contactsMap.get(u.ContactId).Phone != null){
                u.Phone = contactsMap.get(u.ContactId).Phone;
            }
            if (u.MobilePhone != contactsMap.get(u.ContactId).MobilePhone && contactsMap.get(u.ContactId).MobilePhone != null){
                u.MobilePhone = contactsMap.get(u.ContactId).MobilePhone;
            }
            if (u.Title != contactsMap.get(u.ContactId).Title && contactsMap.get(u.ContactId).Title != null){
                u.Title = contactsMap.get(u.ContactId).Title;
            }
            if (u.Email != contactsMap.get(u.ContactId).Email && contactsMap.get(u.ContactId).Email != null){
                u.Email = contactsMap.get(u.ContactId).Email;
            }
            if (u.FirstName != contactsMap.get(u.ContactId).FirstName && contactsMap.get(u.ContactId).FirstName != null){
                u.FirstName = contactsMap.get(u.ContactId).FirstName;
            }
            if (u.Lastname != contactsMap.get(u.ContactId).Lastname && contactsMap.get(u.ContactId).Lastname != null){
                u.Lastname = contactsMap.get(u.ContactId).Lastname;
            }
        }
        update users;
    }

    @future
    public static void finishSubscribing (){
        List <User> UsersToUpdate = [select id, Contact.Fta__c from User where NeedSubscribing__c = true];
        for (User u: UsersToUpdate){
            u.NeedSubscribing__c = false;
        }
        update UsersToUpdate;
    }

    @future
    public static void updateContacts(List<Id> usersIds){
        try{
            List <Contact> conts = new List <Contact> ();
            for (User u : [select Id, ContactId, FirstName, LastName, Title, Phone, Email from User where id in: usersIds]){
                Contact c = new Contact(FirstName = u.FirstName,
                LastName = u.LastName,
                Title = u.Title,
                Phone = u.Phone,
                Email = u.Email,
                Id = u.ContactId,
                Portal_User__c = u.Id);
                conts.add(c);
            }
            update conts;
        }catch(exception e){}
    }

    @future
    public static void addToGroups(List<Id> usersIds){
        try {
            Map <String, String> publGroups = new Map <String, String>();
            List<GroupMember> listGroupMember = new List<GroupMember>(); 

            for (Group gr: [select Id, Name from Group Where Name='Non-LP-Users' or name = 'Bank LP Users' or name = 'Individual LP Users' ]){
                publGroups.put(gr.Name, gr.Id);
            }

            for(User u: [select id, Account_RT_name__c from user where id in: usersIds and Profile.Name = 'Community: Alliance Portal']) {
                    GroupMember gm = new GroupMember(); 
                    gm.UserOrGroupId = u.id;
                    
                    if (u.Account_RT_name__c == 'Bank'){
                        gm.GroupId = publGroups.get('Bank LP Users');
                    } else if(u.Account_RT_name__c == 'Person Account' || u.Account_RT_name__c == 'LP (Individuals)' || u.Account_RT_name__c == 'Limited Partner'){
                        gm.GroupId = publGroups.get('Individual LP Users');
                    } else {
                        gm.GroupId = publGroups.get('Non-LP-Users');
                    }
                    listGroupMember.add(gm);
            }
            
            insert listGroupMember;
        } catch(exception e){}
    }
}