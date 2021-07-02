@IsTest 
public class CapTableDHTMLXControllerTest {

    
    @IsTest
    private static void testgetCapTableData() {
        account a = new account(name='test');
        insert a;
        account a2 = new account(name='test2');
        insert a2;
        account a3 = new account(name='test3');
        insert a3;
        
        CapTableDHTMLXController.AllowEditingUpdate(a.Id,true);
        
        Round__c round = new Round__c();
        round.Target_Company__c= a.id;
        round.Series_Type__c='test';
        round.Share_Price__c=1;
        
        CapTableDHTMLXController.saveNewRound(JSON.serialize(round));
        insert round;
        
        CapTableDHTMLXController.setDollarAmount(a.id,round.id,500,'All');
        CapTableDHTMLXController.setDollarAmount(a.id,round.id,500,'Non-Voting');
        CapTableDHTMLXController.setDollarAmount(a.id,round.id,500,'Voting');
        CapTableDHTMLXController.setShares(a.id,round.id,500,'All');
        CapTableDHTMLXController.setShares(a.id,round.id,500,'Voting');
        CapTableDHTMLXController.setShares(a.id,round.id,500,'Non-Voting');
        CapTableDHTMLXController.setShares(a2.id,round.id,500,'All');

        CapTableDHTMLXController.getCapTableData(a.id,'All','Shares');
        CapTableDHTMLXController.getCapTableData(a.id,'Voting','Dollars');
        CapTableDHTMLXController.getCapTableData(a.id,'Non-Voting','Percentage');
        
        CapTableDHTMLXController.getCapTableData(a.id,'All','Dollars');
        CapTableDHTMLXController.getCapTableData(a.id,'Voting' ,'Shares');
        CapTableDHTMLXController.getCapTableData(a.id,'Non-Voting','Percentage');
        
        CapTableDHTMLXController.getCapTableData(a.id,'All','Percentage');
        CapTableDHTMLXController.getCapTableData(a.id,'Voting','Percentage');
        CapTableDHTMLXController.getCapTableData(a.id,'Non-Voting' ,'Shares');
        CapTableDHTMLXController.setDollarAmount(a.id,round.id,500,'Voting');
        CapTableDHTMLXController.setAllShares(a.id,round.id,500,700);
        CapTableDHTMLXController.setAllShares(a3.id,round.id,500,700);
        system.debug(CapTableDHTMLXController.hasRounds(a.id));
        system.debug(CapTableDHTMLXController.hasRounds(round.id));
        CapTableDHTMLXController.addShareholder(null, 't e s t - 2019', null, 'parent - 2021',  a.id);
        CapTableDHTMLXController.getInvestment(a.id,round.id);

        CapTableDHTMLXController.updateRoundOrder(New List<Round__c>{round});

        CapTableDHTMLXController.importFile('U2VxdWVuY2UgTnVtYmVyLFJlY29yZCBJRCxDaGFydCBvZiBBY2NvdW50cyxDYXRlZ29yeSwzLzI2LzIwMjEsIlExLCAyMDIwIiwiUTIsIDIwMjAiLCJRMywgMjAyMCIsIlE0LCAyMDIwIiwiUTEsIDIwMjEiLCJRMiwgMjAyMSINCjQsYTByMWgwMDAwMDF2dzJUQUFRLGRzNTQsZHNmZHNmZHNmLDQsNCw0LDQsNCw0LDQNCixhMHIxaDAwMDAwMlZaWUtBQTQsaTMsZHNmZHNmZHNmLDAsMCwwLDAsMCwwLDANCixhMHIxaDAwMDAwMkRuYWJBQUMsQVJSLEV4cGVuc2UsMTAuNDUsMjAwLDUsNDAwLDUwMCw5MDAsOTAwDQosYTByMWgwMDAwMDJWWlk1QUFPLEFSUiBZT1ksRXhwZW5zZSwwLDAsMCwwLDAsMCwwDQosYTByMWgwMDAwMDF2dzJSQUFRLGV4cCxFeHBlbnNlLDAs',a.Id, 'All', 'Dollars');
        
        CapTableDHTMLXController.deleteSeries (round.Id);
        CapTableDHTMLXController.deleteShareholder (a.Id,a.Id);
        system.debug(CapTableDHTMLXController.getCommunityAccId());

        CapTableDHTMLXController.fetchLookUpValues('test','Account');
        
        
        
        
        
        }
}