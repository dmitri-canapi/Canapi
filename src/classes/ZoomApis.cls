public with sharing class ZoomApis {
/* Request body I am passing to create a Meeting */
/*{
  "type": 2,
  "topic": "Test Topic",
  "timezone": "Asia/Kolkata",
  "start_time": "2021-04-21T16:54:14Z",
  "password": null,
  "duration": 60
}*/
   
    public static Map<String, Object> createMeeting(String userEmail,String jsonString) {
        System.debug('jason>>'+jsonString);
        String endPoint = 'callout:ZoomMeeting/users/'+userEmail+'/meetings';
        HttpRequest req = new HttpRequest();
        req.setBody(jsonString);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(endPoint); 
        Http http = new Http();
        HttpResponse res = http.send(req);
         
        if(res.getStatusCode() == 201){
            System.debug('res pass >>>' +res.getBody().replace(':', ':\n'));
            Map<String, Object> m =   (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return m;//(Long)m.get('id');          
        }else{
            System.debug('res fail >>>' +res);
            return null;
        }
    }

    public static Map<String, Object> addRegistrant(String meetingId, String jsonString) {
        System.debug('jason>>'+jsonString);

        String endPoint = 'callout:ZoomMeeting/meetings/'+meetingId+'/registrants';
        HttpRequest req = new HttpRequest();
        req.setBody(jsonString);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(endPoint); 
        Http http = new Http();
        HttpResponse res = http.send(req);
         
        /*if(res.getStatusCode() == 201){
            System.debug('res pass >>>' +res.getBody());
                   
        }else{
            System.debug('res fail >>>' +res.getBody());
            return null;
        }*/
        Map<String, Object> m =   (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        return m;   
    }
     
    public class createMeetingWapper{
        Public String topic {get;set;}
        Public Integer type {get;set;}
        Public String start_time {get;set;}
        Public Long duration {get;set;}
        Public String timezone {get;set;}
        Public String password {get;set;}
        Public Settings settings {get;set;}
        Public String agenda {get;set;}
    }
    
    public class Settings {
		public Integer approval_type {get;set;}
		public Integer registration_type {get;set;}
		
	}

    public class inviteContactWrapper{
        Public String email {get;set;}
        Public String first_name {get;set;}
        Public String last_name {get;set;}
    }
}
 
/*
ZoomApis.createMeetingWapper newWapper = new ZoomApis.createMeetingWapper();
newWapper.topic = 'Test Topic';
newWapper.type = 2;
newWapper.start_time = '2021-04-21T16:54:14Z';
newWapper.duration = 60;
newWapper.timezone = 'Asia/Kolkata';
string jsonString = JSON.serialize(newWapper);
System.debug('jsonString >>'+jsonString);
 
ZoomApis.createMeeting('me',jsonString);*/