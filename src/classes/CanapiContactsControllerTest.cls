@isTest public class CanapiContactsControllerTest {
    static testMethod void testMethod1() {
        account a = new account(name='Canapi');
        insert a;
        contact c = new contact(LastName='test', AccountId = a.Id);
        insert c;
        CanapiContactsController.getContacts();
    }
}