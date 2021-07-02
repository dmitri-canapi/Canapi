trigger CheckParentAccounts on Account (after insert, after update, after delete, after undelete) {
   /*
    List<Account> accounts = new List<Account>();   
    List<Account> WOparentAccounts = new List<Account>();  
    Set<Id> custord = new Set<Id>();
    
    if(Trigger.isDelete) {
      for(Account con:Trigger.Old) {      
         custord.add(con.ParentId);    
      }      
    }else if(Trigger.isUpdate) {
      for(Account con:Trigger.New) {      
         custord.add(con.ParentId);     
      }
      for(Account con:Trigger.Old) {      
         custord.add(con.ParentId);   
      }      
    }else {
      for(Account con:Trigger.New) {      
         custord.add(con.ParentId);     
      }
    }
    
    AggregateResult[] groupedResults = [SELECT COUNT(Id), ParentId FROM Account where ParentId IN :custord and ParentId !=null GROUP BY ParentId ];
    
    for (Id accid: custord){
        Account a = new Account(id = accid, Has_Child_Accounts__c = false);
        if (a.Id != null)
        WOparentAccounts.add(a);
    }
    update WOparentAccounts;
    for(AggregateResult ar:groupedResults) {     
      Id custid = (ID)ar.get('ParentId');        
      Account cust1 = new Account(Id=custid);     
      cust1.Has_Child_Accounts__c  = true;     
      accounts.add(cust1);      
    }   
    update accounts;*/
 }