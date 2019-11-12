public without sharing class  CustomMilestoneCreateController {
	
    @AuraEnabled
     public static String getAccountId(){
         return [select Account_Id__c from User where id=:Userinfo.getUserId()].Account_Id__c;
     }
    @AuraEnabled
     public static String saveRecordContr(String MSrec){
         try{
             system.debug(MSrec);
             MSrec=MSrec.replace('[','').replaceAll(']','');
             system.debug(MSrec);
             milestone__c ms = (milestone__c)JSON.deserialize(MSrec,milestone__c.class);
             
            insert ms;
            return ms.Id;
         }catch(exception e){
            throw new AuraHandledException('Error: ' + e.getMessage());   
         }
         //return '';
     }
}