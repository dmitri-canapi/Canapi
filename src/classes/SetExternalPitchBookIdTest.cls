@IsTest
public class SetExternalPitchBookIdTest {
    @IsTest
    private static void test() {
        Account a = new Account (Name='test', pbk__pbId__c='test',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('prospect').getRecordTypeId());
        insert a;
        a.pbk__pbId__c='test1';
        a.Updating_By_Skyvia__c = true;
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Bank_LP').getRecordTypeId();
        update a;
    }
}