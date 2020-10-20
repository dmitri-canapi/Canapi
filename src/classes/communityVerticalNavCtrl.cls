public without sharing class communityVerticalNavCtrl {

    @AuraEnabled
    public static navWrapper getSettings(){
        List <CollaborationGroup> groups = [SELECT Id,Name	FROM CollaborationGroup WHERE NetworkId =: Network.getNetworkId() and CollaborationType = 'Public' and IsArchived = false order by Name asc];
        boolean  hasTags = [select id from UserContactTagAssociation__c where User__c =: UserInfo.getUserId()].size() > 0;
        
        return new navWrapper(groups, hasTags);
        
    }

    public class navWrapper{
        @AuraEnabled public List <CollaborationGroup> groups {get;set;}
        @AuraEnabled public Boolean hasTags {get;set;}
        @AuraEnabled public String accName {get;set;}
        @AuraEnabled public String AccRecTypeName {get;set;}
        @AuraEnabled public Boolean IsExternalGrader {get;set;}
        public navWrapper (List <CollaborationGroup> groups, Boolean hasTags){
            this.groups = groups;
            this.hasTags = hasTags;

            Account acc;
            String accId = [select id,Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
        
            if (accId == null){
                acc = [select id,Name,RecordType.Name from Account where Name = 'Canapi' limit 1];
            } else {
                acc = [select id,Name,RecordType.Name from Account where id =:accId];
            }
            
            this.accName = acc.Name;
            this.AccRecTypeName = acc.RecordType.Name;
            String Contactid = [select ContactId from user where id=:UserInfo.getUserId()].ContactId;
            this.IsExternalGrader = false;
            if(ContactId != null){
                this.IsExternalGrader = [select Is_External_Grader__c from contact where id =: ContactId].Is_External_Grader__c;
            }
        }
    }
}