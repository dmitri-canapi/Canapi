public with sharing class communityVerticalNavCtrl {
    @AuraEnabled
    public static List <CollaborationGroup> getGroups (){
        return [SELECT Id,Name	FROM CollaborationGroup WHERE NetworkId =: Network.getNetworkId() and CollaborationType = 'Public' and IsArchived = false order by Name asc];
    }
}