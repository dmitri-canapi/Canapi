@IsTest
public with sharing class CommunityLoginControllerTest {
    
    @IsTest
    private static void test1() {
        CommunityLoginController.checkPortal('test@test.com', 'test');
        CommunityLoginController.forgotPassowrd('test@test.com');
        CommunityLoginController.getTerms();
    }

}