@isTest(SeeAllData=true) public class ReportSubscriptionsTest {
    static testMethod void testMethod1() {

        String rptId = [SELECT  Id,  DeveloperName FROM Report LIMIT 1].Id;
        String rptId2 = [SELECT  Id,  DeveloperName FROM Report LIMIT 1 offset 1].Id;
        String rptId3 = [SELECT  Id,  DeveloperName FROM Report LIMIT 1 offset 2].Id;
        ReportSubscription__c rs = new ReportSubscription__c (ReportId__c = rptId, Subscribed__c = 'Weekly', User__c = UserInfo.getUserId());
        insert rs;
        ReportSubscription__c rs2 = new ReportSubscription__c (ReportId__c = rptId2, Subscribed__c = 'Monthly', User__c = UserInfo.getUserId());
        insert rs2;
        ReportSubscription__c rs3 = new ReportSubscription__c (ReportId__c = rptId3, Subscribed__c = 'Daily', User__c = UserInfo.getUserId());
        insert rs3;

        ReportSubscriptions.getReports();

        ReportSubscriptions.updateSubscription(rptId2, 'Monthly');

        test.starttest();
        ReportShedulerMonthly repSchMonth = new ReportShedulerMonthly ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, repSchMonth);
        ReportShedulerWeekly repSchWeek = new ReportShedulerWeekly ();   
        String chron2 = '0 0 23 * * ?';        
        system.schedule('Test Sched 2', chron2, repSchWeek);
        ReportShedulerDaily repSchD = new ReportShedulerDaily ();   
        String chron3= '0 0 23 * * ?';        
        system.schedule('Test Sched 3', chron3, repSchD);
        test.stopTest();
 
    }

    static testMethod void testMethod2() {
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId = [SELECT  Id,  DeveloperName FROM Report LIMIT 1].Id;
        rc.getReportResult();
        rc.getReportName();
        system.debug(rc.baseUrl);
    }
}