global class AddCommunityUserToPublicGroupScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ID netwkId = [select id from network where name = 'Canapi Connect' limit 1].Id;
        CollaborationGroup AllianceLeads = [select Id from CollaborationGroup Where Name = 'Alliance Leads' limit 1];

        List<CollaborationGroupMember> listGroupMember = new List<CollaborationGroupMember>(); 
        List<EntitySubscription> listEntitySubscription = new List<EntitySubscription>();

        Set <String> whiteList = new Set <String>();
        for (Auto_Enroll_Chatter_Groups__mdt wlItem: [select GroupId__c from Auto_Enroll_Chatter_Groups__mdt]){
            whiteList.add(wlItem.GroupId__c);
        }
        List <CollaborationGroup> cgroups = [select Id, Name, NetworkId from CollaborationGroup where NetworkId =: netwkId  and ((CollaborationType = 'Public' and IsArchived = false and id in: whiteList) or (id =: AllianceLeads.Id and IsArchived = false)) ];

        Map<Id, User> userToSubscribe = new Map<Id,User> ([select id, Contact.Fta__c from User where NeedSubscribing__c = true]);

        Map <Id,Set<Id>> groupSubscriptions = new Map <Id,Set<Id>>();

        for (CollaborationGroup cg: cgroups){
            groupSubscriptions.put(cg.Id, new Set <id>());
        }
        for (CollaborationGroupMember cgm: [select MemberId, CollaborationGroupId from CollaborationGroupMember where MemberId in: userToSubscribe.keySet() and CollaborationGroupId in: groupSubscriptions.keySet()]){
            Set<Id> temp = groupSubscriptions.get(cgm.CollaborationGroupId);
            temp.add(cgm.MemberId);
            groupSubscriptions.put(cgm.CollaborationGroupId, temp);
        }


        for (Id uId: userToSubscribe.keySet()){
            for ( CollaborationGroup cg: cgroups){
                if(!groupSubscriptions.get(cg.Id).contains(uId)){
                    CollaborationGroupMember gm = new CollaborationGroupMember(); 
                    gm.CollaborationGroupId = cg.id;
                    gm.MemberId = uId;
                    gm.NotificationFrequency = cg.Name == 'Canapi News & Announcements' ? 'P' : 'D';
                    if (cg.Name != 'Alliance Leads' || (cg.Name == 'Alliance Leads' && userToSubscribe.get(uId).Contact.Fta__c == true)){
                        listGroupMember.add(gm);
                    }
                }
            }
        }
        
        try{
            insert listGroupMember;
        } catch(exception e){
            system.debug(e);
        }

        AddCommunityUserToPublicGroupHandler.finishSubscribing();
    }
}