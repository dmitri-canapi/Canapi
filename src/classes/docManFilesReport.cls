public without sharing class docManFilesReport {
    @ReadOnly @RemoteAction @AuraEnabled(cacheable=true)
    public static DocumentWrapper getDocs(String filter, Integer v_Offset, Integer v_pagesize) {
        filter = '%' + String.escapeSingleQuotes(filter) + '%';
        List < Document > documents = new List < Document >();
        Map <id, Document__c> docsmap = new Map <id,Document__c>([Select id, Name__c, Account__r.Name, CreatedDate, CreatedBy.Name, Notes__c, Board_Meeting__r.Name, Opportunity__r.Name, Documents_Folder_Template__r.Name from Document__c where Account__r.Name like: filter or Board_Meeting__r.Account__r.Name like: filter or Opportunity__r.Account.Name like: filter  order by Account__r.Name asc nulls last, Board_Meeting__r.Account__r.Name asc, Opportunity__r.Account.Name asc, Name__c asc limit :v_pagesize OFFSET :v_Offset]);
        integer totalSize = [select count() from Document__c where Account__r.Name like: filter or Board_Meeting__r.Account__r.Name like: filter or Opportunity__r.Account.Name like: filter];
        
        map <Id, String> docAttachmentMap = new map <Id, String>();
                
        set<Id> setDocumentIds = new set<Id>();

        map<Id, Id> mapContentDocumentIdToDocId = new map<Id, Id>();
        if(docsmap.size()>0){
            for(ContentDocumentLink fileLink:  [select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId in: docsmap.Keyset()]){
                setDocumentIds.add(fileLink.ContentDocumentId);
                mapContentDocumentIdToDocId.put(fileLink.ContentDocumentId, fileLink.LinkedEntityId);
                docAttachmentMap.put(fileLink.LinkedEntityId, fileLink.ContentDocumentId);
            }
        }
        

        map<Id, List<DownloadsWrapper>> mapDocDownloadHistory = new map<Id, List<DownloadsWrapper>>();

        for (DocumentDownloadCount__c dvc: [select Document__c, createdby.name, createddate FROM DocumentDownloadCount__c where Document__c in: docsmap.Keyset()]){
            if (mapDocDownloadHistory.containsKey(dvc.Document__c)){
                List<DownloadsWrapper> ds = mapDocDownloadHistory.get(dvc.Document__c);
                ds.add(new DownloadsWrapper(dvc));
                mapDocDownloadHistory.put(dvc.Document__c, ds);

            } else {
                List<DownloadsWrapper> ds = new List<DownloadsWrapper>();
                ds.add(new DownloadsWrapper(dvc));
                mapDocDownloadHistory.put(dvc.Document__c, ds);
            }
        }

        /*
        map<Id, Id> mapContentVersion = new map<Id, Id>();
        for(ContentVersion cv: [select Id, title, ContentDocumentId from ContentVersion where ContentDocumentId in: setDocumentIds]){
            mapContentVersion.put(cv.Id, cv.ContentDocumentId);
        }
        for (ContentVersionHistory cvh: [SELECT id, ContentVersionId, createdby.name, createddate FROM ContentVersionHistory where Field = 'contentVersionDownloaded' and ContentVersionId in: mapContentVersion.keySet()]){
            if (mapDocDownloadHistory.containsKey(mapContentDocumentIdToDocId.get(mapContentVersion.get(cvh.ContentVersionId)))){
                List<DownloadsWrapper> downloads = mapDocDownloadHistory.get(mapContentDocumentIdToDocId.get(mapContentVersion.get(cvh.ContentVersionId)));
                downloads.add(new DownloadsWrapper(cvh));
                mapDocDownloadHistory.put(mapContentDocumentIdToDocId.get(mapContentVersion.get(cvh.ContentVersionId)), downloads);

            } else {
                List<DownloadsWrapper> downloads = new List<DownloadsWrapper>();
                downloads.add(new DownloadsWrapper(cvh));
                mapDocDownloadHistory.put(mapContentDocumentIdToDocId.get(mapContentVersion.get(cvh.ContentVersionId)), downloads);
            }
        }*/



        Map<id, List <ViewsWrapper>> viewsMap = new Map<id, List <ViewsWrapper>> ();
        for (DocumentViewCount__c dvc: [select Document__c, createdby.name, createddate FROM DocumentViewCount__c where Document__c in: docsmap.Keyset()]){
            if (viewsMap.containsKey(dvc.Document__c)){
                List<ViewsWrapper> views = viewsMap.get(dvc.Document__c);
                views.add(new ViewsWrapper(dvc));
                viewsMap.put(dvc.Document__c, views);

            } else {
                List<ViewsWrapper> views = new List<ViewsWrapper>();
                views.add(new ViewsWrapper(dvc));
                viewsMap.put(dvc.Document__c, views);
            }
        }


        
        for (String doc: docsmap.KeySet()){
            List<DownloadsWrapper> downloads = new List<DownloadsWrapper>();
            List<ViewsWrapper> views = new List<ViewsWrapper>();
            if (mapDocDownloadHistory.containsKey(doc)){
                downloads = mapDocDownloadHistory.get(doc);
            }
            if (viewsMap.containsKey(doc)){
                views = viewsMap.get(doc);
            }
            String filePreviewId = (docAttachmentMap.containsKey(doc)) ? docAttachmentMap.get(doc) : null;
            documents.add(new Document(docsmap.get(doc), downloads, views, filePreviewId));

        }

        return new DocumentWrapper(documents, totalSize);
    }

    @AuraEnabled(cacheable=true)
       public static Integer getNext(Integer v_Offset, Integer v_pagesize){
           v_Offset += v_pagesize;
           return v_Offset;
       }

       @AuraEnabled(cacheable=true)
       public static Integer getPrevious(Integer v_Offset, Integer v_pagesize){
           v_Offset -= v_pagesize;
           return v_Offset;
       }

    public class DocumentWrapper {
        @AuraEnabled
        public List <Document> documents {get; set;}
        @AuraEnabled
        public Integer totalCount {get; set;}
        public DocumentWrapper (List <Document> documents, Integer totalCount){
            this.documents = documents;
            this.totalCount = totalCount;
        }
    }

    public class Document {
        @AuraEnabled
        public String docId {get; set;}
        @AuraEnabled
        public String filePreviewId {get; set;}
        @AuraEnabled
        public String docName {get; set;}
        @AuraEnabled
        public String AccountName {get; set;}
        @AuraEnabled
        public String AccountId {get; set;}
        @AuraEnabled
        public DateTime CreatedDate {get; set;}
        @AuraEnabled
        public String CreatedByName {get; set;}
        @AuraEnabled
        public String CreatedById {get; set;}
        @AuraEnabled
        public String Notes {get; set;}
        @AuraEnabled
        public String BoardMeetingName {get; set;}
        @AuraEnabled
        public String DocumentFolder {get; set;}
        @AuraEnabled
        public String DealName {get; set;}
        @AuraEnabled
        public Integer viewCount {get; set;}
        @AuraEnabled
        public Integer downloadCount {get; set;}
        @AuraEnabled
        public List <DownloadsWrapper> downloads {get; set;}
        @AuraEnabled
        public List <ViewsWrapper> views {get; set;}

        public Document(Document__c doc, List <DownloadsWrapper> downloads,  List <ViewsWrapper> views, String filePreviewId){
            this.docId = doc.Id;
            this.filePreviewId = filePreviewId;
            this.docName = doc.Name__c;
            this.AccountName = doc.Account__r.Name;
            this.AccountId = doc.Account__c != null? ('/' + doc.Account__c) : '';
            this.CreatedDate = doc.CreatedDate;
            this.CreatedByName = doc.CreatedBy.Name;
            this.CreatedById = '/' + doc.CreatedById;
            this.Notes = doc.Notes__c;
            this.BoardMeetingName = doc.Board_Meeting__r.Name;
            this.DocumentFolder = doc.Documents_Folder_Template__r.Name;
            this.DealName = doc.Opportunity__r.Name;
            this.viewCount = views.size();
            this.downloadCount = downloads.size();
            this.downloads = downloads;
            this.views = views;
        }
    }

    public class DownloadsWrapper {
        @AuraEnabled
        public String downloadCount {get; set;}
        @AuraEnabled
        public String CreatedByName {get; set;}
        @AuraEnabled
        public String CreatedById {get; set;}
        public DownloadsWrapper(DocumentDownloadCount__c cvh){
            this.downloadCount = string.valueOf(cvh.CreatedDate);
            this.CreatedByName = cvh.createdby.name;
            this.CreatedById = '/' + cvh.createdbyId;
        }
    }

    public class ViewsWrapper {
        @AuraEnabled
        public String viewCount {get; set;}
        @AuraEnabled
        public String CreatedByName {get; set;}
        @AuraEnabled
        public String CreatedById {get; set;}
        public ViewsWrapper(DocumentViewCount__c dvc){
            this.viewCount = string.valueOf(dvc.CreatedDate);
            this.CreatedByName = dvc.createdby.name;
            this.CreatedById = '/' + dvc.createdbyId;
        }
    }
}