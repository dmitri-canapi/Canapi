trigger AccountTrigger on Account (after insert, after update) {
    AccountTriggerHandler handler = new AccountTriggerHandler(
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isAfter
    );
    handler.geocodeAccounts();

    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        integer i = 0;
        for (Account account : Trigger.new) {
            if((Trigger.isInsert && account.Website != null) || (Trigger.isUpdate &&  account.Website != null &&  account.Website != Trigger.oldMap.get(account.Id).Website) && i < 50){
                try{
                    AccountTriggerHandler.updateLogo(account.Id, account.Website);
                } catch(exception e){}
                i++;
            }
        }
    }
}