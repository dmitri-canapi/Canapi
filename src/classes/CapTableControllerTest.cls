@IsTest
public class CapTableControllerTest {

    @IsTest
    private static void testSortRoundRecords() {
        
        List<String> orderedRoundNames = new List<String>();
        for (Schema.PicklistEntry pe : Round__c.Round__c.getDescribe().getPicklistValues()) {
            orderedRoundNames.add(pe.getValue());
        }
        
        // build a list in complete backwards order
        List<Round__c> roundsToBeSorted = new List<Round__c>();
        for (Integer i=orderedRoundNames.size()-1; i>-1; i--) {
            roundsToBeSorted.add(
                new Round__c(
                    Round__c = orderedRoundNames[i],
                    Series_Type__c = 'c'
                )
            );
            roundsToBeSorted.add(
                new Round__c(
                    Round__c = orderedRoundNames[i],
                    Series_Type__c = 'a'
                )
            );
        }
        
        List<Round__c> originalUnsortedRounds = roundsToBeSorted.clone();
        
        CapTableController.sortRoundRecords(roundsToBeSorted);
        
        Integer backwardIndex = originalUnsortedRounds.size()-1;
        for (Integer i=0; i<roundsToBeSorted.size(); i++) {
            System.assertEquals(originalUnsortedRounds[backwardIndex].Round__c, roundsToBeSorted[i].Round__c);
            System.assertEquals(originalUnsortedRounds[backwardIndex].Series_Type__c, roundsToBeSorted[i].Series_Type__c);
            backwardIndex--;
        }
    }
    @IsTest
    private static void testgetCapTableData() {
        account a = new account(name='test');
        insert a;
        
        Round__c round = new Round__c();
        round.Target_Company__c= a.id;
        round.Series_Type__c='test';
        round.Share_Price__c=1;
        insert round;
        
        CapTableController.setDollarAmount(a.id,round.id,500,'All');
        CapTableController.setDollarAmount(a.id,round.id,500,'Non-Voting');
        CapTableController.setDollarAmount(a.id,round.id,500,'Voting');
        CapTableController.setShares(a.id,round.id,500,700);
        
        /*Investment__c inv = new Investment__c();
        inv.Investor__c=a.id;
        inv.Round__c=round.id;
        insert inv;*/
        
        CapTableController.getCapTableData(a.id,'All');
        CapTableController.getCapTableData(a.id,'Voting');
        CapTableController.getCapTableData(a.id,'Non-Voting');
        CapTableController.setDollarAmount(a.id,round.id,500,'Voting');
        CapTableController.setShares(a.id,round.id,500,700);
        system.debug(CapTableController.hasRounds(a.id));
        CapTableController.addShareholder(a.id,'t e s t - 2019',a.id);
        
        CapTableController.deleteSeries (round.Id);
        CapTableController.deleteShareholder (a.Id,a.Id);
        system.debug(CapTableController.getCommunityAccId());
        
        
        }
}