@isTest 
public with sharing class FunctionTriggerHandlerTest {
    
	static testMethod void testMethod1() {
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new FunctionTriggerHandlerMock());
        Function__c f = new Function__c();
        f.Name = 'test';
        f.Begin_Date__c = system.now();
        f.End_Date__c = system.now().addhours(1);
        f.Function_Status__c = 'Planned';
        insert f;
        

        account a = new account();
        a.name = 'test';
        insert a;

        Contact c = new Contact(LastName = 'test', accountId = a.Id, email = 'test@sddghghf.com');
        insert c;
        Function_Contact__c fc = new Function_Contact__c();
        fc.Contact__c = c.Id;
        fc.Function__c = f.Id;
        insert fc;

        FunctionTriggerHandler.sendinvitations(f.Id);
        Test.StopTest();

        FunctionTriggerHandler.getFunctionContactStatus(fc.Id); 
        FunctionTriggerHandler.addRegistrant(fc.Id);

        
    }
    static testMethod void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new FunctionTriggerHandlerMock());
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Function__c f = new Function__c();
        f.Name = 'test';
        f.Begin_Date__c = system.now();
        f.End_Date__c = system.now().addhours(1);
        f.Function_Status__c = 'Planned';
        insert f;
        

        account a = new account();
        a.name = 'test';
        insert a;

        Contact c = new Contact(LastName = 'test', accountId = a.Id, email = 'test@sddghghf.com');
        insert c;
        Function_Contact__c fc = new Function_Contact__c();
        fc.Contact__c = c.Id;
        fc.Function__c = f.Id;
        fc.registrant_id__c = 'test';
        insert fc;

        
        
        /*String json = '{'+
		'  \"event\": \"string\",'+
		'  \"event_ts\": \"long\",'+
		'  \"payload\": {'+
		'    \"objectCustom\": {'+
		'      \"participant\": {'+
		'        \"id\": \"string\"'+
		'      }'+
		'    }'+
		'  }'+
		'}';*/
        String json = '{"event":"meeting.participant_joined","payload":{"object":{"participant":{"id":"test"}}}}';
               
        req.requestURI = '/services/apexrest/zoomwebhooks'; 

        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(json);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ZoomRestResources.doPost();
        json = '{"event":"meeting.participant_left","payload":{"object":{"participant":{"id":"test"}}}}';
        req.requestBody = Blob.valueOf(json);
        RestContext.request = req;
        RestContext.response = res;
        ZoomRestResources.doPost();
        Test.stopTest();
    }

}