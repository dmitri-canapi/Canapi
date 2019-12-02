global without sharing class AccountReviewItemsDHTMLXController {
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
         if(id.valueOf(recId).getSObjectType().getDescribe().getName()=='Contact'){
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
            strlist.add('');
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
}