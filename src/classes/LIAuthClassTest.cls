@isTest 
public with sharing class LIAuthClassTest {
    @isTest
    public static void test() {
        LinkedIn_Urls__mdt LIsettings = new LinkedIn_Urls__mdt();
        LIsettings.DeveloperName = 'test';
        LIsettings.MasterLabel = 'test';
        LIsettings.CommunityReturnUrl__c = 'https://dk-canapi.cs79.force.com/alliance/s/profile/';
        LIsettings.RedirectUrl__c = 'testhttps://dk-canapi.cs79.force.com/alliance/apex/LinkedinStep2';


        
        
        test.starttest();
        LIAuthClass contr = new  LIAuthClass();
        contr.authorize();

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('https://www.linkedin.com/oauth/v2/accessToken?code=null&grant_type=authorization_code&client_id=78ynlh61c4r0x7&client_secret=UFIqzA3ZEIk4wrcY&redirect_uri=https://dk-canapi.cs79.force.com/alliance/apex/LinkedinStep2','LIauth');

        multimock.setStaticResource('https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))&oauth2_access_token=token', 'LIGetPhoto');
        multimock.setStaticResource('https://media-exp1.licdn.com/dms/image/C4E03AQEQFEvvD9x_Qw/profile-displayphoto-shrink_800_800/0?e=1587600000&v=beta&t=S5XcJmhD0mIqculoh6hwL83LbAurojDk3yPd5Oy68UI','LIGetPhoto');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);

   
        contr.authorizationLinkedinStep2();
        test.stopTest();


    }
}