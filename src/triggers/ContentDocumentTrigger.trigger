trigger ContentDocumentTrigger on ContentDocument (before delete, before update) {
    List<ContentDocument> contentDocList = new List<ContentDocument>();
    Set<Id> contentDocIds = new Set<Id>();
    Map<Id, Id> contentDocLinkMap = new Map<Id, Id>();

    // member variables specific to review item object
    Schema.DescribeSObjectResult reviewItemSObjectResult = Review_Item__c.sObjectType.getDescribe();
    String reviewItemIdPrefix = reviewItemSObjectResult.getKeyPrefix();
    Set<Id> reviewItemIds = new Set<Id>();
    Map<Id, Review_Item__c> reviewItemMap  = new Map<Id, Review_Item__c>();
    Map<Id, Set<Id>> reviewItemContentDocLinkMap = new Map<Id, Set<Id>>();

    if (Trigger.isDelete || Trigger.isUpdate) {

        if (Trigger.isDelete) {
            contentDocList = Trigger.old;
        }
        else if (Trigger.isUpdate) {
            contentDocList = Trigger.new;
        }

        for (ContentDocument contentDoc : contentDocList) {
            contentDocIds.add(contentDoc.Id);
        }

        for (ContentDocumentLink contentDocLink : [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN : contentDocIds]) {

            // collect review item ids linked to files (if any)
            if (reviewItemIdPrefix == String.valueOf(contentDocLink.LinkedEntityId).left(3)) {
                reviewItemIds.add(contentDocLink.LinkedEntityId);
                if(!reviewItemContentDocLinkMap.keySet().contains(contentDocLink.ContentDocumentId)) {
                    reviewItemContentDocLinkMap.put(contentDocLink.ContentDocumentId, new Set<Id>());
                }
                reviewItemContentDocLinkMap.get(contentDocLink.ContentDocumentId).add(contentDocLink.LinkedEntityId);
            }
        }

        // build review item map for reference later
        if (!reviewItemIds.isEmpty()) {  
            for (Review_Item__c reviewItem : [
                SELECT Id, Is_Locked__c
                FROM Review_Item__c
                WHERE Id IN :reviewItemIds ]) {

                reviewItemMap.put(reviewItem.Id, reviewItem);
            }
        }
 
        for (ContentDocument contentDoc : contentDocList) {
            // if it's a review item and the review item is locked, prevent the delete
            if (reviewItemContentDocLinkMap.keySet().contains(contentDoc.Id)) {
                for (Id reviewItemId : reviewItemContentDocLinkMap.get(contentDoc.Id)) {
                    if (reviewItemMap.get(reviewItemId).Is_Locked__c) {
                        contentDoc.addError('This file could not be modified due to the status of the associated Review Item.');
                        break;
                    }
                }
            }
        }
    }
}