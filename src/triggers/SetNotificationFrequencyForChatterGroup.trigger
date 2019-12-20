trigger SetNotificationFrequencyForChatterGroup on CollaborationGroupMember (before insert, before update) {
    Map <Id, CollaborationGroupMember> groupToFreq = new Map <Id, CollaborationGroupMember>();

    for (CollaborationGroupMember cgm: [select NotificationFrequency, CollaborationGroupId, CollaborationGroup.OwnerId, MemberId from CollaborationGroupMember where CollaborationRole = 'Admin']){
        if (cgm.CollaborationGroup.OwnerId == cgm.MemberId){
            groupToFreq.put(cgm.CollaborationGroupId, cgm);
        }
    }
    
    if (Trigger.isInsert) {
        for (CollaborationGroupMember cgm : Trigger.new) {
            if(groupToFreq.ContainsKey(cgm.CollaborationGroupId)){
                cgm.NotificationFrequency = groupToFreq.get(cgm.CollaborationGroupId).NotificationFrequency;
            } else {
                cgm.NotificationFrequency = 'D';
            }
        }
    }

    if (Trigger.isUpdate) {
        Map <Id,String> groupToFreq2 = new Map <Id,String>();
        for (CollaborationGroupMember cgm : Trigger.new) {
            if (groupToFreq.ContainsKey(cgm.CollaborationGroupId) && groupToFreq.get(cgm.CollaborationGroupId).MemberId == cgm.MemberId){
                groupToFreq2.put(cgm.CollaborationGroupId, cgm.NotificationFrequency);
            }
        }
        List <CollaborationGroupMember> updList = [select id,CollaborationGroupId,MemberId, CollaborationGroup.OwnerId from CollaborationGroupMember where 
                                CollaborationGroupId in:groupToFreq2.keySet() and id not IN: Trigger.newMap.KeySet()];
        for (CollaborationGroupMember cgm: updList){
            cgm.NotificationFrequency = groupToFreq2.get(cgm.CollaborationGroupId);
        }
        update updList;
    }

}