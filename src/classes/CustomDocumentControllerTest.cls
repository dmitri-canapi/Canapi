@IsTest
public class CustomDocumentControllerTest {
    @IsTest
    private static void test1() {
        system.debug(CustomDocumentController.isCommunity());
        system.debug(CustomDocumentController.createNewRec());
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List <Tag__c> tags = CustomDocumentController.getAccountTagsRecords(acc.Id);
        
        
        
        system.debug(CustomDocumentController.getTags(CustomDocumentController.createNewRec()));
        
        system.debug(CustomDocumentController.getTagsRecords(CustomDocumentController.createNewRec()));
        delete tags;
        
        CustomDocumentController.DeleteRec(CustomDocumentController.createNewRec());
        
        string tag1Id = CustomDocumentController.addNewTag(null,'test',acc.Id);
        string tag2Id = CustomDocumentController.addNewTag(tag1Id,'test',acc.Id);
        CustomDocumentController.setTagParent(tag1Id,tag2Id);
        CustomDocumentController.setTagParent(tag1Id,'0');
        
        Document_Helper__c docH = new Document_Helper__c(Name__c='test',ConvertToDocuments__c=true);
        insert docH;
        
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
        cdl.LinkedEntityId = docH.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        system.debug(CustomDocumentController.getFileRecords(docH.id));
        
        
        
        CustomDocumentController.setTagsVF(docH.id,new List<String>{tag1Id});
        CustomDocumentController.renameTag(tag1Id,'test2');
        
        
        
        Document__c doc = new Document__c (Name__c='test',Account__c=acc.Id);
        insert doc;
        Document__c doc2 = new Document__c (Name__c='test.pdf',Account__c=acc.Id);
        insert doc2;
        Document__c doc3 = new Document__c (Name__c='test.unknown',Account__c=acc.Id);
        insert doc3;
        
        Blob beforeblob=Blob.valueOf('Unit test Attachment Body');

        contact c = new Contact (Lastname='test',Account=acc);
        insert c;
        Opportunity o = new Opportunity (name='test',Account=acc,StageName='Closing',CloseDate=System.today());
        insert o;
        Board_Meeting__c b = new Board_Meeting__c (Account__c=acc.Id);
        insert b;
        
        CustomDocumentController contr = new CustomDocumentController();
        contr.filecontent = 'test';
        contr.filename = 'test';
        contr.filetype = 'txt';
        contr.parentId = acc.Id;
        contr.accId = acc.Id;
        contr.selectedTags = tag1Id;
        contr.uploadAttachment();
        contr.parentId = c.Id;
        contr.uploadAttachment();
        //CustomDocumentController.prepareDocumentForUpload('text',c.Id,acc.Id,tag1Id);
        contr.parentId = o.Id;
        contr.uploadAttachment();
        //CustomDocumentController.prepareDocumentForUpload('text',o.Id,acc.Id,tag1Id);
        contr.parentId = b.Id;
        contr.uploadAttachment();
        //CustomDocumentController.prepareDocumentForUpload('text',b.Id,acc.Id,tag1Id);
        contr.parentId = 'notId';
        contr.filename = 'verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext';
        contr.uploadAttachment();
        //CustomDocumentController.prepareDocumentForUpload('text','notId',acc.Id,tag1Id);
        
        //CustomDocumentController.prepareDocumentForUpload('verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext',acc.Id,acc.Id,tag1Id);
        
        /*CustomDocumentController.uploadAttachment('test','test','txt',acc.Id, acc.Id, tag1Id);
        CustomDocumentController.uploadAttachment('test','test','txt',c.Id, acc.Id, tag1Id);
        CustomDocumentController.uploadAttachment('test','test','txt',o.Id, acc.Id, tag1Id);
        CustomDocumentController.uploadAttachment('test','test','txt',b.Id, acc.Id, tag1Id);
        CustomDocumentController.uploadAttachment('test','test','txt','notId', acc.Id, tag1Id);*/
        
        system.debug(CustomDocumentController.GetDocumentsAccPage(acc.Id));
        
        system.debug(CustomDocumentController.GetDocuments());
        system.debug(CustomDocumentController.GetDocumentsHomePage());
        system.debug(CustomDocumentController.GetDocumentsRI());
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'test',acc.id,'Opportunities'));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'test',acc.id,'Contacts'));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'test',acc.id,'Board_Meetings__r'));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'test',acc.id,acc.id));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'test','testestesttestetest',acc.id));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,null,'testestesttestetest',acc.id));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'',acc.id,'Opportunities'));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'',acc.id,'Contacts'));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'',acc.id,'Board_Meetings__r'));
        system.debug(CustomDocumentController.GetAccountDocumentsFiltered(null,'',acc.id,acc.id));
        
        system.debug(CustomDocumentController.GetAccountDocumentsFilteredCount(null,'test',acc.id,acc.id));
        system.debug(CustomDocumentController.GetAccountDocumentsFilteredCount(null,null,acc.id,'Opportunities'));
        system.debug(CustomDocumentController.GetAccountDocumentsFilteredCount(null,null,acc.id,'Contacts'));
        system.debug(CustomDocumentController.GetAccountDocumentsFilteredCount(null,null,acc.id,'Board_Meetings__r'));
        //system.debug(CustomDocumentController.GetAccountDocumentsFilteredCount(null,null,acc.id,acc.id));
        system.debug(CustomDocumentController.GetAccountDocumentsFilteredCount(null,null,acc.id,c.id));
        
        system.debug(CustomDocumentController.GetAccountsRelatedLists(acc.id));
        system.debug(CustomDocumentController.getAccNameById(acc.id));
        
        
        system.debug(CustomDocumentController.getAccNameById(c.id));
        system.debug(CustomDocumentController.getAccNameById(o.id));
        system.debug(CustomDocumentController.getAccNameById(b.id));
        system.debug(CustomDocumentController.getAccNameById(tag1Id));
        

        
        system.debug(CustomDocumentController.getBaseUrl());
        
        TagDocumentAssociation__c tda = new TagDocumentAssociation__c(Tag__c=tag1Id,Document__c=doc.id);
        insert tda;
        system.debug(CustomDocumentController.GetDocumentsFiltered(tag1Id,'test'));
        system.debug(CustomDocumentController.getDocsTagsRecords(doc.id));
        CustomDocumentController.addTagForDocument(doc.id,tag2Id);
        CustomDocumentController.addTagForDocument(doc.id,tag2Id);
        
        CustomDocumentController.removeTag(tag2Id);
        CustomDocumentController.removeDocHelperTagAssoc(tda.id);
        
        

        Assessment__c assess = new Assessment__c(Account__c = acc.id);
        insert assess;

        review_item__c reviewItem = 
            new review_item__c(
                Assessment__c = assess.Id, 
                Review_Item_Name__c = 'Bronze 1',
                Item_Category__c = 'Bronze',
                Item_Category_Description__c = 'Bronze items');
        insert reviewItem;
        
        
        Test.startTest();
        system.debug(CustomDocumentController.GetDocNotes(doc.Id,reviewItem.id));
        CustomDocumentController.LinkDocToRI(reviewItem.id,doc.Id,'test');
        CustomDocumentController.LinkDocToRI(reviewItem.id,doc.Id,'test');
        
        
        system.debug(CustomDocumentController.GetDocumentsFilteredRI(null,null));
        
        system.debug(CustomDocumentController.GetDocNotes(doc.Id,reviewItem.id));
        
        CustomDocumentController.saveRecordContr (JSON.serialize(docH));
        system.debug(CustomDocumentController.getFileRecords(docH.id));
        
            system.debug(CustomDocumentController.getCommunityAccId());
        	CustomDocumentController.updateDocument(doc.Id, 'test', '2019-09-11 05:21:00');
            system.debug(Review_Items_Controller.getLinkedDocuments(reviewItem.id,''));
            
            string extId = String.valueOf(reviewItem.id) + String.valueOf(doc.id);
            Junction_Document_ReviewItem__c obj = [ select id from Junction_Document_ReviewItem__c where External_Id__c=:extId][0];
            Review_Items_Controller.removeJunctionObjectById(obj.id);
        Group gp = new Group(Name = 'Test');
        insert gp;  
        CustomDocumentController.removeAccess(gp.Id,doc.Id);
        Document__Share ds = new Document__Share();
        ds.ParentId = doc.Id;
        ds.UserOrGroupId = gp.Id;
        ds.AccessLevel = 'read';
        insert ds;
        CustomDocumentController.removeBulkAccess(ds.Id);
        
        system.debug(CustomDocumentController.GetDocVersionsData(acc.Id,doc.Id,null));
        
        CustomDocumentController.saveKeywords(tag1Id,true, 'test');
        CustomDocumentController.saveKeywords(tag1Id,true, 'test');
        Keyword__c kw = CustomDocumentController.getKeywordByTag(tag1Id);
            CustomDocumentController.deleteDocument (doc.id);
                
            delete documents;         
        Test.stopTest();
            
               
    }
    
    @IsTest
    private static void test2() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List <Tag__c> tags = CustomDocumentController.getAccountTagsRecords(acc.Id);
        
        
        
        system.debug(CustomDocumentController.getTags(CustomDocumentController.createNewRec()));
        
        system.debug(CustomDocumentController.getTagsRecords(CustomDocumentController.createNewRec()));
        
        CustomDocumentController.DeleteRec(CustomDocumentController.createNewRec());
        
        string tag1Id = CustomDocumentController.addNewTag(null,'test',acc.Id);
        string tag2Id = CustomDocumentController.addNewTag(tag1Id,'test',acc.Id);
        CustomDocumentController.setTagParent(tag1Id,tag2Id);
        CustomDocumentController.setTagParent(tag1Id,'0');
        
        Document_Helper__c docH = new Document_Helper__c(Name__c='test',ConvertToDocuments__c=true);
        insert docH;
        
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
        cdl.LinkedEntityId = docH.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        system.debug(CustomDocumentController.getFileRecords(docH.id));
        
        
        
        CustomDocumentController.setTagsVF(docH.id,new List<String>{tag1Id});
        CustomDocumentController.renameTag(tag1Id,'test2');
		Group gp = new Group(Name = 'Test');
        insert gp; 
        
        CustomDocumentController.addDefaultPermission(gp.Id,'Read');
        system.debug(CustomDocumentController.getCurrentDefaultSharings());
        
        Document__c doc = new Document__c (Name__c='test',Account__c=acc.Id);
        insert doc;
        Document__c doc2 = new Document__c (Name__c='test.pdf',Account__c=acc.Id);
        insert doc2;
        Document__c doc3 = new Document__c (Name__c='test.unknown',Account__c=acc.Id);
        insert doc3;
        
        Blob beforeblob=Blob.valueOf('Unit test Attachment Body');

        
        
        contact c = new Contact (Lastname='test',Account=acc);
        insert c;
        Opportunity o = new Opportunity (name='test',Account=acc,StageName='Closing',CloseDate=System.today());
        insert o;
        Board_Meeting__c b = new Board_Meeting__c (Account__c=acc.Id);
        insert b;
        
        CustomDocumentController contr = new CustomDocumentController();
        contr.filecontent = 'test';
        contr.filename = 'test';
        contr.filetype = 'txt';
        contr.parentId = acc.Id;
        contr.accId = acc.Id;
        contr.selectedTags = tag1Id;
        contr.uploadAttachment();
        contr.parentId = c.Id;
  
        CustomDocumentController.prepareDocumentForUpload('text',c.Id,acc.Id,tag1Id);
        contr.parentId = o.Id;

        CustomDocumentController.prepareDocumentForUpload('text',o.Id,acc.Id,tag1Id);
        contr.parentId = b.Id;

        CustomDocumentController.prepareDocumentForUpload('text',b.Id,acc.Id,tag1Id);
        contr.parentId = 'notId';
        contr.filename = 'verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext';
		
        CustomDocumentController.prepareDocumentForUpload('text','notId',acc.Id,tag1Id);
        
        CustomDocumentController.prepareDocumentForUpload('verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext',acc.Id,acc.Id,tag1Id);
        CustomDocumentController.changeDocumentsParent(doc.Id,acc.Id);
        CustomDocumentController.changeDocumentsParent(doc.Id,c.Id);
        CustomDocumentController.changeDocumentsParent(doc.Id,b.Id);
        CustomDocumentController.changeDocumentsParent(doc.Id,o.Id);
        update doc;
        CustomDocumentController.reApplyTags(acc.Id);
        
        Test.startTest();
        CustomDocumentController.addPermission(gp.Id,doc.Id,'read');
        CustomDocumentController.addBulkPermission(gp.Id,acc.Id,acc.Id,'read');
        CustomDocumentController.addBulkPermission(gp.Id,acc.Id,c.Id,'read');
        CustomDocumentController.addBulkPermission(gp.Id,acc.Id,'Opportunities','read');
        CustomDocumentController.addBulkPermission(gp.Id,acc.Id,'Contacts','read');
        CustomDocumentController.addBulkPermission(gp.Id,acc.Id,'Board_Meetings__r','read');
        
        system.debug(CustomDocumentController.getCurrentPermissionsForTheDocument(doc.Id));
        system.debug(CustomDocumentController.getCurrentPermissionsForObject(acc.Id,acc.Id));
        system.debug(CustomDocumentController.getCurrentPermissionsForObject(acc.Id,c.Id));
        system.debug(CustomDocumentController.getCurrentPermissionsForObject(acc.Id,'Opportunities'));
        system.debug(CustomDocumentController.getCurrentPermissionsForObject(acc.Id,'Contacts'));
        system.debug(CustomDocumentController.getCurrentPermissionsForObject(acc.Id,'Board_Meetings__r'));
        
        system.debug(CustomDocumentController.getGroups());
        system.debug(CustomDocumentController.getUsers());
        /*system.debug(CustomDocumentController.getCommunityPageHeaderInitValues2(c.Id));*/
        Test.stopTest();
        
    }

}