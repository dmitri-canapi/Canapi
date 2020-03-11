public class CommunityPostToChatterController {
    
	 @AuraEnabled  
    public static List<picklistWrapper> getMyGroups() {
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        
		for (CollaborationGroupMember cg: [select id,collaborationGroupId,collaborationGroup.Name from CollaborationGroupMember where memberId=:UserInfo.getUserId() and collaborationGroup.IsBroadcast = false and collaborationGroup.IsArchived = false and collaborationGroup.NetworkId =: Network.getNetworkId()]) {
			picklistWrapper aa = new picklistWrapper();
			aa.pickListLabel = cg.collaborationGroup.Name;
			aa.pickListValue = cg.collaborationGroupId;
			returnValue.add(aa);
		}

        return returnValue;
        
        
    }
    public class picklistWrapper{
        @AuraEnabled 
		public string pickListLabel;
        @AuraEnabled 
		public string pickListValue;
        
    }
}