public with sharing class FinancialsRequestReportController {
    private final Financials_Change_Request__c FCR;

    public FinancialsRequestReportController(ApexPages.StandardController controller) {
        //this.FCR = (Financials_Change_Request__c)controller.getRecord();
        Id fcrId = (Id) System.currentPageReference().getParameters().get('id');  
        system.debug(System.currentPageReference().getParameters().get('id'));
        //system.debug((Financials_Change_Request__c)controller.getRecord());
        this.FCR = [SELECT 
        Id,
        Account__c,
        Account__r.Name,
        Requestor__r.Name,
        Requestor__c,
        CreatedDate
         FROM Financials_Change_Request__c WHERE Id = :fcrId];
    }

    public List <Financials_Verification__c> getVerifications() {
        return [
            select id, 
            Financials__r.Chart_of_Accounts__r.Name, 
            Financials__r.Chart_of_Accounts__r.Type__c,
            Financials__r.Report_Period__r.Quarter__c,
            Value__c,
            Financials__r.Value__c,
            TextValue__c,
            Financials__r.TextValue__c,
            DateValue__c,
            Financials__r.DateValue__c
            from Financials_Verification__c
            where Financials_Change_Request__c=: FCR.Id 
            order by Financials__r.Report_Period__r.Quarter__c, Financials__r.Chart_of_Accounts__r.Name
            ];
    }

}