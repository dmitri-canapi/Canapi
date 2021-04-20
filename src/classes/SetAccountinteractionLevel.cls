global class SetAccountinteractionLevel implements Schedulable {
    global void execute(SchedulableContext sc) {
        List <Account> accForUpdate = new List <Account>();
        
        Map<Id,List <User>> accUserMap = new Map<Id,List <User>>();
        for (User u: [Select LastLoginDate, AccountId from User where Profile.Name = 'Community: Alliance Portal' and IsActive = true and LastLoginDate != null and Account.Recordtype.Name = 'Bank']){
            if (accUserMap.containsKey(u.AccountId)){
                List <User> usrs = accUserMap.get(u.AccountId);
                usrs.add(u);
                accUserMap.put(u.AccountId,usrs);
            } else {
                accUserMap.put(u.AccountId,new List <User> {u});
            }
        }

        for (Id accId: accUserMap.KeySet()){
            Integer daysSum = 0;
            for (User u: accUserMap.get(accId)){
                daysSum += Date.valueOf(u.LastLoginDate).daysBetween(System.today());
            }
            String level = 'Blue';
            if (daysSum / accUserMap.get(accId).size() <= 30 ){
                level = 'Gold';
            } else if (daysSum / accUserMap.get(accId).size() <= 90){
                level = 'Green';
            }
            accForUpdate.add(new Account (id = accId, Account_Interaction_Level__c = level));
        }
        update accForUpdate;
    }
}