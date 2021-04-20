@IsTest private with sharing class SetAccountLastModifiedTest {
    @IsTest
    private static void test1() {
        test.starttest();
        Account a = new Account(Name='CheckParentAccountsAcc',Heat__c = 'On Fire');
        insert a;
        Document__c d = new Document__c(Account__c = a.Id, Name__c='test');
        insert d;
        Opportunity o = new Opportunity(name='test',Account=a,StageName='Closing',CloseDate=System.today());
        insert o;
        Account b = new Account(Name='CheckParentAccountsAcc2',Last_Modified_Date_Interactive__c = DateTime.Now().AddDays(-11), Heat__c = 'On Fire');
        insert b;
        update a;        
        
        SetAccountWatchlistField sch = new SetAccountWatchlistField ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched' + String.valueOf(Datetime.now()), chron, sch);
        
        test.stopTest();
    }
}