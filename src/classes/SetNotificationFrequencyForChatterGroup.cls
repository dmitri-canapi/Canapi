global without sharing class SetNotificationFrequencyForChatterGroup {
    @future
    public static void updateNotification(List<ID> groupIds) {
        Map <Id, CollaborationGroupMember> groupToFreq = new Map <Id, CollaborationGroupMember>();
        for (CollaborationGroupMember cgm: [select NotificationFrequency, CollaborationGroupId, CollaborationGroup.OwnerId, MemberId from CollaborationGroupMember where CollaborationRole = 'Admin' and CollaborationGroupId in:groupIds ]){
            if (cgm.CollaborationGroup.OwnerId == cgm.MemberId){
                groupToFreq.put(cgm.CollaborationGroupId, cgm);
            }
        }
        //List <CollaborationGroupMember> updList = new List <CollaborationGroupMember>();
        List <CollaborationGroupMember> updList = [select id,CollaborationGroupId,MemberId, CollaborationGroup.OwnerId from CollaborationGroupMember where 
                            CollaborationGroupId in:groupIds FOR UPDATE];
                            //

        for (CollaborationGroupMember cgm : updList) {
            //grIds.add(cgm.CollaborationGroupId);
            if(cgm.CollaborationGroup.OwnerId != cgm.MemberId){
                cgm.NotificationFrequency = groupToFreq.get(cgm.CollaborationGroupId).NotificationFrequency;
            }
            //updList.add(cgm);
        }

        update updList;


    }

    
    public static void updateNotificationNonFuture(List<ID> groupIds) {
        Map <Id, CollaborationGroupMember> groupToFreq = new Map <Id, CollaborationGroupMember>();
        for (CollaborationGroupMember cgm: [select NotificationFrequency, CollaborationGroupId, CollaborationGroup.OwnerId, MemberId from CollaborationGroupMember where CollaborationRole = 'Admin' and CollaborationGroupId in:groupIds ]){
            if (cgm.CollaborationGroup.OwnerId == cgm.MemberId){
                groupToFreq.put(cgm.CollaborationGroupId, cgm);
            }
        }
        //List <CollaborationGroupMember> updList = new List <CollaborationGroupMember>();
        List <CollaborationGroupMember> updList = [select id,CollaborationGroupId,MemberId, CollaborationGroup.OwnerId from CollaborationGroupMember where 
                            CollaborationGroupId in:groupIds FOR UPDATE];
                            //

        for (CollaborationGroupMember cgm : updList) {
            //grIds.add(cgm.CollaborationGroupId);
            if(cgm.CollaborationGroup.OwnerId != cgm.MemberId){
                cgm.NotificationFrequency = groupToFreq.get(cgm.CollaborationGroupId).NotificationFrequency;
            }
            //updList.add(cgm);
        }

        update updList;


    }
}