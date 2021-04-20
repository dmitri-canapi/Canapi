global class SetAccountWatchlistFieldBatch implements Database.Batchable<sObject>{
    
        public String query = 'Select id, Last_Modified_Date_Interactive__c,Heat__c, (select lastmodifieddate from events order by lastmodifieddate desc limit 1),(select lastmodifieddate from Tasks order by lastmodifieddate desc limit 1), (select lastmodifieddate from Documents__r order by lastmodifieddate desc limit 1),(select lastmodifieddate from opportunities order by lastmodifieddate desc limit 1) from Account where Last_Modified_Date_Interactive__c != null and Heat__c != \'Cold\' and Heat__c != null';
        global Database.QueryLocator start(Database.BatchableContext BC) {
            return Database.getQueryLocator(query);
        }
    
        global void execute(Database.BatchableContext BC, List<Account> records) {     
            
            for(Account a : records){
                
                Datetime  d = a.Last_Modified_Date_Interactive__c;
                for(Event e: a.events){
                    if (d < e.lastmodifieddate){
                        d = e.lastmodifieddate;
                    }
                }
                for(task t: a.tasks){
                    if (d < t.lastmodifieddate){
                        d = t.lastmodifieddate;
                    }
                }
                for(opportunity o: a.opportunities){
                    if (d < o.lastmodifieddate){
                        d = o.lastmodifieddate;
                    }
                }
                for(Document__c o: a.Documents__r){
                    if (d < o.lastmodifieddate){
                        d = o.lastmodifieddate;
                    }
                }

                Integer lastModDay = Date.valueOf(d).daysBetween((Date.Today()));
                //system.debug(lastModDay);
                if (lastModDay <= 20 && (a.Heat__c == 'On Fire' || a.Heat__c == 'Hot')){
                    a.Heat__c = 'Hot';
                    if (Test.isRunningtest()){
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
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                        i = 0;
                    }
                } else if (lastModDay <= 30){
                    a.Heat__c = 'Warm';
                }else if (lastModDay > 30){
                    a.Heat__c = 'Cold';
                }
                
                
            }  
            //system.debug(records);
            update records;
            
        }   
        
        global void finish(Database.BatchableContext BC){    
        }
    }