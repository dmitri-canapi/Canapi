trigger AddCommunityUserToPublicGroup on User (after insert, after update) {
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
    
    if (Trigger.IsInsert){
        List <id> userIds = new List <id>();
        ID canapiConnectProfileId = [select id,name from Profile where name ='Community: Alliance Portal' limit 1].Id;
        for(User u:Trigger.new) {
            if (u.ProfileId == canapiConnectProfileId){
                userIds.add(u.Id);
            }
        }
        AddCommunityUserToPublicGroupHandler.subscribe(userIds);
    }

    List <id> userIds = new List <id>();
    for(User u:Trigger.new) {
        if (u.ContactId != null){
            userIds.add(u.Id);
        }
    }
     AddCommunityUserToPublicGroupHandler.updateContacts(userIds);
    
}