@IsTest private with sharing class CheckParentAccountsTest {
    @IsTest
    private static void test1() {
        Account a = new Account(Name='CheckParentAccountsAcc');
        insert a;
        Account b = new Account(Name='CheckParentAccountsAcc2');
        insert b;
        a.ParentId = b.Id;
        update a;
        a.ParentId = null;
        update a;
        //delete a;

    }

}