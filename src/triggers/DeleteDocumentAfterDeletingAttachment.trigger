trigger DeleteDocumentAfterDeletingAttachment on ContentDocumentLink (after delete) {
    /*system.debug('DELETING');
    List <String> delList = new List <String>();
    for (ContentDocumentLink cdl : Trigger.old) {
        if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName()=='Document__c'){
            delList.add(cdl.LinkedEntityId);
        }
 
    }
    if(delList.size()>0){
        delete [select id from Document__c where id in:delList];
    }*/
}