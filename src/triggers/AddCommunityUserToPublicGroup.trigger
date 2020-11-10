trigger AddCommunityUserToPublicGroup on User (before insert, after insert, after update) {
    if (Trigger.IsAfter){
        try{
        Group allianceGroup = [select Id from Group Where Name='Alliance Portal Users'];
        Group fintechGroup = [select Id from Group Where Name='Fintech Portal Users'];
        
        List<GroupMember> listGroupMember = new List<GroupMember>(); 
        
        for(User u:Trigger.new) {
            if ((u.ProfileId=='00e6A000000JXOi' || u.ProfileId=='00e6A000000vI1M' || u.ProfileId=='00e6A000000vI1MQAU') && u.IsActive){ //Alliance profile id
                GroupMember gm = new GroupMember(); 
                gm.GroupId = allianceGroup.id;
                gm.UserOrGroupId = u.id;
                listGroupMember.add(gm);   
            }
            if ((u.ProfileId=='00e6A000000JVnd' || u.ProfileId=='00e6A000000JXOi' || u.ProfileId=='00e6A000000JXOiQAO') && u.IsActive){ //Fintech profile id
                GroupMember gm = new GroupMember(); 
                gm.GroupId = fintechGroup.id;
                gm.UserOrGroupId = u.id;
                listGroupMember.add(gm);   
            }
        }
        if(listGroupMember.size() > 0)
            insert listGroupMember;
        
        } catch(exception e){}

        List <id> userIds = new List <id>();
        for(User u:Trigger.new) {
            if (u.ContactId != null){
                userIds.add(u.Id);
            }
        }
        if (!System.isFuture()){
            AddCommunityUserToPublicGroupHandler.updateContacts(userIds);
        }
        if (Trigger.IsInsert){
            AddCommunityUserToPublicGroupHandler.addToGroups(userIds);
        }

    
    }
    
    if (Trigger.IsInsert && Trigger.IsAfter){
        List <id> userIds = new List <id>();
        ID canapiConnectProfileId = [select id,name from Profile where name ='Community: Alliance Portal' limit 1].Id;
        List <id> intUsers = new List <id>();

        Map <id,id> contactUserMap = new Map <id,id>();


        for(User u:Trigger.new) {
            if (u.ProfileId == canapiConnectProfileId){
                userIds.add(u.Id);
                contactUserMap.put(u.contactId, u.id);
            }

            if (u.ContactId == null){ // set default sharing for internal users
                intUsers.add(u.Id);
            }
        }


        AddCommunityUserToPublicGroupHandler.insertDefSharings(intUsers);
        
        AddCommunityUserToPublicGroupHandler.subscribe(userIds);

        /*List <UserContactTagAssociation__c> uctaList = [select id,Contact__c from UserContactTagAssociation__c where Contact__c in: contactUserMap.keySet()];

        for(UserContactTagAssociation__c ucta: uctaList){
            ucta.User__c = contactUserMap.get(ucta.Contact__c);
        }
        update uctaList;*/

        

        
    }

    if (Trigger.IsInsert && Trigger.IsBefore){
        ID canapiConnectProfileId = [select id,name from Profile where name ='Community: Alliance Portal' limit 1].Id;
        for(User u:Trigger.new) {
            if (u.ProfileId == canapiConnectProfileId){
                u.NeedSubscribing__c = true;
            }
        }
    }

    
    
}