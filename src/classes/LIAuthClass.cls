public class LIAuthClass {
    private static String communityRetUrl = [select CommunityReturnUrl__c from LinkedIn_Urls__mdt limit 1].CommunityReturnUrl__c + UserInfo.getUserId();
    private static String linkedin_redirect_uri = [select RedirectUrl__c from LinkedIn_Urls__mdt limit 1].RedirectUrl__c;
    
	private static String linkedin_client_id = '78ynlh61c4r0x7';
    private static String linkedin_client_secret = 'UFIqzA3ZEIk4wrcY';

    public String photoUrl { get; set; }


    public LIAuthClass (){
        photoUrl = [select fullphotourl from User where id =: UserInfo.getUserId() limit 1].fullphotourl;
    }
    
   
    
    //---------------------------- Linkedin authorization ----------------------------------------------------------

    public PageReference authorize() {
        String auth_url = 'https://www.linkedin.com/oauth/v2/authorization';
        String params =  
            '?response_type=code' +
            '&client_id=' + linkedin_client_id + 
            '&redirect_uri=' + linkedin_redirect_uri + 
            //'&scope=' + encodingUtil.URLEncode('r_liteprofile r_emailaddress w_share rw_company_admin','UTF-8') +
            '&scope=' + encodingUtil.URLEncode('r_liteprofile','UTF-8') +
            '&state=DCEeFWf45A53sdfKef424';
        
        return new PageReference(auth_url + params);
    }

    
    public PageReference authorizationLinkedinStep2() {
        String TheCode = ApexPages.currentPage().getParameters().get('code');

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        String auth_url = 'https://www.linkedin.com/oauth/v2/accessToken';
        String params =  
            '?code=' + TheCode +
            '&grant_type=authorization_code' + 
            '&client_id=' + linkedin_client_id + 
            '&client_secret=' + linkedin_client_secret + 
            '&redirect_uri=' + linkedin_redirect_uri;
        
        req.setMethod('POST');
        req.setEndpoint(auth_url + params);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length', string.valueOf(req.getBody().length()));
        
        HTTPResponse resp = http.send(req);
        Map<String,Object> postsList = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
       

        req = new HttpRequest();
        http = new Http();
        req.setMethod('GET');
        req.setEndpoint('https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))&oauth2_access_token=' + String.ValueOf(postsList.get('access_token')));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length', string.valueOf(req.getBody().length()));
        resp = http.send(req);

        JSONParser parser = JSON.createParser(resp.getBody());
        string photoUrl;
        string userLIid;
        system.debug(resp.getBody());
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String currentPropertyName = parser.getText();
                if (currentPropertyName=='identifier'){
                    parser.nextValue();
                // Get the arrival time.
                system.debug(parser.getText());
                photoUrl = parser.getText();
                    
                } else if (currentPropertyName=='id'){
                    parser.nextValue();
                    // Get the arrival time.
                    system.debug(parser.getText());
                    userLIid = parser.getText();
                    
                }
                
            }
        }

        if (photoUrl != null){
            HttpRequest photoReq = new HttpRequest();
            Http photoHttp = new Http();
            photoReq.setMethod('GET');
            photoReq.setEndpoint(photoUrl);
            photoReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            photoReq.setHeader('Content-Length', string.valueOf(photoReq.getBody().length()));
            HTTPResponse photoResp = photoHttp.send(photoReq);
            blob userPic = photoResp.getBodyAsBlob();
            if (!Test.IsRunningTest()){
                ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(userPic, 'image/jpg', 'UserPic');  
                //ConnectApi.Photo photoProfile = ConnectApi.UserProfiles.setPhoto('0DB6A000000L064', '0051h000002gCOAAA2', fileUpload);
                ConnectApi.Photo photoProfile = ConnectApi.UserProfiles.setPhoto(null, UserInfo.getUserId(), fileUpload);
            }
        }

        if (userLIid!=null) {
            User u = new User(id = UserInfo.getUserId(), LinkedIn_Id__c = userLIid);
            update u;
        }

        return new PageReference(communityRetUrl + '?linkedin_token='+ (String) postsList.get('access_token'));
    }
}