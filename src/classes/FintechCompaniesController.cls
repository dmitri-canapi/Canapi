global without sharing class FintechCompaniesController {
	@AuraEnabled
    global static List<Account> getAccounts(String pageSize, String pageNumber, String filter){
        Integer psize = Integer.valueOf(pageSize);
        Integer pnumber = Integer.valueOf(pageNumber)-1;
        
        String q ='Select Id, Name,Type, Phone, Website, BillingState, Owner.Name, External_Logo__c,External_Logo2__c,External_Logo3__c from Account ';
        q += ' where RecordType.Name = \'Fintech\' and Name like \'%' + filter + '%\'';
        integer offset = psize*pnumber;
        q+= ' order by name asc LIMIT : psize OFFSET :offset';
        return Database.query(q);
    }
    
    @AuraEnabled
    public static Integer getTotalCount(String filter){
        filter = '%'+ filter +'%';
        AggregateResult results = [select  count(Id) total from Account where RecordType.Name = 'Fintech' and Name like :filter];//!!!!
        Integer total =(Integer)results.get('total') ; 
        return total;
    } 
    
}