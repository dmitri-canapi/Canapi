public without sharing class DocumentsSharedWithAPusers {
    @AuraEnabled
    public static List<Document__c> getSharings() {

        String apGroupId = [select id from Group where Name = 'Alliance Portal Users' limit 1].id;
        
        Set <id> ParentIds = new Set <id>();
        for (Document__Share  ds: [select id,UserOrGroupId,RowCause,ParentId from Document__Share where UserOrGroupId =: apGroupId and RowCause!= 'Owner']){
            ParentIds.add(ds.ParentId);
        }
        List <Document__c> docList = new List <Document__c>();
        docList = [select id, Name__c, Owner.Name,CreatedDate, OwnerId,Contact__c,Contact__r.Name,Account__c,Account__r.Name,Board_Meeting__c,Board_Meeting__r.Name from Document__c where id in: ParentIds order by CreatedDate desc];

        return docList;
         }
}