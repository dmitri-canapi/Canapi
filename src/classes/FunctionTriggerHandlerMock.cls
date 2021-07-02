@isTest 
global with sharing class FunctionTriggerHandlerMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"test","join_url":"dfdf"}');
        res.setStatusCode(201);
        return res;
    }
}