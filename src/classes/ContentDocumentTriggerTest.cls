@isTest
public class ContentDocumentTriggerTest {

    @testSetup 
    private static void testDataSetup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Assessment__c assess = new Assessment__c(Account__c = acc.id);
        insert assess;

        review_item__c item = new review_item__c(
            Assessment__c = assess.Id, 
            Review_Item_Name__c = 'Gold 1',
            Item_Category__c = 'Gold',
            Item_Category_Description__c = 'Gold items');
        insert item;

        ContentVersion cv = new ContentVersion(
            Title = 'Test Review Item File',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Review Item File'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentDocument cd = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
            WHERE LatestPublishedVersionId = :cv.Id
        ];

        ContentDocumentLink cdl = New ContentDocumentLink(
            LinkedEntityId = item.Id,
            ContentDocumentId = cd.Id,
            shareType = 'V'
        );
        insert cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Test Account File',
            PathOnClient = 'PolarBears.jpg',
            VersionData = Blob.valueOf('Test Account File'),
            IsMajorVersion = true
        );
        insert cv2;
        
        ContentDocument cd2 = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
            WHERE LatestPublishedVersionId = :cv2.Id
        ];

        ContentDocumentLink cdl2 = New ContentDocumentLink(
            LinkedEntityId = acc.Id,
            ContentDocumentId = cd2.Id,
            shareType = 'V'
        );
        insert cdl2;
    }

    @isTest
    private static void deleteReviewItemFileTest() {
        review_item__c reviewItem = [
            SELECT Id, Review_Item_Status__c, Is_Locked__c
            FROM review_item__c
            LIMIT 1
        ];

        ContentDocumentLink cdl = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :reviewItem.Id
            LIMIT 1
        ];

        ContentDocument cd = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Id = :cdl.ContentDocumentId
        ];

        Boolean isReviewItemLocked = reviewItem.Is_Locked__c;
        Boolean wasDeleteSuccessful = false;

        Test.startTest();
        try {
            delete cd;
            wasDeleteSuccessful = true;
        }
        catch (Exception ex) {
            wasDeleteSuccessful = false;
        }
        Test.stopTest();

        System.assertNotEquals(isReviewItemLocked, wasDeleteSuccessful);
    }

    @isTest 
    private static void deleteNonReviewItemFileTest() {
        Account acc = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        ContentDocumentLink cdl = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :acc.Id
            LIMIT 1
        ];

        ContentDocument cd = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Id = :cdl.ContentDocumentId
        ];

        Boolean wasDeleteSuccessful = false;

        Test.startTest();
        try {
            delete cd;
            wasDeleteSuccessful = true;
        }
        catch (Exception ex) {
            wasDeleteSuccessful = false;
        }
        Test.stopTest();

        System.assert(wasDeleteSuccessful);
    }
}