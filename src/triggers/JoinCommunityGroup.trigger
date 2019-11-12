trigger JoinCommunityGroup on Contact (after update) {
	/*
    CollaborationGroup FintechLeads = [select Id, name from CollaborationGroup Where Name='Fintech Leads' limit 1];
    
    List<CollaborationGroupMember > listGroupMemberToInsert = new List<CollaborationGroupMember >(); 
    List<CollaborationGroupMember > listGroupMemberToDelete = new List<CollaborationGroupMember >(); 
    Set <Id> contactsToInsert = new Set <Id>();
    Set <Id> contactsToDelete = new Set <Id>();
    
    for(Contact c:Trigger.new) {
        if (c.FTA__c){ //Alliance profile id
           contactsToInsert.add(c.id);
        } else {
            contactsToDelete.add(c.id);
        }
    }

    for (User u: [select id from User where IsActive = true and ContactId in: contactsToInsert]){
        CollaborationGroupMember gm = new CollaborationGroupMember();
        gm.collaborationGroupId=FintechLeads.Id;
        gm.memberId=u.Id;
        gm.NotificationFrequency='P';
        listGroupMemberToInsert.add(gm);
    }
    
    Set <Id> gmToDelUsersIds = new Set <Id>();
    for (User u: [select id from User where IsActive = true and ContactId in: contactsToDelete]){
        gmToDelUsersIds.add(u.Id);
    }
    listGroupMemberToDelete = [select id from CollaborationGroupMember where memberId in: gmToDelUsersIds and collaborationGroupId=:FintechLeads.Id];
    
    try{
        insert listGroupMemberToInsert;
    } catch(exception e){}
    
    try{
        delete listGroupMemberToDelete;
    } catch(exception e){}
*/
}