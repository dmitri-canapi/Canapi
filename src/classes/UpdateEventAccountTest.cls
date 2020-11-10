@isTest public class UpdateEventAccountTest {

    static testMethod void testMethod1() {
        insert new Account (Name = '-');
        UpdateEventAccount sch = new UpdateEventAccount(); 
        sch.execute(null);
    }
}