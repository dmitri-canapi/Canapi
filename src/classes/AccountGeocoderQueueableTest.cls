@isTest
private class AccountGeocoderQueueableTest {
    @isTest
    static void executeTest() {
        // this test depends on the account trigger to enqueues the job
        Test.startTest();

        List<Account> testAccounts = new List<Account>{
            new Account(
                Name = 'Test Account 1', 
                Use_Google_to_Geocode__c = true,
                ShippingStreet = '123 Anywhere St',
                ShippingCity = 'Cityville',
                ShippingState = 'North Carolina',
                ShippingCountry = 'United States',
                ShippingPostalCode = '20000'
            ), 
            new Account(
                Name = 'Test Account 2', 
                Use_Google_to_Geocode__c = true
            )
        };
        insert testAccounts;

        Test.stopTest();

        testAccounts = [
            SELECT Id, Use_Google_to_Geocode__c, ShippingLatitude, ShippingLongitude
            FROM Account
        ];

        System.assert(!testAccounts.isEmpty());
        System.assert(testAccounts[0].Use_Google_to_Geocode__c == false);
        System.assert(testAccounts[0].ShippingLatitude != null);
        System.assert(testAccounts[0].ShippingLongitude != null);
    }
}