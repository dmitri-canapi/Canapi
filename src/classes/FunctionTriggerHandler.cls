public without sharing class FunctionTriggerHandler {
     @future (callout=true)
     Public static void createMeeting(String functionId, String Password, String req)
     {
          //system.debug();
          Map<String, Object> resp = ZoomApis.createMeeting('me',req);
          
          system.debug(resp.get('registration_url'));
          Function__c f = new Function__c();
          f.id = functionId;
          f.Meeting_Password__c = Password; 
          f.Meeting_Id__c = String.ValueOf(resp.get('id')); 
          f.join_url__c = String.ValueOf(resp.get('join_url'));
          f.Registration_URL__c = String.ValueOf(resp.get('registration_url'));
          update f;
     }

    

    @auraEnabled()
    public static void sendinvitations(String recId){
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Zoom_invitation'];
        
        List <Function_Contact__c> fcList = [select Id, Contact__c, Contact__r.Email, Function__r.Name, Start_Time__c, Function__r.Function_Description__c from Function_Contact__c where Function__c =: recId and Function_Status__c = 'Planned'];
        for (Function_Contact__c fc: fcList){
            if (fc.Contact__r.Email == null ){
                throw new applicationException('No Email');
            }
            fc.Function_Status__c = 'Invited';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setSubject(et.subject);

            et.HtmlValue = et.HtmlValue.replace('{FunctionName}', fc.Function__r.Name);
            et.HtmlValue = et.HtmlValue.replace('{FunctionDescription}', (fc.Function__r.Function_Description__c != null ? fc.Function__r.Function_Description__c : ''));
            et.HtmlValue = et.HtmlValue.replace('{!Function_Contact__c.Start_Time__c}', String.ValueOf(fc.Start_Time__c.format('M/d/y h:mm a z')));
            et.HtmlValue = et.HtmlValue.replace('{!Function_Contact__c.Id}', fc.Id);
            mail.setHTMLBody(et.HtmlValue); 
            mail.setTargetObjectId(fc.Contact__c);
            mail.setWhatId(fc.Id);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            
            allmsg.add(mail);
        }
        
        Messaging.sendEmail(allmsg,false);
        update fcList;
    }

    @auraEnabled()
    public static Function_Contact__c getFunctionContactStatus(String functionConId){
        system.debug(functionConId);
        return [select Function_Status__c, Start_Time__c, Function__r.Function_Description__c, Function__r.Name from Function_Contact__c where id =: functionConId];
    }

    @auraEnabled()
    public static void addRegistrant(String functionConId){
        Contact c = [select FirstName, LastName, email from contact where id in (select Contact__c from Function_Contact__c where id =: functionConId)];
        Function__c f = [select Meeting_Id__c from Function__c where id in (select Function__c from Function_Contact__c where id =: functionConId)];
        if (c.email == null || f.Meeting_Id__c == null){
            return;
        }

        ZoomApis.inviteContactWrapper newWapper = new ZoomApis.inviteContactWrapper();
        newWapper.email = c.email;
        newWapper.first_name = c.Firstname != null ? c.FirstName : c.LastName;
        newWapper.last_name = c.LastName;
        string jsonString = JSON.serialize(newWapper);
        Map<String, Object> resp = ZoomApis.addRegistrant(f.Meeting_Id__c,jsonString);

        if (resp.containsKey('code')){
            throw new applicationException(String.ValueOf(resp.get('code')) == '3027' ? ( 'Registration Error. Please change it to "Host cannot register as a participant for the event they host.' ) : String.ValueOf(resp.get('message')));
        }

        system.debug(resp.get('registrant_id'));
        Function_Contact__c fc = new Function_Contact__c();
        fc.id = functionConId;
        fc.join_url_unique__c = String.ValueOf(resp.get('join_url'));
        fc.registrant_id__c = String.ValueOf(resp.get('registrant_id'));
        fc.Function_Status__c = 'Registered';
        update fc;

    }

    /*@future (callout=true)
    public static void addRegistrant(String functionConId, String functionId){
        Contact c = [select FirstName, LastName, email from contact where id in (select Contact__c from Function_Contact__c where id =: functionConId)];
        Function__c f = [select Meeting_Id__c from Function__c where id =: functionId];
        if (c.email == null || f.Meeting_Id__c == null){
            return;
        }

        ZoomApis.inviteContactWrapper newWapper = new ZoomApis.inviteContactWrapper();
        newWapper.email = c.email;
        newWapper.first_name = c.Firstname != null ? c.FirstName : c.LastName;
        newWapper.last_name = c.LastName;
        string jsonString = JSON.serialize(newWapper);
        Map<String, Object> resp = ZoomApis.addRegistrant(f.Meeting_Id__c,jsonString);

        system.debug(resp.get('registrant_id'));
        Function_Contact__c fc = new Function_Contact__c();
        fc.id = functionConId;
        fc.join_url_unique__c = String.ValueOf(resp.get('join_url'));
        fc.registrant_id__c = String.ValueOf(resp.get('registrant_id'));
        update fc;

    }*/

    public class applicationException extends Exception {}

    /*@future (callout=true)
    Public static void inviteContact(String functionConId, String functionId)
    {   
        Contact c = [select FirstName, LastName, email from contact where id in (select Contact__c from Function_Contact__c where id =: functionConId)];
        Function__c f = [select Meeting_Id__c from Function__c where id =: functionId];
        if (c.email == null || f.Meeting_Id__c == null){
            return;
        }

        ZoomApis.inviteContactWrapper newWapper = new ZoomApis.inviteContactWrapper();
        newWapper.email = c.email;
        newWapper.first_name = c.Firstname != null ? c.FirstName : c.LastName;
        newWapper.last_name = c.LastName;
        string jsonString = JSON.serialize(newWapper);

        
        system.debug(ZoomApis.inviteContact(f.Meeting_Id__c, jsonString));

        //Function_Contact__c f = new Function_Contact__c(id = functionConId, Meeting_Id__c = String.ValueOf(ZoomApis.createMeeting('me',req)));
        //update f;
    }*/
}