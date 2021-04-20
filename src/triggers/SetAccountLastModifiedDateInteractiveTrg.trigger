trigger SetAccountLastModifiedDateInteractiveTrg on Account (before insert, before update) {
    if(Trigger.isInsert) {
        for(Account a:Trigger.New) { 
           a.Last_Modified_Date_Interactive__c = System.Now();
        }
    }
    //system.debug(System.isBatch() );
    Set <Id> serviceIds = new Set<Id>();
    for(Service_Account_IDs__mdt sa: [select MasterLabel from Service_Account_IDs__mdt]){
        serviceIds.add(sa.MasterLabel);
    }
    if(Trigger.isUpdate && !System.isBatch() && !serviceIds.contains(UserInfo.getUserId())) {
        for(Account a: Trigger.New) { 
            if(Trigger.OldMap.get(a.Id).Last_Modified_Date_Interactive__c ==  a.Last_Modified_Date_Interactive__c){
                a.Last_Modified_Date_Interactive__c = System.Now();
            }
        }
    }
}