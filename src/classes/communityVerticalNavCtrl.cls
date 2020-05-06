public with sharing class communityVerticalNavCtrl {

    @AuraEnabled
    public static navWrapper getSettings(){
        List <CollaborationGroup> groups = [SELECT Id,Name	FROM CollaborationGroup WHERE NetworkId =: Network.getNetworkId() and CollaborationType = 'Public' and IsArchived = false order by Name asc];
        boolean  hasTags = [select id from UserContactTagAssociation__c where User__c =: UserInfo.getUserId()].size() > 0;
        String accId;
        accId = [select id,Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
       
        if (accId == null){
            accId = [select id from Account where Name = 'Canapi' limit 1].Id;
        }
        String RecTypeName = [select recordtype.name from Account where id =:accId].recordtype.name;
        return new navWrapper(groups, hasTags, RecTypeName, accId);
        
    }

    public class navWrapper{
        @AuraEnabled public List <CollaborationGroup> groups {get;set;}
        @AuraEnabled public String recTypeName {get;set;}
        @AuraEnabled public Boolean hasTags {get;set;}
        @AuraEnabled public String accId {get;set;}
        public navWrapper (List <CollaborationGroup> groups, Boolean hasTags, String recTypeName, String accId){
            this.groups = groups;
            this.hasTags = hasTags;
            this.recTypeName = recTypeName;
            this.accId = accId;
        }
    }
}