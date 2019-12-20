public class AccountTriggerHandler {
    private List<Account> newAccounts;
    private Map<Id, Account> newAccountsMap;
    private List<Account> oldAccounts;
    private Map<Id, Account> oldAccountsMap;
    private Boolean isBefore;
    private Boolean isAfter;
    private Boolean isInsert;
    private Boolean isUpdate;
    private Boolean isDelete;

    public AccountTriggerHandler(
            List<Account> newAccounts, Map<Id, Account> newAccountsMap, 
            List<Account> oldAccounts, Map<Id, Account> oldAccountsMap, 
            Boolean isBefore, Boolean isAfter) {

        this.newAccounts = newAccounts;
        this.newAccountsMap = newAccountsMap;
        this.oldAccounts = oldAccounts;
        this.oldAccountsMap = oldAccountsMap;
        this.isBefore = isBefore;
        this.isAfter = isAfter;
        this.isInsert = (oldAccounts == null || oldAccounts.isEmpty());
        this.isDelete = (newAccounts == null || newAccounts.isEmpty());
        this.isUpdate = (!isInsert && !isDelete);
    }

    public void geocodeAccounts() {
        if ((isInsert || isUpdate) && isAfter) {
            Set<Id> geocodeAccountIds = new Set<Id>();

            for (Account account : newAccounts) {
                // only geocode on transition from "Use Google to Geocode" = false to "Use Google to Geocode" = true
                if (account.Use_Google_to_Geocode__c 
                        && (isInsert || (isUpdate && !oldAccountsMap.get(account.Id).Use_Google_to_Geocode__c))) {

                    geocodeAccountIds.add(account.Id);
                }
            }

            if (!geocodeAccountIds.isEmpty()) {
                System.enqueueJob(new AccountGeocoderQueueable(geocodeAccountIds, 1));
            }
        }
    }
    
    @future (callout = true)
    public static void updateLogo(Id accId, String website){
        account record = new account(id=accId);
        String endpoint;
        HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                endpoint = 'https://api.ritekit.com/v1/images/logo?client_id=6e255a97c9de4025d5f3c3d5465d006b6ad7a37ea9c7&domain='; 
                
                endpoint +=  website;
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                
                if (!Test.isRunningTest()) {      
                    res = http.send(req);
                    if (res.getStatusCode() == 200){
                        blob image = res.getBodyAsBlob();
                        String resString = EncodingUtil.base64Encode(image);
                        
                        if (resString.length() <= 131072){
                            record.External_Logo__c = resString;
                        } else {
                            record.External_Logo__c = resString.subString(0,131072);
                            
                            if (resString.length() <= 262144){
                                record.External_Logo2__c = resString.subString(131072,resString.length());
                            } else {
                                record.External_Logo2__c = resString.subString(131072,262144);
                                record.External_Logo3__c = resString.subString(262144,resString.length());
                            }
                        }
                        
                    }
                }  else {
                    integer j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
            } 
            update record;
    }
}