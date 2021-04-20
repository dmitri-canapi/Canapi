@IsTest
public class FinancialsFeatureDHTMLXControllerTest {
    
    @testSetup static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc; 
        Report_Period__c rp = new Report_Period__c();
        rp.Date__c = system.today();
        rp.Account__c = acc.Id;
        insert rp;

        Financial_Category__c fc = new Financial_Category__c(Name = 'Revenue', Type__c = 'Static', Account__c = acc.Id);
        insert fc;
        
        FinancialsFeatureDHTMLXController.createChartOfAccounts('','test1', String.ValueOf(fc.Id),'Percentage','',false,'None',null,acc.Id);
        
        Chart_of_Accounts__c chart = [select id from Chart_of_Accounts__c limit 1];
        FF_CalculateFormulas.firstRun = true;
        FinancialsFeatureDHTMLXController.setFinancials(chart.Id, rp.Id,'5','Percentage');
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

        FinancialsFeatureDHTMLXController.requestFinReport(acc.Id);
        
        Financial_Category__c fc = new Financial_Category__c(Name = 'Metric', Type__c = 'Calculated',Account__c = acc.Id);
        insert fc;

        FinancialsFeatureDHTMLXController.getCatGridData(acc.Id);
        FinancialsFeatureDHTMLXController.setCategoryName(fc.Id,'test');
        FinancialsFeatureDHTMLXController.setCatData(fc.Id,'Calculated');
        FinancialsFeatureDHTMLXController.addCategory('test2', acc.Id);
        
        FF_CalculateFormulas.firstRun = true;
        FinancialsFeatureDHTMLXController.createChartOfAccounts('','test2', fc.Id, 'Percentage','{test1}*2',false,'None',null,acc.Id);
        FinancialsFeatureDHTMLXController.saveFinancialReport([select id, Report_Period__c, Chart_of_Accounts__c,DateValue__c from Financials__c], acc.Id);
        
        FF_CalculateFormulas.firstRun = true;
        FinancialsFeatureDHTMLXController.createChartOfAccounts('','test2', fc.Id, 'Percentage','{test1}*2',false,'None',null,acc.Id);
        
        Chart_of_Accounts__c chart = [select id from Chart_of_Accounts__c limit 1];

        FinancialsFeatureDHTMLXController.setFinancials(chart.Id, rp.Id, '1','Percentage');
        FinancialsFeatureDHTMLXController.setFinancials(chart.Id, rp.Id, '2','Percentage');
        
        
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

        FinancialsFeatureDHTMLXController.deleteCategory(fc.Id);
        FinancialsFeatureDHTMLXController.getUserFiles(UserInfo.getUserId());
        FinancialsFeatureDHTMLXController.prepareDocumentForUpload('text.txt', acc.Id, 'Q1, 2021');

        
        
    }
	
    @IsTest
    private static void test2() {
        

        Financials_Change_Request__c fcr = new Financials_Change_Request__c ();
        insert fcr;

        Financials_Verification__c fv = new Financials_Verification__c();
        fv.Financials__c = [select id from Financials__c limit 1].Id;
        fv.Financials_Change_Request__c = fcr.Id;
        insert fv;

        ApexPages.StandardController sc = new ApexPages.StandardController(fcr);
        

        PageReference pageRef = Page.FinancialsRequestReport;
        pageRef.getParameters().put('Id', String.valueOf(fcr.Id));
        Test.setCurrentPage(pageRef);
        FinancialsRequestReportController testAccPlan = new FinancialsRequestReportController(sc);
        testAccPlan.getVerifications();
        fcr.Status__c = 'Rejected';
        update fcr;

        Test.StartTest();
        FinancialsRequestScheduler sh1 = new FinancialsRequestScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test FinancialsRequestScheduler', sch, sh1);
        Test.stopTest();

        
    }
}