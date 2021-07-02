@RestResource(urlMapping='/zoomwebhooks')
global class ZoomRestResources {
    @HttpPost
    global static void doPost()
    {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String bodyString = body.toString().replace('object','objectCustom');
        
        ZoomRestResources zr = (ZoomRestResources) JSON.deserialize(bodyString,ZoomRestResources.class);
        system.debug(zr.payload.objectCustom.participant.id);
        system.debug(zr.payload.objectCustom.id);
        system.debug(zr.event);

        if (zr.event == 'meeting.participant_joined'){
            try{
                Function_Contact__c fc = [select id from Function_Contact__c where function__r.Meeting_Id__c =: zr.payload.objectCustom.id and registrant_id__c = : zr.payload.objectCustom.participant.id and Join_Time__c = null order by createdDate desc limit 1];
                fc.Join_Time__c = System.Now();
                fc.Attended__c = true;
                update fc;
            } catch(exception e){

            }
        } else if (zr.event == 'meeting.participant_left'){
            try{
                Function_Contact__c fc = [select id from Function_Contact__c where function__r.Meeting_Id__c =: zr.payload.objectCustom.id and registrant_id__c = : zr.payload.objectCustom.participant.id order by createdDate desc  limit 1];
                fc.Leave_Time__c = System.Now();
                update fc;
            } catch(exception e){

            }
        }
        
    }
    

        public String event;
        public Payload payload;
    
        public class Participant {
            public String id;
        }
    
        public class ObjectCustom {
            public Participant participant;
            public String id;
        }
    
        public class Payload {
            public ObjectCustom objectCustom;
        }
    
        
        /*public static ZoomRestResources parse(String json) {
            return (ZoomRestResources) System.JSON.deserialize(json, ZoomRestResources.class);
        }*/
    
}