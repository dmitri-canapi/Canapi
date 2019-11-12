public class LIAuthClass {
    private static String lightningURL = 'https://canapi--dk.lightning.force.com/one/one.app#/n/LinkedIn_Outh';
    
	private static String linkedin_client_id = '78ynlh61c4r0x7';
    private static String linkedin_client_secret = 'UFIqzA3ZEIk4wrcY';
    private static String linkedin_redirect_uri = 'https://canapi--dk--c.cs79.visual.force.com/apex/LinkedinStep2';
    
   
    
    //---------------------------- Linkedin authorization ----------------------------------------------------------
    @AuraEnabled
    public static String authorizationLinkedinStep1(){
        String auth_url = 'https://www.linkedin.com/oauth/v2/authorization';
        String params =  
            '?response_type=code' +
            '&client_id=' + linkedin_client_id + 
            '&redirect_uri=' + linkedin_redirect_uri + 
            '&scope=' + encodingUtil.URLEncode('r_liteprofile r_emailaddress w_share rw_company_admin','UTF-8') +
            '&state=DCEeFWf45A53sdfKef424';
        
        return auth_url + params;
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
        system.debug(postsList.get('access_token'));
        system.debug(postsList);
        try {
            Saved_Company__c sc = [select id, AccessToken__c from Saved_Company__c limit 1];
            sc.AccessToken__c = String.ValueOf(postsList.get('access_token'));
            update sc;
        } catch (exception e){
            Saved_Company__c sc = new Saved_Company__c(Name='Linked In', AccessToken__c = String.ValueOf(postsList.get('access_token')));
            insert sc;
        }
        return new PageReference(lightningURL + '?linkedin_token='+ (String) postsList.get('access_token'));
    }
    
    
   
    
    
    
    @AuraEnabled
    public static String linkedinSearch(String searchString, String token) {
        List<Object> resp = linkedinAPIcalls.getSearchList(searchString, token);
        List<Object> itemList = new List<Object>();
        for(Object o : resp) {
            Map<String, Object> itemMap = (Map<String, Object>) o;
            SearchItem si = new SearchItem();
            si.name = (String) itemMap.get('name');
            si.system_name = String.valueOf((Integer) itemMap.get('id'));
            si.logo_url = (String) itemMap.get('logoUrl');
            si.description = (String) itemMap.get('description');
            if(si.description.length() >= 296) {
                si.description = si.description.substring(0,295) + '...';
            }
            itemList.add(si);
        }
        return JSON.serialize(itemList);
    }

    public class SearchItem {
        public String name {get; set;}
        public String system_name {get; set;}
        public String logo_url {get; set;}
        public String description {get; set;}
    }
    
    
    
    @AuraEnabled
    public static String loadSaved() {
        List<Saved_Company__c> savedPeople = [SELECT id, Name, System_Name__c, Site_Name__c, UserID__c, Logo_URL__c, Description__c FROM Saved_Company__c WHERE UserID__c =: System.UserInfo.getUserId()];
        Map<String, Saved_Company__c> linkedinSaved = getMapForSite(savedPeople, 'Linkedin');
        
        List<List<Object>> listForReturn = new List<List<Object>>();

        listForReturn.add(getObjectList(linkedinSaved.values()));
        
        return JSON.serialize(listForReturn);
    }
    
    @AuraEnabled
    public static String saveSelected(String linkedinListString) {

        List<Object> linkedinList = (List<Object>) JSON.deserializeUntyped(linkedinListString);
        
        List<Saved_Company__c> savedPeople = [SELECT id, Name, System_Name__c, Site_Name__c, UserID__c FROM Saved_Company__c WHERE UserID__c =: System.UserInfo.getUserId()];
        

        Map<String, Saved_Company__c> linkedinSaved = getMapForSite(savedPeople, 'Linkedin');

        List<Saved_Company__c> peopleForInsert = getListForInsert(linkedinSaved, linkedinList, 'Linkedin');
        
        List<Saved_Company__c> peopleForDelete = linkedinSaved.values();
        
        try {
            if(!peopleForInsert.isEmpty()) {
                insert peopleForInsert;
            }
            if(!peopleForDelete.isEmpty()) {
                delete peopleForDelete;
            }
        } Catch(DMLException e) {
            return e.getMessage();
        }
    	return null;
    }
    
    
    //---------------------------- Help methods ----------------------------------------------------------
    //
    private static List<Object> getObjectList(List<Saved_Company__c> savedPeople) {
        List<Object> listForReturn = new List<Object>();
        
        for(Saved_Company__c sp : savedPeople) {
            Map<String, Object> objectMap = new Map<String, Object>();
            objectMap.put('name', sp.Name);
            objectMap.put('system_name', sp.System_Name__c);
            objectMap.put('logo_url', sp.Logo_URL__c);
            objectMap.put('description', sp.Description__c);
            listForReturn.add(objectMap);
        }
        return listForReturn;
    }
    
    private static Map<String, Saved_Company__c> getMapForSite(List<Saved_Company__c> savedPeople, String siteName) {
        Map<String, Saved_Company__c> mapForReturn = new Map<String, Saved_Company__c>();
        for(Saved_Company__c sp : savedPeople) {
            if(sp.Site_Name__c.equalsIgnoreCase(siteName)) {
                mapForReturn.put(sp.System_Name__c, sp);
            }
        }
        return mapForReturn;
    }
    
    private static List<Saved_Company__c> getListForInsert(Map<String, Saved_Company__c> alreadySaved, List<Object> newList, String siteName) {
        List<Saved_Company__c> peopleForInsert = new List<Saved_Company__c>();
        for(Object o : newList) {
            Map<String, Object> sp = (Map<String, Object>) o;
            if(!alreadySaved.containsKey((String) sp.get('system_name'))) {
                Saved_Company__c spToInsert = new Saved_Company__c();
                spToInsert.Name = (String) sp.get('name');
                spToInsert.System_Name__c = (String) sp.get('system_name');
                spToInsert.Site_Name__c = siteName;
                spToInsert.UserID__c = System.UserInfo.getUserId();
                if(siteName == 'Linkedin') {
                    spToInsert.Logo_URL__c = (String) sp.get('logo_url');
                    spToInsert.Description__c = (String) sp.get('description');
                }
                peopleForInsert.add(spToInsert);
            } else {
                alreadySaved.remove((String) sp.get('system_name'));
            }
        }
        return peopleForInsert;
    }

}