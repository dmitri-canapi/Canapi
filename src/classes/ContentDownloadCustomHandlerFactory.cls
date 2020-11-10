public class ContentDownloadCustomHandlerFactory implements Sfc.ContentDownloadHandlerFactory {
        public Sfc.ContentDownloadHandler getContentDownloadHandler(List<ID> ids, Sfc.ContentDownloadContext context) {
            Sfc.ContentDownloadHandler contentDownloadHandler = new Sfc.ContentDownloadHandler();
            List <id> ContentDocumentIds = new List <id>();
            for (ContentVersion cv : [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType FROM ContentVersion WHERE Id in: ids]){
                ContentDocumentIds.add(cv.ContentDocumentId);
            }
            
            List <DocumentDownloadCount__c> downloadsList = new List <DocumentDownloadCount__c>();

            if(ContentDocumentIds.size()>0){
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId in: ContentDocumentIds]) {
                    if(cdl.LinkedEntityId.getSObjectType() == Schema.Document__c.getSObjectType()) {
                        downloadsList.add(new DocumentDownloadCount__c(Document__c = cdl.LinkedEntityId));
                    }        
                }
            }
            insert downloadsList;
            contentDownloadHandler.isDownloadAllowed = true;       
            return contentDownloadHandler;
        }
    }