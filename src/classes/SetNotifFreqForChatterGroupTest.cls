@IsTest public class SetNotifFreqForChatterGroupTest {
	@IsTest
    private static void test1() {
        CollaborationGroup g = new CollaborationGroup(
            Name = 'test',
            CollaborationType = 'Public'
        );
        insert g;
        
        update [select id from CollaborationGroupMember limit 1];
    }
}