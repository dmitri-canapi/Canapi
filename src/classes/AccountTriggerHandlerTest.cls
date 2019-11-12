@isTest
private class AccountTriggerHandlerTest {
    @testSetup
    static void createTestData() {
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account 1'), 
            new Account(Name = 'Test Account 2')
        };
        insert testAccounts;
    }

    @isTest
    static void geocodeAccountsTest() {
        List<Account> testAccounts = [
            SELECT Id, Use_Google_to_Geocode__c 
            FROM Account
        ];

        for (Account testAccount : testAccounts) {
            testAccount.Use_Google_to_Geocode__c = true;
        }

        Test.startTest();

        AccountTriggerHandler handler = new AccountTriggerHandler(testAccounts, null, null, null, false, true);
        handler.geocodeAccounts();

        Test.stopTest();
    }
}