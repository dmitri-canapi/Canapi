@IsTest
public class CommunityDealsTest {
    @IsTest
    private static void test1() {
        List <Opportunity> opp = CommunityDeals.getFilteredDeals();
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Opportunity o = new Opportunity (name='test',Account=acc,StageName='Closing',CloseDate=System.today());
        insert o;
         map<String,String> oppMap = CommunityDeals.getOppMap(o.Id);
    }

}