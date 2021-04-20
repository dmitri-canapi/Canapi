global class FinancialsRequestScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        
        FinancialsCreateRequestBatch b = new FinancialsCreateRequestBatch(); 
        database.executebatch(b,100);
    }

    /*
    to run every hour:
        String CRON_EXP = '0 0 * * * ?';
        FinancialsRequestScheduler sch = new FinancialsRequestScheduler();
        system.schedule('Create Financials Request', CRON_EXP, sch);
    */
}