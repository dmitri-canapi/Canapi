@IsTest
public class SetContactExternalPitchBookIdTest {
    @IsTest
    private static void test() {
        CollaborationGroup cg = new CollaborationGroup(Name='Fintech Leads',CollaborationType='Public');
        insert cg;
        
        Contact c = new Contact (LastName='test', pbk__pbId__c='test');
        insert c;
        c.pbk__pbId__c='test1';
        update c;
    }
}