@IsTest(seeAllData=true)
public class SetCommitmentStageOnAccountTestClass {
    @IsTest
    private static void test() {
        account a = new account(name='test - 2019 - 1');
        insert a;
        
        Fund__c f = new Fund__c(name='test - 2019 - 1');
        insert f;
        
        Commitment__c c = new Commitment__c();
        c.Account__c = a.Id;
        c.Fund__c = f.Id;
        c.Commitment_Stage__c = 'Interested';
        insert c;
    }
}