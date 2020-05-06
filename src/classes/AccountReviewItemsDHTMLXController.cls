global with sharing class AccountReviewItemsDHTMLXController {
    private static set <String> knowedFileExtensions = new set <String>{'doc','docx','ppt','pptx', 'xls','xlsx', 'html', 'txt', 'pdf', 'jpg', 'gif', 'png', 'tiff'};
    	
    @RemoteAction
    global static DDdata  GetReviewItemsList(String recId, String RIstatuses, String filter) {
        
        List <String> riStatusesList = (List <String>) JSON.deserialize (RIstatuses, List <String>.class);
        riStatusesList.add(null);
        filter = '%' + filter + '%';
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
            WHERE Assessment__c = :recId and Review_Item_Status__c in: riStatusesList and
            (Item_Category__c Like :filter or Review_Item_Name__c Like :filter)
            ORDER BY Item_Category__c ASC NULLS LAST, Review_Item_Name__c ASC
        ];
        Assessment__c asses = new Assessment__c ();
        if (recId!= '') asses = [select Review_Type__c from Assessment__c where id =: recId];
        String AssName = asses.Review_Type__c != null? asses.Review_Type__c : '';
        return new DDdata (reviewItems,AssName);
    }

    @RemoteAction
    global static RIData GetRIData(String recId) {
        Review_Item__c reviewItem = [SELECT  Is_Locked__c, Id,Name,Assets_Needed__c,File_Count__c,Item_Comments__c,Reviewer_Comments__c,Grade_Number__c,Urgent__c,Item_Grading__c,Grade_Description__c,Assessment__c,Assessment__r.Name,Review_Date__c,Item_Category__c,Item_Category_Description__c,Item_Description__c,Finished__c,Review_Item_Name__c, Review_Item_Status__c FROM Review_Item__c where id =: recId limit 1];
        
        List <Document__c> documents = [SELECT 
                                        id, 
                                        Name__c,
                                        (
                                            SELECT 
                                            Tag__r.Name
                                            FROM 
                                            TagDocumentAssociations__r
                                        ),
                                        (
                                            SELECT
                                            id,
                                            Notes__c
                                            FROM
                                            Junctions_Document_ReviewItem__r
                                            WHERE
                                            Review_Item__c=:recId
                                            
                                        )
                                        FROM Document__c 
                                        WHERE 
                                        id in 
                                        (
                                            SELECT Document__c
                                            FROM
                                            Junction_Document_ReviewItem__c
                                            WHERE 
                                            Review_Item__c=:recId
                                        )
                                       ];


                                       Set <Id> docsIds = new  Set <Id>();
                                       map <Id, String> docAttachmentMap = new map <Id, String>();
                                       for (Document__c doc: documents) {
                                            docsIds.add(doc.Id);
                                       }

                                       JSONGenerator generator = JSON.createGenerator(true);   

                                       if (docsIds.size()>0){
                                        for (ContentDocumentLink cdl: [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in:docsIds]){
                                            docAttachmentMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                                        }
                                        
                                        
                                        generator.writeStartObject(); 
                                        generator.writeFieldName('rows');
                                        generator.writeStartArray(); //Write the starting marker of a JSON object '['
                                        for (Document__c d: documents){
                                            if (docAttachmentMap.containsKey(d.Id)){
                                                generator.writeStartObject(); //Write the starting marker of a JSON object '{'
                                                generator.writeStringField('id', d.Id);
                                                generator.writeFieldName('userdata');
                                                generator.writeStartObject();
                                                generator.writeStringField('Tags', JSON.serialize(d.TagDocumentAssociations__r));
                                                generator.writeEndObject();

                                                List<String> strlist = new List<String>();
                                                String link='';
                                                
                                                if(d.Name__c.contains('.')){
                                                    list<String> parsedDocName = d.Name__c.split('\\.');
                                                    if(knowedFileExtensions.contains(parsedDocName[parsedDocName.size()-1].toLowerCase())){
                                                        strlist.add(parsedDocName[parsedDocName.size()-1].toLowerCase() + '.png');
                                                    } else {
                                                        strlist.add('file.png');
                                                    }
                                                } else {
                                                    strlist.add('file.png');
                                                }
                                                
                                                    link = 'javascript:openModal("' + docAttachmentMap.get(d.Id) + '")^_self';
                                                //}
                                                
                                                strlist.add( d.Name__c  + '^' + link );
                                                strlist.add(d.Id);
                                                for (Junction_Document_ReviewItem__c jri: d.Junctions_Document_ReviewItem__r){
                                                    strlist.add(jri.Notes__c);
                                                }
                                                //strlist.add('<input type="button" value="Remove" onclick="removeJunc(\''+ d.Id +'\')">');
                                                strlist.add('edit.png^Attach^javascript:openLinkDocWindow("' + d.Id + '");^_self');
                                                strlist.add('delete.png^Attach^javascript:removeJunc("' +  d.Id + '");^_self');
                                                generator.writeObjectField('data', strlist);
                                                generator.writeEndObject();
                                            }
                                        }
                                        generator.writeEndArray(); //Write the end marker of a JSON object ']'
                                        generator.writeEndObject();
                                    }
        
        return new RIData (reviewItem, generator.getAsString());
    }

    @RemoteAction
    global static void removeJunctionObjectById(String recordId){
        Delete [select id from Junction_Document_ReviewItem__c where External_Id__c =: recordId];
    }

    @RemoteAction
    global static void removeDDById(String recordId){
        Delete [select id from Assessment__c where id =: recordId];
    }

    @RemoteAction
    global static void removeRIById(String recordId){
        Delete [select id from Review_Item__c where id =: recordId];
    }

    @RemoteAction
    global static void removeCategoryByName(String catName, String recordId){
        if (catName == 'other'){
            Delete [select id from Review_Item__c where Assessment__c =: recordId and (Item_Category__c =: catName or Item_Category__c = null or Item_Category__c = 's')];
        } else {
            Delete [select id from Review_Item__c where Assessment__c =: recordId and Item_Category__c =: catName];
        }
    }

    @RemoteAction
    global static void createCategory(String catName, String recordId){
        Review_Item__c reviewItem = new Review_Item__c (Assessment__c = recordId, Item_Category__c = catName, Review_Item_Name__c = 'New Review Item');
        insert reviewItem;
    }

    @RemoteAction
    global static String GetCategoryData(String catName, String recordId){
        system.debug(catName + recordId);
        return [ select Item_Category_Description__c from  Review_Item__c where Item_Category__c =: catName and Assessment__c =: recordId limit 1].Item_Category_Description__c;
    }

    @RemoteAction
    global static void setCatData(String catName, String catDesc, String newCatName, String recordId){
        List <Review_Item__c> riList = [ select id, Item_Category__c from  Review_Item__c where Item_Category__c =: catName and Assessment__c =: recordId];
        for (Review_Item__c ri: riList){
            ri.Item_Category__c = newCatName;
            ri.Item_Category_Description__c = catDesc;
        }
        update riList;

    }

    /*@RemoteAction
     global static List <Assessment__c> GetReviewItems (String recId){
         
         recId = [SELECT Id, Account__c from Assessment__c where id=:recId].Account__c;
         //Account a = [select Id,name,(select id,name from opportunities order by name asc), (select id, name from contacts order by name asc),(select id, name from Board_Meetings__r order by Date__c desc nulls last) from Account where id=:recId];
         return [select id, Name, Account__r.Name, (select id, Item_Category__c from Review_Items__r order by Item_Category__c nulls last) from Assessment__c where Account__c =: recId];
     }*/ 

     /*@RemoteAction
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
    }*/

    /*@RemoteAction
    global static Review_Item__c getRIData(String recId){
        return [select id, Item_Description__c, Item_Comments__c, Grade_Description__c, Review_Item_Name__c FROM Review_Item__c WHERE id = :recId];
    }*/

    @RemoteAction
    global static void setRIData(String recId, String ItemDescription, String assetsNedded, String itemComments, String reviewerComments, String grade, String status, String riName){
        Review_Item__c ri = new Review_Item__c();
        ri.id = recId;
        ri.Item_Comments__c = itemComments;
        ri.Reviewer_Comments__c = reviewerComments;
        ri.Item_Description__c = ItemDescription;
        ri.Assets_Needed__c = assetsNedded;
        ri.Item_Grading__c = grade;
        ri.Review_Item_Status__c = status;
        ri.Review_Item_Name__c = riName;
        update ri;
    }

    @RemoteAction
    global static void setCompleted(String recId){
        Review_Item__c ri = new Review_Item__c();
        ri.id = recId;
        ri.Review_Item_Status__c = 'Complete';
        update ri;
    }

    @RemoteAction
    global static String GetAllDDchecklists(String accId){
        JSONGenerator generator = JSON.createGenerator(true);
            generator.writeStartObject(); 
            generator.writeFieldName('rows');
            generator.writeStartArray(); 
            for (Assessment__c dd: [select Id, Name, Review_Type__c, Review_Date__c,Review_Status__c,Review_Items_Total__c,Review_Items_Open__c  FROM Assessment__c where Account__c =: accId  ORDER BY Review_Status__c ASC]){
                generator.writeStartObject(); //Write the starting marker of a JSON object '{'
                generator.writeStringField('id', dd.Id);
                List<String> strlist = new List<String>();
                strlist.add(dd.Review_Type__c);
                if (dd.Review_Date__c != null){
                    strlist.add(dd.Review_Date__c.month() + '/' + dd.Review_Date__c.day() +'/' + dd.Review_Date__c.year());
                } else {
                    strlist.add('');
                }
                String link = 'javascript:navigateTo("' + dd.Id + '")^_self';
                strlist.add(dd.Name + '^' + link);
                strlist.add(dd.Review_Status__c);
                strlist.add(String.ValueOf(dd.Review_Items_Total__c));
                strlist.add(String.ValueOf(dd.Review_Items_Open__c));
                strlist.add('edit.png^Attach^javascript:sendToParent(' + '"edit","' + dd.Id + '");^_self');
                strlist.add('delete.png^Attach^javascript:removeDD("' +  dd.Id + '");^_self');
                generator.writeObjectField('data', strlist);
                generator.writeEndObject();
            }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        return generator.getAsString();
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
    public static initValuesWrapper getInitValuesWrapper(String recId) {
        // below is the desired method of checking permissions, but it always returns true due to
        // known issue W-2616683 where Apex can't correctly determine the current user's access because 
        // the code runs in system mode. for now using VisualForce workaround as decribed at:
        //   https://success.salesforce.com/issues_view?id=a1p300000008djFAAQ
        // Boolean isCreateable = Schema.describeSObjects(new List<String>{'review_item__c'})[0].isCreateable();
        Boolean isCreateable = new CheckObjectPermissionsInVisualForce('review_item__c').isCreateable();
        String AccId = '';
        String ddId = '';
        if (recId == null){
            AccId = [select Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
            if (AccId == null){
                AccId = [select id from Account where Name = 'Canapi' limit 1].Id;
            }
            try {
                ddId = [select Id FROM Assessment__c where Account__c =: AccId  ORDER BY Review_Status__c ASC limit 1].Id;
            } catch(exception e){}
        } else {
            if (id.valueOf(recId).getSObjectType().getDescribe().getName()=='Account'){
                AccId = recId;
                try {
                    ddId = [select Id FROM Assessment__c where Account__c =: AccId  ORDER BY Review_Status__c ASC limit 1].Id;
                } catch(exception e){}
            } else if (id.valueOf(recId).getSObjectType().getDescribe().getName()=='Assessment__c'){
                ddId = recId;
                AccId = [select Account__c FROM Assessment__c where id =: recId].Account__c;
            }
        }


        return new initValuesWrapper(AccId, ddId, isCreateable);
    }

    @AuraEnabled
    public static void saveRecord (String RIrec){
        RIrec=RIrec.replace('[','').replaceAll(']','');
        system.debug(RIrec);
        Review_Item__c ri = (Review_Item__c)JSON.deserialize(RIrec,Review_Item__c.class);
        
        update ri;
    }

    global class RIData {
        public String gridData { get; set; }
        public Review_Item__c reviewItem {get; set;}
        public RIData(Review_Item__c reviewItem, String gridData){
            this.reviewItem = reviewItem;
            this.gridData = gridData;
        }
    }

    global class DDdata {
        public String ddType { get; set; }
        public List <Review_Item__c> riList {get; set;}
        public DDdata(List <Review_Item__c> riList, String ddType){
            this.riList = riList;
            this.ddType = ddType;
        }
    }

    public class initValuesWrapper {
        @AuraEnabled
        public String accId {get; set;}
        @AuraEnabled
        public String ddId {get; set;}
        @AuraEnabled
        public Boolean isCreateable {get; set;}
        public initValuesWrapper(String accId, String ddId, boolean isCreateable){
            this.accId = accId;
            this.ddId = ddId;
            this.isCreateable = isCreateable;
        }
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