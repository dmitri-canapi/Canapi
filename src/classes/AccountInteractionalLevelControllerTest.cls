@IsTest 
private with sharing class AccountInteractionalLevelControllerTest {
    
    @IsTest
    private static void test1() {
        Account a = new Account(Name= 'interaction acc');
        insert a;
        AccountInteractionalLevelController.fetchAcc(a.Id);
    }
}