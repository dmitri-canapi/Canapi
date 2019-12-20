@isTest() public class TermsOfServiceTest {
    static testMethod void testMethod1() {
        Terms_of_Service__mdt mt = new Terms_of_Service__mdt ();
        mt.HTML_code__c = 'test';
        mt.MasterLabel = 'test';
        mt.DeveloperName = 'test';

        TermsOfService.getTermsState();
        TermsOfService.acceptTerms();
    }
}