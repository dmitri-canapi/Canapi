trigger AddCommunityUserToPublicGroup on User (after insert, after update) {
    try{
    Group allianceGroup = [select Id from Group Where Name='Alliance Portal Users'];
    Group fintechGroup = [select Id from Group Where Name='Fintech Portal Users'];
    
    List<GroupMember> listGroupMember = new List<GroupMember>(); 
    
    for(User u:Trigger.new) {
        if ((u.ProfileId=='00e6A000000JXOi' || u.ProfileId=='00e6A000000vI1M') && u.IsActive){ //Alliance profile id
            GroupMember gm = new GroupMember(); 
            gm.GroupId = allianceGroup.id;
            gm.UserOrGroupId = u.id;
            listGroupMember.add(gm);   
        }
        if ((u.ProfileId=='00e6A000000JVnd' || u.ProfileId=='00e6A000000JXOi') && u.IsActive){ //Fintech profile id
            GroupMember gm = new GroupMember(); 
            gm.GroupId = fintechGroup.id;
            gm.UserOrGroupId = u.id;
            listGroupMember.add(gm);   
        }
    }
    if(listGroupMember.size() > 0)
        insert listGroupMember;
    
    } catch(exception e){}
    
}