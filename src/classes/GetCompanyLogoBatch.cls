global class GetCompanyLogoBatch implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    public String query = 'Select ID, Name,Website,Contact_Email__c,Organization_Name_URL__c, External_Logo__c from Account where (Website != null or Contact_Email__c != null or Organization_Name_URL__c != null) order by name asc';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> records) {         
        String endpoint;        
        for ( integer i = 0; i< records.size(); i++ ){
            if (records[i].External_Logo__c == null){
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                // Set values to Params
                
                endpoint = 'https://api.ritekit.com/v1/images/logo?client_id=6e255a97c9de4025d5f3c3d5465d006b6ad7a37ea9c7&domain='; 
                
                endpoint +=  records[i].Website != null ? records[i].Website : records[i].Organization_Name_URL__c != null ? records[i].Organization_Name_URL__c : records[i].Contact_Email__c.split('@')[1];
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                
                if (!Test.isRunningTest()) {      
                    res = http.send(req);
                    if (res.getStatusCode() == 200){
                        blob image = res.getBodyAsBlob();
                        String resString = EncodingUtil.base64Encode(image);
                        
                        if (resString.length() <= 131072){
                            records[i].External_Logo__c = resString;
                        } else {
                            records[i].External_Logo__c = resString.subString(0,131072);
                            
                            if (resString.length() <= 262144){
                                records[i].External_Logo2__c = resString.subString(131072,resString.length());
                            } else {
                                records[i].External_Logo2__c = resString.subString(131072,262144);
                                integer maxLengnth = resString.length();
                                if (resString.length() > 393216){
                                    maxLengnth = 393216;
                                }
                                records[i].External_Logo3__c = resString.subString(262144, maxLengnth);
                            }
                        }
                        
                    } else {
                        endpoint = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/images/photo/' + records[i].Id;
                        req.setEndpoint(endpoint);
                        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionID());
                        req.setMethod('GET');
                        res = http.send(req);
                        system.debug(res.getHeader('Location'));
                        if (!res.getHeader('Location').contains('profilephoto/005/T')){
                            req.setEndpoint(res.getHeader('Location'));
                            res = new Http().send(req);
                            if (res.getStatusCode() == 200){
                                blob image = res.getBodyAsBlob();
                                String resString = EncodingUtil.base64Encode(image);
                                
                                if (resString.length() <= 131072){
                                    records[i].External_Logo__c = resString;
                                } else {
                                    records[i].External_Logo__c = resString.subString(0,131072);
                                    
                                    if (resString.length() <= 262144){
                                        records[i].External_Logo2__c = resString.subString(131072,resString.length());
                                    } else {
                                        records[i].External_Logo2__c = resString.subString(131072,262144);
                                        integer maxLengnth = resString.length();
                                        if (resString.length() > 393216){
                                            maxLengnth = 393216;
                                        }
                                        records[i].External_Logo3__c = resString.subString(262144, maxLengnth);
                                    }
                                }
                                
                            }
                    }

                    }
                }  else {
                    integer j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    j = 0;
                    
                }           
            }              
            
        }
        update records;
    }   
    
    global void finish(Database.BatchableContext BC){    
    }
}