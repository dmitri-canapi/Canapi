// asynchronously geocode accounts using the Google Maps API
//
// design goals:
//   - tolerate/work around Google Maps API limits (# of calls per unit of time, etc)
//   - avoid Salesforce governor limits (cumulative callout timeout, SOQL queries, SOQL row limit, DML row limit)
//   - successfully geocode all accounts even with batch insert/update of account records
//   - leave the decision about which records should be geocoded by Google (as opposed to by Salesforce) to clicks-based automation
//   - encapsulate the details of the Google Maps API in a reusable service class
public class AccountGeocoderQueueable implements Queueable, Database.AllowsCallouts {
    private Integer JOB_COUNT_LIMIT = 500;
    private Integer BATCH_SIZE = 20;

    private Set<Id> accountIds;
    private Integer jobCount;

    public List<Account> accounts;

    public AccountGeocoderQueueable(Set<Id> accountIds, Integer jobCount) {
        this.accountIds = accountIds;
        this.jobCount = jobCount;
        this.accounts = [
            SELECT Id, Name, Use_Google_to_Geocode__c, ShippingStreet, ShippingCity, ShippingState, 
                ShippingCountry, ShippingPostalCode, ShippingLongitude, ShippingLatitude
            FROM Account
            WHERE Use_Google_to_Geocode__c = true AND Id IN :accountIds
            ORDER BY CreatedDate ASC
            LIMIT :BATCH_SIZE];
    }

    public void execute(QueueableContext context) {
        Boolean enqueueNextBatch = false;

        if (accounts.isEmpty()) {
            System.debug('Geocoding complete');
        } 
        else if (jobCount > JOB_COUNT_LIMIT) {
            // this limit is necessary to prevent runaway execution of the job
            System.debug('Geocoding job limit exceeded, some accounts may remain unencoded. Look for accounts where Use_Google_to_Geocode__c = true.');
        }
        else {
            enqueueNextBatch = true;
            // process a batch of accounts needing geocoding
            List<Account> updateAccounts = new List<Account>();

            for (Account account : accounts) {
                String address = '';
                if (String.isNotBlank(account.ShippingStreet)) 
                    address += '\'' + account.ShippingStreet  + '\',';
                if (String.isNotBlank(account.ShippingCity)) 
                    address += '\'' + account.ShippingCity  + '\',';
                if (String.isNotBlank(account.ShippingState)) 
                    address += '\'' + account.ShippingState + '\',';
                if (String.isNotBlank(account.ShippingCountry)) 
                    address += '\'' + account.ShippingCountry + '\',';
                if (String.isNotBlank(account.ShippingPostalCode)) 
                    address += '\'' + account.ShippingPostalCode + '\'';
                address = address.removeEnd(',');
            
                GoogleMapsGeocodeResponse response;
                if (Test.isRunningTest()) {
                    // mock response object to avoid having to include http mock response
                    // in every test method that inserts test accounts
                    response = new GoogleMapsGeocodeResponse(0, 0, true, null);
                }
                else if (String.isBlank(address)) {
                    // don't bother calling the service if address is null
                    response = new GoogleMapsGeocodeResponse(null, null, true, null);
                }
                else {
                    // call the service
                    response = GoogleMapsService.geocode(address);
                }

                if (response.success) {
                    account.ShippingLatitude = response.latitude;
                    account.ShippingLongitude = response.longitude;
                    account.Use_Google_to_Geocode__c = false;
                    updateAccounts.add(account);
                }
                else {
                    // some errors due to API limits are expected - by ignoring them the affected
                    //   account(s) will be included in the next batch where they may succeed
                    System.debug('Google Maps API Geocoding error: ' + response.message);
                }
            }

            if (!updateAccounts.isEmpty()) {
                update updateAccounts;
            }
        }

        if (enqueueNextBatch && !Test.isRunningTest()) {
            // kick off next batch
            //   dev note: you may get a "Maximum stack depth has been reached." here when running in a 
            //   scratch org - seems to be a scratch org limit only
            System.enqueueJob(new AccountGeocoderQueueable(accountIds, jobCount + 1));
        }
    }
}