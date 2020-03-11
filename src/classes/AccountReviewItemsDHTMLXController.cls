global with sharing class AccountReviewItemsDHTMLXController {
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

    @RemoteAction
     global static List <Assessment__c> GetAccountsRelatedLists (String recId){
         /*if(id.valueOf(recId).getSObjectType().getDescribe().getName()=='Contact'){
             recId = [select id, AccountId from Contact where id=:recId].AccountId;
         }
         if(id.valueOf(recId).getSObjectType().getDescribe().getName()=='Opportunity'){
             recId = [select id, AccountId from Opportunity where id=:recId].AccountId;
         }
         if(id.valueOf(recId).getSObjectType().getDescribe().getName()=='Board_Meeting__c'){
             recId = [select id, Account__c from Board_Meeting__c where id=:recId].Account__c;
         }
         if (id.valueOf(recId).getSObjectType().getDescribe().getName()=='Financial_Report__c'){
             recId = [select id, Account__c from Financial_Report__c where id=:recId].Account__c;
         }
         if (id.valueOf(recId).getSObjectType().getDescribe().getName()=='Round__c'){
             recId = [select id, Target_Company__c from Round__c where id=:recId].Target_Company__c;
         }
         if (id.valueOf(recId).getSObjectType().getDescribe().getName()=='Task'){
             recId = [SELECT Id, AccountId from Task where id=:recId].AccountId;
         }
        */
         recId = [SELECT Id, Account__c from Assessment__c where id=:recId].Account__c;
         //Account a = [select Id,name,(select id,name from opportunities order by name asc), (select id, name from contacts order by name asc),(select id, name from Board_Meetings__r order by Date__c desc nulls last) from Account where id=:recId];
         return [select id, Name, Account__r.Name, (select id, Item_Category__c from Review_Items__r order by Item_Category__c nulls last) from Assessment__c where Account__c =: recId];
     }

     @RemoteAction
    global static String GetRIFiltered(String DDId, String category){
        JSONGenerator generator = JSON.createGenerator(true);
            generator.writeStartObject(); 
            generator.writeFieldName('rows');
            generator.writeStartArray(); 
            for (Review_Item__c ri: [select Id, Name, Assets_Needed__c, File_Count__c, Item_Comments__c, Grade_Number__c, Urgent__c, Item_Grading__c, Grade_Description__c, Assessment__c, Assessment__r.Name, Review_Date__c, Item_Category__c, Item_Category_Description__c, Item_Description__c, Finished__c, Review_Item_Name__c, Review_Item_Status__c FROM Review_Item__c WHERE Assessment__c = :DDId and  Item_Category__c =: category ORDER BY Review_Item_Name__c ASC]){
                generator.writeStartObject(); //Write the starting marker of a JSON object '{'
                generator.writeStringField('id', ri.Id);
                List<String> strlist = new List<String>();
                strlist.add(ri.Review_Item_Name__c);
                strlist.add(ri.Review_Item_Status__c);
                strlist.add(ri.Assets_Needed__c);
                strlist.add('clip.png^Attach^javascript:sendToParent(' + '"link","' + ri.Id + '");^_self');
                strlist.add('edit.png^Attach^javascript:sendToParent(' + '"edit","' + ri.Id + '");^_self');
                generator.writeObjectField('data', strlist);
                generator.writeEndObject();
            }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        return generator.getAsString();
    }

    @RemoteAction
    global static Review_Item__c getRIData(String recId){
        return [select id, Item_Description__c, Item_Comments__c, Grade_Description__c, Review_Item_Name__c FROM Review_Item__c WHERE id = :recId];
    }

    @RemoteAction
    global static void setRIData(String recId, String itemComments, String GradeDescription){
        Review_Item__c ri = new Review_Item__c(id = recId, Item_Comments__c = itemComments, Grade_Description__c = GradeDescription);
        update ri;
    }


    @AuraEnabled  
    public static RIwrapper getWrapper(String riID) {
        system.debug(riID);
        Review_Item__c reviewItem = [SELECT Is_Locked__c, Id,Name,Assets_Needed__c,File_Count__c,Item_Comments__c,Grade_Number__c,Urgent__c,Item_Grading__c,Grade_Description__c,Assessment__c,Assessment__r.Name,Review_Date__c,Item_Category__c,Item_Category_Description__c,Item_Description__c,Finished__c,Review_Item_Name__c, Review_Item_Status__c FROM Review_Item__c where id =: riID limit 1];
        List<UserRecordAccess> access = [
            SELECT RecordId, HasEditAccess, MaxAccessLevel 
            FROM UserRecordAccess 
            WHERE UserId = :UserInfo.getUserId() 
            AND RecordId = :riID
        ];

        Boolean editable = !access.isEmpty() && access[0].HasEditAccess && !reviewItem.Is_Locked__c;
        Boolean isCreateable = new CheckObjectPermissionsInVisualForce('review_item__c').isCreateable();
        return new RIwrapper (reviewItem, editable, isCreateable);
    }

    @AuraEnabled
    public static Boolean isReviewItemCreateable() {
        // below is the desired method of checking permissions, but it always returns true due to
        // known issue W-2616683 where Apex can't correctly determine the current user's access because 
        // the code runs in system mode. for now using VisualForce workaround as decribed at:
        //   https://success.salesforce.com/issues_view?id=a1p300000008djFAAQ
        // Boolean isCreateable = Schema.describeSObjects(new List<String>{'review_item__c'})[0].isCreateable();
        Boolean isCreateable = new CheckObjectPermissionsInVisualForce('review_item__c').isCreateable();
        System.debug('+++ isCreateable: ' + isCreateable);
        return isCreateable;
    }

    @AuraEnabled
    public static void saveRecord (String RIrec){
        RIrec=RIrec.replace('[','').replaceAll(']','');
        system.debug(RIrec);
        Review_Item__c ri = (Review_Item__c)JSON.deserialize(RIrec,Review_Item__c.class);
        
        update ri;
    }

    public class RIwrapper {
        @AuraEnabled
        public Review_Item__c reviewItem {get; set;}
        @AuraEnabled
        public Boolean isRecordEditable {get; set;}
        @AuraEnabled
        public Boolean isReviewItemCreateable {get; set;}
        public RIwrapper(Review_Item__c reviewItem, boolean isRecordEditable, boolean isReviewItemCreateable){
            this.reviewItem = reviewItem;
            this.isRecordEditable = isRecordEditable;
            this.isReviewItemCreateable = isReviewItemCreateable;
        }
    }

}