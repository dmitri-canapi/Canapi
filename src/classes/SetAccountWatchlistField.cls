global with sharing class SetAccountWatchlistField implements Schedulable {
    global void execute(SchedulableContext sc) {
        SetAccountWatchlistFieldBatch b = new SetAccountWatchlistFieldBatch(); 
        database.executebatch(b,100);
    }

}