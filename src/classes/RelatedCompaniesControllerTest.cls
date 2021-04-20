@isTest 
private with sharing class RelatedCompaniesControllerTest {
    static testMethod void getAccs() {
        Account a = new Account(name='parentAcc');
        insert a;
        RelatedCompaniesController.getAccounts(a.id);
    }
}