public class NewReview {
  @InvocableMethod(label='Inserts Review Items' description='Inserts review items that relates to a specific assessment(s) and review type.')
    public static void insertReviewItems(List<Id> reviewIDs){
      	List<Assessment__c> reviews = [select id, Name, Review_Date__c, Review_Status__c, Review_Summary__c, Review_Type__c, Total_Grade__c from Assessment__c where Assessment__c.Id in : reviewIDs];
        List<Assessment_Meta_Data__c> reviewItems = [select id, Name , Review_Type__c, Review_Category__c, Item_Assets__c, Item_Description__c from Assessment_Meta_Data__c];
         
        
       	for (Assessment__c review : reviews) {
              for (Assessment_Meta_Data__c r:reviewItems) {
                  if (review.Review_Type__c == r.Review_Type__c) {
                	review_item__c ri = new review_item__c();
                    ri.Assessment__c = review.Id;
                    ri.Assets_Needed__c = r.Item_Assets__c;
                    ri.Item_Category__c = r.Review_Category__c;
                    ri.Item_Description__c = r.Item_Description__c;
                    ri.Review_Item_Name__c = r.Name;
                    insert ri;
                    }
              }
                  
		}
 
    
    }
}