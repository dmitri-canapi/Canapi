public class linkedinAPIcalls {
    @AuraEnabled
    public static String getCompany(String companyName) {
        List<Saved_Company__c> savedCompanies = [SELECT id, Name, System_Name__c, Site_Name__c, UserID__c, Logo_URL__c, Description__c FROM Saved_Company__c 
                                             WHERE UserID__c =: System.UserInfo.getUserId() AND System_Name__c = :companyName];   
        CompanyInfo ci;
        if(!savedCompanies.isEmpty()) {
            Saved_Company__c sp = savedCompanies.get(0);
            ci = new CompanyInfo();
            ci.name = sp.Name;
            ci.system_name = sp.System_Name__c;
            ci.logo_url = sp.Logo_URL__c;
            ci.description = sp.Description__c;
        }
        return JSON.serialize(ci);
    }
    
    public class CompanyInfo {
        public String name {get; set;}
        public String system_name {get; set;}
        public String logo_url {get; set;}
        public String description {get; set;}
    }
    
    public static List<Object> getSearchList(String searchString, String token) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.linkedin.com/v1/company-search:(companies:(id,name,logo-url,description))?keywords=' + searchString + '&oauth2_access_token=' + token + '&format=json');
        req.setMethod('GET');
        HTTPResponse res = http.send(req);
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> companiesMap = (Map<String, Object>) respMap.get('companies');
        return (List<Object>) companiesMap.get('values');
    }
    
    @AuraEnabled
    public static String getCompanyList() {
        List<Saved_Company__c> savedCompanies = [SELECT id, System_Name__c FROM Saved_Company__c 
                                             WHERE UserID__c =: System.UserInfo.getUserId() AND Site_Name__c = 'Linkedin' ORDER BY Name ASC];
        List<String> listOfSystemNames = new List<String>();
        for(Saved_Company__c sp : savedCompanies) {
            listOfSystemNames.add(sp.System_Name__c);
        }
        return JSON.serialize(listOfSystemNames);
    }
    
    /*@AuraEnabled
    public static String getPosts(String companyName, String token) {
        String tmpBearer = token;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.linkedin.com/v1/companies/' + companyName + '/updates?oauth2_access_token=' + tmpBearer +'&format=json');
        req.setMethod('GET');
        HTTPResponse res = http.send(req);
        String body = res.getBody();
        
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(body);
        List<Object> postsList = (List<Object>) respMap.get('values');
        List<Object> newPosts = new List<Object>();
        for(Object o : postsList) {
            Post newPost = new Post();
            Map<String, Object> tmpMap = (Map<String, Object>) o;
            Map<String, Object> tmpMap1 = (Map<String, Object>) tmpMap.get('updateContent');
            Map<String, Object> tmpMap2 = (Map<String, Object>) tmpMap1.get('company');
            newPost.user_name = (String) tmpMap2.get('name');
            newPost.url = 'https://www.linkedin.com/organization/' + companyName;
            
            Map<String, Object> tmpMap3 = (Map<String, Object>) tmpMap1.get('companyStatusUpdate');
            Map<String, Object> tmpMap4 = (Map<String, Object>) tmpMap3.get('share');
            newPost.message = (String) tmpMap4.get('comment');
            newPost.profile_image = 'https://media.licdn.com/mpr/mpr/shrinknp_100_100/AAEAAQAAAAAAAAeSAAAAJDgxMjI2ZGMwLWU3ODYtNDRjNy1iNmUyLTM2MmRmZTg1ZmFhNw.png';
            newPosts.add(newPost);
        }
        
        return JSON.serialize(newPosts);
    }*/
}