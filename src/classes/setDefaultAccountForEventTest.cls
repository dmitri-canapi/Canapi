@IsTest public class setDefaultAccountForEventTest {
	@IsTest
    private static void test1() {
        Account a = new Account(Name='-');
        insert a;
        Contact c = new Contact(LastName='test', AccountId = a.Id);
        insert c;
        
        Event e = new Event();
        e.Subject = 'test';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now();
        e.DurationInMinutes = 0;
        insert e;
        
        Event e2 = new Event();
        e2.Subject = 'test';
        e2.WhoId = c.Id;
        e2.StartDateTime = system.now();
        e2.EndDateTime = system.now();
        e2.DurationInMinutes = 0;
        insert e2;
        
    }
}