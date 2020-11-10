@isTest
public with sharing class docManFilesReportTest {
    @IsTest
    static void test(){

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
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = doc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        logFileView.logView(documents[0].Id);

        insert new DocumentViewCount__c(Document__c = doc.Id);
        insert new DocumentViewCount__c(Document__c = doc.Id);

        insert new DocumentDownloadCount__c(Document__c = doc.Id);
        insert new DocumentDownloadCount__c(Document__c = doc.Id);


        docManFilesReport.getDocs('Test Account',0,25);
        docManFilesReport.getNext(0,10);
        docManFilesReport.getPrevious(100,10);

    }

}