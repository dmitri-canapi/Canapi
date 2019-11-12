trigger AccountTrigger on Account (after insert, after update) {
    AccountTriggerHandler handler = new AccountTriggerHandler(
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isAfter
    );
    handler.geocodeAccounts();
}