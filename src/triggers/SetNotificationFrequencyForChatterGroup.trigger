trigger SetNotificationFrequencyForChatterGroup on CollaborationGroupMember (before insert, after insert, before update) {
    Map <Id, CollaborationGroupMember> groupToFreq = new Map <Id, CollaborationGroupMember>();

    for (CollaborationGroupMember cgm: [select NotificationFrequency, CollaborationGroupId, CollaborationGroup.OwnerId, MemberId from CollaborationGroupMember where CollaborationRole = 'Admin']){
        if (cgm.CollaborationGroup.OwnerId == cgm.MemberId){
            groupToFreq.put(cgm.CollaborationGroupId, cgm);
        }
    }
    
    if (Trigger.isInsert) {
        if (Trigger.IsBefore) {
            for (CollaborationGroupMember cgm : Trigger.new) {
                if(!groupToFreq.ContainsKey(cgm.CollaborationGroupId)){
                    cgm.NotificationFrequency = 'D';
                }
            }
        }
        List <id> grIds = new List <id>();
        for (CollaborationGroupMember cgm : Trigger.new) {
            grIds.add(cgm.CollaborationGroupId);
        }
        if (!System.isFuture()){
            SetNotificationFrequencyForChatterGroup.updateNotification(grIds);
        } else {
            SetNotificationFrequencyForChatterGroup.updateNotificationNonFuture(grIds);
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