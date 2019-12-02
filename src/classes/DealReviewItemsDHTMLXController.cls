global without sharing class DealReviewItemsDHTMLXController {
    @RemoteAction
    global static List <Review_Item__c> getReviewItems(String recId) {
        List<Review_Item__c> reviewItems = [
            SELECT
                Id,
                Name,
                Assets_Needed__c,
            	File_Count__c,
            	Item_Comments__c,
                Grade_Number__c,
                Urgent__c,
                Item_Grading__c,
                Grade_Description__c,
            	Assessment__c,
            	Assessment__r.Name,
            	Review_Date__c,
                Item_Category__c,
                Item_Category_Description__c,
                Item_Description__c,
                Finished__c,
                Review_Item_Name__c,
                Review_Item_Status__c
            FROM Review_Item__c
            WHERE Assessment__c = :recId
            ORDER BY Item_Category__c ASC NULLS LAST, Name ASC
        ];
        return reviewItems;
    }
       
}