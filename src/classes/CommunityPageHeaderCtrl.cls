global without sharing class CommunityPageHeaderCtrl{
    @AuraEnabled
     public static objWrapper getInitValues (String recId){ 
         String sobjName = Id.valueOf(recId).getSObjectType().getDescribe().getName(); 
         
         DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(sobjName).getDescribe();
         SObject record;
         String accID = null;
         String accName = null;
         String accDescription = null;
         String RecordType = null;
         
         if (sobjName=='Account'){
            record = Database.query('Select Name,Description, External_Logo__c,External_Logo2__c,External_Logo3__c, Recordtype.Name From ' + sobjName + ' Where Id = :recId');
            accDescription = String.ValueOf(record.get('Description')); /*!= null ? String.ValueOf(record.get('Description')) : ;*/
            RecordType = String.ValueOf(record.getSobject('Recordtype').get('Name'));
         } else if (sobjName=='Round__c') {
            record = Database.query('Select Name, Target_Company__c, Target_Company__r.Name, Target_Company__r.Recordtype.Name From ' + sobjName + ' Where Id = :recId');
            accID = String.ValueOf(record.get('Target_Company__c'));
            accName = String.ValueOf(record.getSobject('Target_Company__r').get('Name'));
            RecordType = String.ValueOf(record.getSobject('Target_Company__r').getSobject('Recordtype').get('Name'));
        } else if (sobjName=='Investment__c') {
            record = Database.query('Select Name, Investor__c, Investor__r.Name, Investor__r.Recordtype.Name From ' + sobjName + ' Where Id = :recId');
            accID = String.ValueOf(record.get('Investor__c'));
            accName = String.ValueOf(record.getSobject('Investor__r').get('Name'));
            RecordType = String.ValueOf(record.getSobject('Investor__r').getSobject('Recordtype').get('Name'));
         } else {
             try{
                 record = Database.query('Select Name, Account__c, Account__r.Name, Account__r.Recordtype.Name From ' + sobjName + ' Where Id = :recId');
                 accID = String.ValueOf(record.get('Account__c'));
                 accName = String.ValueOf(record.getSobject('Account__r').get('Name'));
                 RecordType = String.ValueOf(record.getSobject('Account__r').getSobject('Recordtype').get('Name'));
             } catch(exception e){
                 record = Database.query('Select Name, AccountId, Account.Name, Account.Recordtype.Name From ' + sobjName + ' Where Id = :recId');
                 accID = String.ValueOf(record.get('AccountId'));
                 accName = String.ValueOf(record.getSobject('Account').get('Name'));
                 RecordType = String.ValueOf(record.getSobject('Account').getSobject('Recordtype').get('Name'));
             }
         }
         

         objWrapper ow = new objWrapper(sobjName, String.ValueOf(record.get('Name')), accID, accName, accDescription, record, RecordType);
         return ow;
     }
    
    public class objWrapper {
        @AuraEnabled
        public String sobjName {get; set;}
        @AuraEnabled
        public String recordName {get; set;}
        @AuraEnabled
        public String accID {get; set;}
        @AuraEnabled
        public String accName {get; set;}
        @AuraEnabled
        public String accDescription {get; set;}
        @AuraEnabled
        public SObject obj {get; set;}
        @AuraEnabled
        public String RecordType {get; set;}
        @AuraEnabled
        public String UserAccountRT {get; set;}
        @AuraEnabled
        public String UserAccountName {get; set;}


        public objWrapper(String sobjName, String recordName, String accID, String accName, String accDescription, SObject obj, String RecordType){
            this.sobjName = sobjName;
            this.recordName = recordName;
            this.accID = accID;
            this.accName = accName;
            this.accDescription = accDescription;
            this.obj = obj;
            this.RecordType = RecordType;
            try {
                String userAccId = [select Account_Id__c from user where id =: userinfo.getuserid()].Account_Id__c;
                Account acc = [select Name,RecordType.Name from Account where id=: userAccId];
                this.UserAccountRT = acc.RecordType.Name;
                this.UserAccountName = acc.Name;
            } catch(exception e){}
            
        }
    }
}