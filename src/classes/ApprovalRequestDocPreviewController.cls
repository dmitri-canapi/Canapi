public without sharing class ApprovalRequestDocPreviewController {
    @AuraEnabled
    public static String getFileId(String recordId){
        String fileId = null;
        Id targObjId = [select ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where id =: recordId].ProcessInstance.TargetObjectId;
        if(targObjId.getSObjectType().getDescribe().getName() == 'Document__c' || targObjId.getSObjectType().getDescribe().getName() == 'Financials_Change_Request__c'){
            ContentDocumentLink cdl= [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:targObjId];
            fileId = cdl.ContentDocumentId;
        }
        return fileId;
    }
}