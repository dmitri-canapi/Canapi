public without sharing class CustomDocumentControllerWoutSharing {
    public static String getCurrentPermissionsForTheDocument (String currentDocId){
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        List <Document__Share> dshares = [select id,UserOrGroupId,AccessLevel,RowCause from Document__Share where ParentId=:currentDocId and RowCause!= 'Owner'];
        Map <id,string> UserOrGroupIds = new map <id,string>();
        
        for (Document__Share  ds: dshares){
            UserOrGroupIds.put(ds.UserOrGroupId,ds.AccessLevel);
        }
        
        for (Group  g: [select Id, Name, DeveloperName, Type FROM Group where id in: UserOrGroupIds.KeySet() order by name asc, DeveloperName asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', g.Id);
            List<String> strlist = new List<String>();
            strlist.add( 'Group' );
            if (g.Name == '' || g.Name == null){
                strlist.add( g.DeveloperName );
            } else {
                strlist.add( g.Name );
            }
            strlist.add(UserOrGroupIds.get(g.Id));
            String link='';
            link = 'javascript:removeAccess("' + g.Id + '","' + currentDocId + '")';
            strlist.add( 'X'  + '^' + link );
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        for (User  u: [select name from User where id in: UserOrGroupIds.KeySet() order by name asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', u.Id);
            List<String> strlist = new List<String>();
            strlist.add( 'User' );
            strlist.add( u.Name );
            strlist.add(UserOrGroupIds.get(u.Id));
            String link='';
            link = 'javascript:removeAccess("' + u.Id + '","' + currentDocId + '")';
            strlist.add( 'X'  + '^' + link );
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        
        return generator.getAsString();
    }
    
    public static String getCurrentPermissionsForObject (String accId, String DocumentParentObjectId){
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String FullaccId = accId;
        accId = accId.substring(0, 15);
        List <Document__c> docList = new List <Document__c>();    
        
        string query = 'select id, Name__c,UserRecordAccess.HasEditAccess, Owner.Name, OwnerId from Document__c where id!=null';
        if (DocumentParentObjectId==FullaccId){
            query+=' AND (Account__c=:accId OR Opportunity__r.AccountId=:accId OR Contact__r.AccountId=:accId OR Board_Meeting__r.Account__c=:accId)'; 
        } else if(DocumentParentObjectId=='Opportunities'){
            query+=' AND Opportunity__r.AccountId=:accId'; 
        } else if(DocumentParentObjectId=='Contacts'){
            query+=' AND Contact__r.AccountId=:accId'; 
        } else if(DocumentParentObjectId=='Board_Meetings__r'){
            query+=' AND Board_Meeting__r.Account__c=:accId'; 
        } else if(DocumentParentObjectId.contains(',')){
            List <String> docIds = DocumentParentObjectId.split(',');
            query+=' AND Id in:docIds';
        } else {
            string objName = Id.valueOf(DocumentParentObjectId).getSObjectType().getDescribe().getName(); 
            system.debug(objName);
            if(!objName.contains('__c')){
                objName = objName + '__c';
            }
            query+=' AND ' + objName + '=:DocumentParentObjectId';
        }
        
        if (p.Name!='System Administrator'){
            string Uid = userInfo.getUserId();
             query+=' AND OwnerId =: Uid';
        }
        query+=' order by Name__c desc';
        
		map <Id,Document__c> docsIds = new  map <Id,Document__c>();
		for (Document__c doc:Database.query(query)){
            docsIds.put(doc.Id, doc);
        }

        List <Document__Share> dshares = [select id,UserOrGroupId,AccessLevel,RowCause,ParentId from Document__Share where ParentId in: docsIds.keySet() and RowCause!= 'Owner'];
        Set <id> UserOrGroupIds = new Set <id>();
        map <id,string> UserOrGroupIdstonameMap = new map <id,string>();
        for (Document__Share  ds: dshares){
            UserOrGroupIds.add(ds.UserOrGroupId);
        }
        for (Group  g: [select Id, Name, DeveloperName, Type FROM Group where id in: UserOrGroupIds order by name asc, DeveloperName asc]){
            string gName='';
            if (g.Name == '' || g.Name == null){
                gName = g.DeveloperName;
            } else {
                 gName = g.Name;
            }
            UserOrGroupIdstonameMap.put(g.Id, gName);
        }
        for (User  u: [select name from User where id in: UserOrGroupIds order by name asc]){
            UserOrGroupIdstonameMap.put(u.Id, u.name);
        }
        
        
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['

        for (Document__Share ds : dshares){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', ds.Id);
            List<String> strlist = new List<String>();
            strlist.add(docsIds.get(ds.ParentId).Name__c);
            
            if (String.ValueOf(ds.UserOrGroupId).startsWithIgnoreCase('005')){
            	strlist.add( 'User' );
            } else {
                strlist.add( 'Group' );
            }
            strlist.add( UserOrGroupIdstonameMap.get(ds.UserOrGroupId) );
            strlist.add(ds.AccessLevel);
            String link='';
            link = 'javascript:removeBulkAccess("' + ds.Id + '")';
            strlist.add( 'X'  + '^' + link );
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        
        return generator.getAsString();
    }
    
    public static String getCurrentDefaultSharings(){
    	JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        List <Default_Sharing__c> dshares = [select id, UserOrGroup__c, Access__c, createdById  from Default_Sharing__c where createdById=:userInfo.getUserId()];
        Map <id,Default_Sharing__c> UserOrGroupIds = new map <id,Default_Sharing__c>();

        for (Default_Sharing__c  ds: dshares){
            UserOrGroupIds.put(ds.UserOrGroup__c,ds);
        }
        
        for (Group  g: [select Id, Name, DeveloperName, Type FROM Group where id in: UserOrGroupIds.KeySet() order by name asc, DeveloperName asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', UserOrGroupIds.get(g.Id).Id);
            List<String> strlist = new List<String>();
            strlist.add( 'Group' );
            if (g.Name == '' || g.Name == null){
                strlist.add( g.DeveloperName );
            } else {
                strlist.add( g.Name );
            }
            strlist.add(UserOrGroupIds.get(g.Id).Access__c);
            String link='';
            link = 'javascript:removeDSAccess("' + UserOrGroupIds.get(g.Id).Id + '")';
            strlist.add( 'X'  + '^' + link );
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        for (User  u: [select name from User where id in: UserOrGroupIds.KeySet() order by name asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', UserOrGroupIds.get(u.Id).Id);
            List<String> strlist = new List<String>();
            strlist.add( 'User' );
            strlist.add( u.Name );
            strlist.add(UserOrGroupIds.get(u.Id).Access__c);
            String link='';
            link = 'javascript:removeDSAccess("' + UserOrGroupIds.get(u.Id).Id + '")';
            strlist.add( 'X'  + '^' + link );
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        
        return generator.getAsString();
    }
    
    public static String getGroups(){
        list <Group> groups = [SELECT Id, Name, DeveloperName, Type FROM Group where type='Regular' Or type ='AllCustomerPortal' Or type ='Organization' order by Name asc,DeveloperName asc  limit 1000];
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('options');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        
        for (Group u: groups){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('value', u.Id);
            generator.writeStringField('img', '');
            if (u.Name == '' || u.Name == null){
                generator.writeStringField('text', u.DeveloperName);
            } else {
                generator.writeStringField('text', u.Name);
            }
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        
        return generator.getAsString();
    }
    public static String getUsers(){
        list <User> usrs = [select id,name,SmallPhotoUrl from User where id!=:userInfo.getUserId() and isActive=true and name!='Automated Process' and (Profile.UserLicense.Name='Salesforce' or Profile.UserLicense.Name='Customer Community Plus') order By name ASC];
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('options');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        
        for (User u: usrs){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('value', u.Id);
            generator.writeStringField('img', u.SmallPhotoUrl);
            generator.writeStringField('text', u.Name);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        
        return generator.getAsString();
        
    }
    public static void addPermission (String userOrGroupId,String currentDocId, String AccessType){
        Document__Share ds = new Document__Share();
        ds.ParentId = currentDocId;
        ds.UserOrGroupId = userOrGroupId;
        ds.AccessLevel = AccessType;
        insert ds;
        
        List <ContentDocumentLink> cdlList = new List <ContentDocumentLink> ();
        cdlList=  [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:currentDocId];
        for(ContentDocumentLink l:cdlList) {
            l.Visibility='AllUsers';
        } 
        if (cdlList.size()>0){
            update cdlList;
        }
            
    }
    
    public static void addDefaultPermission (String userOrGroupId, String AccessType){
        Default_Sharing__c ds = new Default_Sharing__c();
        try {
            ds = [select id, UserOrGroup__c, Access__c, createdById from Default_Sharing__c where UserOrGroup__c= : userOrGroupId and createdById=:userInfo.getUserId()];
        } catch(exception e){}
        ds.UserOrGroup__c = userOrGroupId;
        ds.Access__c = AccessType;
        upsert ds;
    }
    
    public static void addBulkPermission (String userOrGroupId,String accId, String DocumentParentObjectId, String AccessType){
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String FullaccId = accId;
        accId = accId.substring(0, 15);
        List <Document__c> docList = new List <Document__c>();    
        
        string query = 'select id, Name__c,UserRecordAccess.HasEditAccess, Owner.Name, OwnerId from Document__c where id!=null';
        if (DocumentParentObjectId==FullaccId){
            query+=' AND (Account__c=:accId OR Opportunity__r.AccountId=:accId OR Contact__r.AccountId=:accId OR Board_Meeting__r.Account__c=:accId)'; 
        } else if(DocumentParentObjectId=='Opportunities'){
            query+=' AND Opportunity__r.AccountId=:accId'; 
        } else if(DocumentParentObjectId=='Contacts'){
            query+=' AND Contact__r.AccountId=:accId'; 
        } else if(DocumentParentObjectId=='Board_Meetings__r'){
            query+=' AND Board_Meeting__r.Account__c=:accId'; 
        } else if(DocumentParentObjectId.contains(',')){
            List <String> docIds = DocumentParentObjectId.split(',');
            query+=' AND Id in:docIds';
        } else {
            string objName = Id.valueOf(DocumentParentObjectId).getSObjectType().getDescribe().getName(); 
            system.debug(objName);
            if(!objName.contains('__c')){
                objName = objName + '__c';
            }
            query+=' AND ' + objName + '=:DocumentParentObjectId';
        }
        
        if (p.Name!='System Administrator'){
            string Uid = userInfo.getUserId();
            query+=' AND OwnerId =: Uid';
        }
        system.debug(query);
        if (userOrGroupId.startsWithIgnoreCase('005')){
            query+=' AND OwnerId !=:userOrGroupId';
        }
        system.debug(query);
        
		list <Document__Share> dsList = new list <Document__Share>();
		Set<Id> docIds = new Set<Id>();
        
        for (Document__c doc:Database.query(query)){
            Document__Share ds = new Document__Share();
            ds.ParentId = doc.Id;
            ds.UserOrGroupId = userOrGroupId;
            ds.AccessLevel = AccessType;
            dsList.add(ds);
            docIds.add(doc.Id);
        }
        
        if (dsList.size()>0){
            insert dsList;
        }
        
        List <ContentDocumentLink> cdlList = new List <ContentDocumentLink> ();
        if (!Test.isRunningTest()){
            cdlList=  [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId  in: docIds  or ContentDocumentId=:userInfo.getUserId()];
            for(ContentDocumentLink l:cdlList) {
                l.Visibility='AllUsers';
            } 
            if (cdlList.size()>0){
                update cdlList;
            }
        }
    }
    
    public static void removeAccess (String userOrGroupId, String currentDocId){
        delete [select id from Document__Share where userOrGroupId=:userOrGroupId and ParentId=:currentDocId];
    }
    
    public static void removeBulkAccess (String dsId){
        delete [select id from Document__Share where id=:dsId];
    }
    
    public static List <Document__share> getDocShares (Set <Id> docsIds){
        List <Document__share> dsList = new List <Document__share>();
        dsList = [select id, ParentId, AccessLevel,UserOrGroupId,RowCause from Document__share where ParentId in:docsIds and RowCause='Manual'];
        return dsList;
    }
}