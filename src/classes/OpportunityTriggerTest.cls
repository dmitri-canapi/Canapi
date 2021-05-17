@IsTest
public class OpportunityTriggerTest {
    @IsTest
    private static void test1() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Opportunity o = new Opportunity (name='test',Account=acc,StageName='Closing',CloseDate=System.today());
        insert o;
    }

}