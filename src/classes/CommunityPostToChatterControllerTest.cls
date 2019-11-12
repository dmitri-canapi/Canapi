@IsTest 
public class CommunityPostToChatterControllerTest {
	@IsTest
    private static void test() {
        CollaborationGroup cg = new CollaborationGroup(Name = 'My Group', CollaborationType = 'Public');
        insert cg;
        CollaborationGroupMember gm = new CollaborationGroupMember();

        CommunityPostToChatterController.getMyGroups();
    }
}