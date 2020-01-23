@IsTest
public class CommunityPageHeaderCtrlTest {
    @IsTest
    private static void test1() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        contact c = new contact (LastName='test', accountId = acc.Id);
        insert c;
        
        Round__c round = new Round__c();
        round.Series_Type__c = 'test';
        round.Target_Company__c = acc.Id;
        //round.pbk_dealid__c = 'roundId';
        //round.pbk_pbId__c = 'accountId';
        insert round;
        
        Investment__c inv = new Investment__c();
        //inv.pbk_dealid__c = 'roundId';
        //inv.pbk_pbId__c = 'invId';
        inv.Investor__c = acc.Id;
        inv.Round__c = round.Id;
        insert inv;

        CommunityPageHeaderCtrl.getInitValues(acc.Id);
        
        CommunityPageHeaderCtrl.getInitValues(round.Id);
        
        CommunityPageHeaderCtrl.getInitValues(inv.Id);
        
        CommunityPageHeaderCtrl.getInitValues(c.Id);
    }
}