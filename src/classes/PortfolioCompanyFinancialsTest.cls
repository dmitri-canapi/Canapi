@IsTest 
private with sharing class PortfolioCompanyFinancialsTest {
    @IsTest
    private static void test1() {
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Portfolio_Company').getRecordTypeId();
        
        account acc =  new Account(
                Name = 'Portfolio Account 1',
                RecordTypeId=recordTypeId
            );
        insert acc;

        integer currentQuarter = ( Date.Today().Month() / 3) + 1;
        String prevQuarter;
        Integer currentYear = System.Today().year();
        String thisQuarter = 'Q' + currentQuarter + ', ' + currentYear;


        Report_Period__c rp = new Report_Period__c();
        rp.quarter__c = thisQuarter;
        rp.Account__c = acc.Id;
        insert rp;

        Financial_Category__c fc = new Financial_Category__c(Name = 'Revenue', Type__c = 'Static', Account__c = acc.Id);
        insert fc;
        
        FinancialsFeatureDHTMLXController.createChartOfAccounts('','ARR', String.ValueOf(fc.Id),'Percentage','',false,'None',null,acc.Id);
        
        Chart_of_Accounts__c chart = [select id from Chart_of_Accounts__c limit 1];
        FF_CalculateFormulas.firstRun = true;
        FinancialsFeatureDHTMLXController.setFinancials(chart.Id, rp.Id,'5','Percentage');

        PortfolioCompanyFinancials.getCapTableData(thisQuarter);
    }
}