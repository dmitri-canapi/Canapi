@isTest(SeeAllData=true) public class ReportsToEmailControllerTest {
    static testMethod void testMethod1() {
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId = [SELECT  Id,  DeveloperName FROM Report LIMIT 1].Id;
        rc.getReportResult();
    }
}