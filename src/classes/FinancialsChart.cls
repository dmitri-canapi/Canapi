public without sharing class FinancialsChart {
    @AuraEnabled(cacheable=true)
    public static List<Financials__c> getFins(String accountId){
        if (accountId == null || accountId == ''){
            accountId = [select Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
        }
        Integer i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        return [Select id,
                Chart_of_Accounts__r.Name,
                Report_Period__r.Quarter__c,
                Value__c,
                TextValue__c,
                Chart_of_Accounts__r.Graph_Type__c
                FROM Financials__c
                WHERE  Report_Period__r.Account__c = :accountId
                AND Chart_of_Accounts__r.Account__c = :accountId
                AND Chart_of_Accounts__r.Financial_Category__c != null
                AND Report_Period__r.Quarter__c != null
                AND (Chart_of_Accounts__r.Graph_Type__c = 'Bar Graph' OR Chart_of_Accounts__r.Graph_Type__c = 'Line Graph' )
                order by Chart_of_Accounts__r.Name asc, Report_Period__r.Date__c ASC NULLS LAST, Report_Period__r.CreatedDate ASC 
        ];
    }
}