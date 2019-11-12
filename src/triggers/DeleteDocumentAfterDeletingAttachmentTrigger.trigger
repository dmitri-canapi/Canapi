trigger DeleteDocumentAfterDeletingAttachmentTrigger on ContentDocument (before delete) {
    List <String> cdList = new List <String>();
    for (ContentDocument cd : Trigger.old) {
        cdList.add(cd.Id);
    }
    List <String> delList = new List <String>();
    for(ContentDocumentLink cdl : [select id,LinkedEntityId from ContentDocumentLink where ContentDocumentId in:cdList]){
        if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName()=='Document__c')
        	delList.add(cdl.LinkedEntityId);
    }
   
    if(delList.size()>0){
        delete [select id from Document__c where id in:delList];
    }
}