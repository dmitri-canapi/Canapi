@IsTest
public class SetSeriesInvExtPBIdTest {
    @IsTest
    private static void test() {
        Account a = new Account (Name='test', pbk__pbId__c='test',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('prospect').getRecordTypeId());
        insert a;
        a.pbk__pbId__c='accountId';
        a.Updating_By_Skyvia__c = true;
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Bank_LP').getRecordTypeId();
        update a;
        
        Round__c round = new Round__c();
        round.Series_Type__c = 'test';
        round.Target_Company__c = a.Id;
        round.pbk_dealid__c = 'roundId';
        round.pbk_pbId__c = 'accountId';
        insert round;
        
        Investment__c inv = new Investment__c();
        inv.pbk_dealid__c = 'roundId';
        inv.pbk_pbId__c = 'invId';
        inv.Round__c = round.Id;
        insert inv;
        
        round.pbk_pbId__c = 'incorrectId';
        update round;
        
        inv.pbk_dealid__c = 'incorrectId';
        update inv;
    }
}