trigger shareDocumentAttachment on Document__c (before update,after insert) {

    Set<string> docids = new set <string>();
    map <id,Document__c> DocsMap = new map <id,Document__c>();
    String accId;
    for(Document__c d:Trigger.new) {
        docids.add(d.Id);
        DocsMap.put(d.Id,d);
        accId = d.Account_Id__c;
    }
    map <Id, String> docAttachmentMap = new map <Id, String>();
    List <ContentDocumentLink> cdlList = new List <ContentDocumentLink> ();
    if(docids.size()>0){
        if (Trigger.isUpdate) {
            cdlList=  [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in:docids];
            for(ContentDocumentLink l:cdlList) {
                l.Visibility='AllUsers';
            } 
            if (cdlList.size()>0){
                update cdlList;
            }
        }
        if (Trigger.isInsert) {
            map <id, List <String>> tagKeywords = new map <id, List <String>>();
            for (Tag__c tag: [select id, name, (select id,Tag__c,Tag__r.Name, Keywords__c from Keywords__r where IsKeywordEnabled__c = true) from Tag__c where Account__c =: accId limit 50000]){
                tagKeywords.put(tag.id,new list <String>{tag.name});
                for (Keyword__c kw: tag.Keywords__r){
                    system.debug(kw.Keywords__c);
                    if(kw.Keywords__c!=null){
                        String kwords = kw.Keywords__c.replaceAll('</div>','');
                        List <String> kwList = kwords.split('<div>');
                        kwList.add(kw.Tag__r.Name);
                        system.debug(kwList);
                        tagKeywords.put(tag.id,kwList);
                    }
                    
                }
            }
            List <TagDocumentAssociation__c> tdaList = new List <TagDocumentAssociation__c>();
            List <Default_Sharing__c> defSharings = [select id, UserOrGroup__c, Access__c, createdById from Default_Sharing__c where createdById=:userInfo.getUserId() or CreatedBy__c =:userInfo.getUserId()];
        	List <Document__Share> docShares = new List <Document__Share>();
            
            
            for (Document__c doc: DocsMap.values()){
                for (ID tagId : tagKeywords.keySet() ){
                    for (String keyword: tagKeywords.get(tagId)){
                        system.debug(keyword);
                        if(doc.Name.toLowerCase().Contains(keyword.toLowerCase())){
                            TagDocumentAssociation__c tda = new TagDocumentAssociation__c(Tag__c=tagId,Document__c=doc.Id);
                            tdaList.add(tda);
                        }
                    }
                }
                /* Creating default shares */
                for (Default_Sharing__c ds: defSharings){
                    Document__Share dShare = new Document__Share();
                    dShare.ParentId = doc.Id;
                    dShare.UserOrGroupId = ds.UserOrGroup__c;
                    dShare.AccessLevel = ds.Access__c;
                    docShares.add(dShare);
                }
                /* Creating default shares */
                
            }
            if (tdaList.size()>0){
                insert tdaList;
            }
            
		    if (docShares.size()>0){
                insert docShares;
            }        
            
            
            
            
        }
        
    }
}