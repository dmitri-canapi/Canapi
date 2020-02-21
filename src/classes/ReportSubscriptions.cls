public with sharing class ReportSubscriptions {

    @AuraEnabled
    public static List <ReportWrapper> getReports (){
        List <ReportWrapper> reps = new List <ReportWrapper>();
        map <String, String> subsMap = new map <String, String> ();
        for (ReportSubscription__c rs: [select ReportId__c,Subscribed__c  from ReportSubscription__c where User__c =: UserInfo.getUserId()]){
            subsMap.put(rs.ReportId__c, rs.Subscribed__c);
        }

        List <Report> reportsIn = [select id, Name, Owner.Name, Description  from Report order by Owner.Name asc, name asc limit 200];
        
        set<ID> filterList = (new Map<Id,Report>(reportsIn)).keySet();

        // Query to see if current user has record access
        List<userRecordAccess> accessResults = [SELECT RecordId FROM UserRecordAccess  WHERE UserId = :userInfo.getUserId()
                                                AND RecordId IN :filterList
                                                AND HasReadAccess = true limit 200]; // need to split into parts (limits)

        if (reportsIn.size()>200){
            reportsIn = [select id, Name, Owner.Name, Description  from Report order by Owner.Name asc, name asc limit 200 offset 200];
            
            set<ID> filterList2 = (new Map<Id,Report>(reportsIn)).keySet();

            // Query to see if current user has record access
            List<userRecordAccess> accessResults2 = [SELECT RecordId FROM UserRecordAccess  WHERE UserId = :userInfo.getUserId()
                                                    AND RecordId IN :filterList2
                                                    AND HasReadAccess = true limit 200];
            accessResults.addAll(accessResults2);
       }

        // Create a lookup
        set<ID> validIds = new Set<ID>();
        for (userRecordAccess ura: accessResults) {
            validIds.add(ura.RecordId);
        }

        
        for (Report theReport:reportsIn) {
            if (validIds.contains(theReport.id)) {
                ReportWrapper rw = new ReportWrapper (theReport, subsMap.containsKey(theReport.Id)? subsMap.get(theReport.Id) : 'Unsubscribed');
                reps.add(rw);
            }
        }

        return reps;
    }
    
    
    @AuraEnabled
    public static void updateSubscription(String reportId, String subscription){
        ReportSubscription__c rs = new ReportSubscription__c();
        try {
            rs = [select id from ReportSubscription__c where ReportId__c =: reportId and User__c =: UserInfo.getUserId()];
        } catch (exception e){}
        rs.User__c = UserInfo.getUserId();
        rs.ReportId__c = reportId;
        rs.Subscribed__c = subscription;
        upsert rs;
    }
    
     public class ReportWrapper {
        @AuraEnabled public Report rep { get; set;}
        @AuraEnabled public String Subscription { get; set;}
        public ReportWrapper (Report rep, String Subscription){
            this.rep = rep;
            this.Subscription = Subscription;
        }
    }
    
}