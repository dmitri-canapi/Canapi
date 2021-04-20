public class ReportsToEmailController {
    public Id rptId { get; set; } // Here we will get the report Id from the VF Component
    public Integer trimTo { get {
            if (trimTo == null){
                trimTo = 1000;
                return trimTo;
            }
            else {
                return trimTo;
            }
        } set; }
    public boolean wasTrimmed { get; set; }    
    public String baseUrl { 
        get {
            if (baseUrl == null){
                String baseUrl = System.URL.getOrgDomainUrl().toExternalForm() +'/';
                return baseUrl;
            }
            else {
                return baseUrl;
            }
        }
        private set;}
    private transient Reports.ReportResults results; // It will hold the entire data of a report
 
    /*********************
     // Method Name : getReportResult
     // Description : Here we will get the data of a report and send to the VF Component
    /********************/
 
    public reportWrapper getReportResult() {
        // Here it will run the report with that report ID and adding the report data into results
        results = Reports.ReportManager.runReport(rptId, true);
        
        Reports.ReportFactWithDetails rwd; //(Reports.ReportFactWithDetails) results.getFactMap().get('0!T');
        //system.debug(rwd);
        List <Reports.ReportDetailRow> rwdList = new List <Reports.ReportDetailRow>();

        if (results.getFactMap().containsKey('0!T')){
            for (String key: results.getFactMap().keySet()){
                system.debug(key);
                rwd = (Reports.ReportFactWithDetails) results.getFactMap().get(key);
                rwdList.addAll(rwd.getRows());
            } 
        } else if (results.getFactMap().containsKey('T!T')){
            rwd = (Reports.ReportFactWithDetails) results.getFactMap().get('T!T');
            rwdList = rwd.getRows();
        }
        system.debug(results);
        system.debug(results.getFactMap());
        wasTrimmed = false;
        if (rwdList.size() > = trimTo){
                wasTrimmed = true;
                for(Integer i = rwdList.size() - 1; i >= 0; i--) {
                    if(i > = trimTo) {
                        rwdList.remove(i);
                    }
                }
                
            }

        /*Reports.ReportExtendedMetadata rpmtd = results.getReportExtendedMetadata();
        MAP<String,Reports.DetailColumn> d = rpmtd.getDetailColumnInfo();
        for (String rd: d.keySet()){
            system.System.debug(d.get(rd));
        }*/
        return new reportWrapper(results, rwdList);
    }

    public class reportWrapper  {
        public Reports.ReportResults fullrep  { get; set; }
        public List <Reports.ReportDetailRow> repDetails  { get; set; }
        public  reportWrapper (Reports.ReportResults fullrep, List <Reports.ReportDetailRow> repDetails){
            this.fullrep = fullrep;
            this.repDetails = repDetails;
        }
    }

    public String getReportName() {
        return [select Name from Report where id=:rptId].Name;
    }
}