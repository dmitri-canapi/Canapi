@isTest
private class ContentDownloadCustomHandlerFactoryTest {
    private static testMethod void testCase_Upload() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    Document__c doc = new Document__c (Name__c='test',Account__c=acc.Id);
    insert doc;

        Attachment testAttachment = new Attachment(
            Name='test12345',
            Description='testDescription',
            ParentId=doc.Id);
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        testAttachment.body=bodyBlob;
        insert testAttachment;
        
        ContentVersion testContent = new ContentVersion(
            Title='test12345',
            Description='testDescription',
            ContentLocation = 'S',
            PathOnClient = 'test12345',
            VersionData = bodyBlob);
        insert testContent;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = doc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        ContentDownloadCustomHandlerFactory f = new ContentDownloadCustomHandlerFactory() ;
        f.getContentDownloadHandler(new List<Id>{testContent.Id}, null);
    }
}