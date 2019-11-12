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
}