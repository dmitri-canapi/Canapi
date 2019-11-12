@isTest (SeeAllData=true)
public class AddCommunityUserToPublicGroupTest {
    @isTest
    public static void test() {
        user U1 = [select id from user where ProfileId='00e6A000000JXOi' and IsActive=true limit 1];
        user U2 = [select id from user where ProfileId='00e6A000000vI1M' and IsActive=true limit 1];
        update U1;
        update U2;
    }
}