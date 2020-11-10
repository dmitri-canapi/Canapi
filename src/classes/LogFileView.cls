global with sharing class LogFileView {
    @RemoteAction
    global static void logView (String recId){
        system.debug(recId);
        List <DocumentViewCount__c> views = new List <DocumentViewCount__c>();
        for(ContentDocumentLink fileLink:  [select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where ContentDocumentId =:recId]){
            if (fileLink.LinkedEntityId.getSObjectType().getDescribe().getName()=='Document__c') {
                views.add(new DocumentViewCount__c (Document__c = fileLink.LinkedEntityId));
            }

        }
        insert views;
    }
}