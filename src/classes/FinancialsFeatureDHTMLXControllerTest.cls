@IsTest
public class FinancialsFeatureDHTMLXControllerTest {
    
    @testSetup static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc; 
        Report_Period__c rp = new Report_Period__c();
        rp.Date__c = system.today();
        rp.Account__c = acc.Id;
        insert rp;
        
        FinancialsFeatureDHTMLXController.createChartOfAccounts('test1', 'Revenue','',null,acc.Id);
        
        Chart_of_Accounts__c chart = [select id from Chart_of_Accounts__c limit 1];
        FF_CalculateFormulas.firstRun = true;
        FinancialsFeatureDHTMLXController.setFinancials(chart.Id, rp.Id,5);
        FF_CalculateFormulas.firstRun = true;
    }
    
    @IsTest
    private static void test1() {
        /*Account acc = [select id from account];*/
        Account acc = new Account(Name = 'Canapi');
        insert acc;
        
        Report_Period__c rp = new Report_Period__c();
        rp.Date__c = system.today();
        rp.Account__c = acc.Id;
        FinancialsFeatureDHTMLXController.createReportPeriod(JSON.serialize(rp), acc.Id, '');
        insert rp;
        
        
        FF_CalculateFormulas.firstRun = true;
        FinancialsFeatureDHTMLXController.createChartOfAccounts('test2', 'Metric','{test1}*2',null,acc.Id);
        FF_CalculateFormulas.firstRun = true;
        FinancialsFeatureDHTMLXController.createChartOfAccounts('test2', 'Metric','{test1}*2',null,acc.Id);
        
        Chart_of_Accounts__c chart = [select id from Chart_of_Accounts__c limit 1];

        FinancialsFeatureDHTMLXController.setFinancials(chart.Id, rp.Id, 1);
        FinancialsFeatureDHTMLXController.setFinancials(chart.Id, rp.Id, 2);
        
        FinancialsFeatureDHTMLXController.AllowEditingUpdate (acc.Id, true);
        
        FinancialsFeatureDHTMLXController.getCapTableData('');

        FinancialsFeatureDHTMLXController.createTemplate('test', acc.Id);
        FinancialsFeatureDHTMLXController.createTemplate('test', acc.Id);
        String templId = [select id from Chart_of_Accounts_Template__c limit 1].Id;
        FinancialsFeatureDHTMLXController.applyTemplate(templId, acc.Id);
        FinancialsFeatureDHTMLXController.getTemplatesData();
        FinancialsFeatureDHTMLXController.getTemplatesPreview(templId);
        FinancialsFeatureDHTMLXController.getSavedTemplates();
        FinancialsFeatureDHTMLXController.deleteTemplate(templId);
        
        FinancialsFeatureDHTMLXController.deleteChartOfAccounts(chart.Id);
        FinancialsFeatureDHTMLXController.deleteReportPeriod(rp.Id);
        
    }
	
    @IsTest
    private static void test2() {
        //Financials__c fin = new Financials__c();
        
    }
}