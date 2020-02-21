trigger JoinCommunityGroup on Contact (after update) {
	
    CollaborationGroup AllianceLeads = [select Id from CollaborationGroup Where Name = 'Alliance Leads' limit 1];
    
    List<CollaborationGroupMember> listGroupMemberToInsert = new List<CollaborationGroupMember>(); 
    List<CollaborationGroupMember> listGroupMemberToDelete = new List<CollaborationGroupMember>(); 
    Set <Id> contactsToInsert = new Set <Id>();
    Set <Id> contactsToDelete = new Set <Id>();
    List <Id> allConts = new List <Id>();
    
    for(Contact c:Trigger.new) {
        if(Trigger.oldMap.get(c.Id).FTA__c != c.FTA__c)
        if (c.FTA__c){ 
           contactsToInsert.add(c.id);
        } else {
            contactsToDelete.add(c.id);
        }
        allConts.add(c.Id);
    }
    if (!System.isFuture()){
        AddCommunityUserToPublicGroupHandler.updateUsers(allConts);
    }

    for (User u: [select id from User where IsActive = true and ContactId in: contactsToInsert and profile.name = 'Community: Alliance Portal']){
        CollaborationGroupMember gm = new CollaborationGroupMember();
        gm.collaborationGroupId = AllianceLeads.Id;
        gm.memberId = u.Id;
        gm.NotificationFrequency = 'D';
        listGroupMemberToInsert.add(gm);
    }
    
    Set <Id> gmToDelUsersIds = new Set <Id>();
    for (User u: [select id from User where IsActive = true and ContactId in: contactsToDelete]){
        gmToDelUsersIds.add(u.Id);
    }
    listGroupMemberToDelete = [select id from CollaborationGroupMember where memberId in: gmToDelUsersIds and collaborationGroupId=:AllianceLeads.Id];
    
    try{
        insert listGroupMemberToInsert;
    } catch(exception e){}
    
    try{
        delete listGroupMemberToDelete;
    } catch(exception e){}

}