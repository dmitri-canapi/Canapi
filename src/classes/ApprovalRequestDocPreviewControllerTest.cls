@isTest public with sharing class ApprovalRequestDocPreviewControllerTest {
    @isTest
    private static void test1() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Document__c doc = new Document__c (Name__c='test',Account__c=acc.Id);
        insert doc;

        ContentVersion contentVersion = new ContentVersion(
          Title = 'test',
          PathOnClient = 'test.txt',
          VersionData = Blob.valueOf('test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = doc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setObjectId(doc.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Alliance_Document_approval_process');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);

        ApprovalRequestDocPreviewController.getFileId(result.getNewWorkitemIds()[0]);
    }
}