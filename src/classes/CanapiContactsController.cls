public without sharing class CanapiContactsController {
    @AuraEnabled
    public static List<person> getContacts(){
        List<person> persons = new List<person>();
        List <Contact> conts = [Select Id, Name, Title, Phone, MobilePhone, Email, Account.Name, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c from Contact where Account.Name = 'Canapi' order by name asc];
        Set <String> contNames = new  Set <String>();
        for (Contact c: conts){
            contNames.add(c.Name);
        }
        List <User> users = [SELECT Id, Name, FullPhotoUrl FROM User WHERE isActive= true and name in: contNames];
        Map <String, User> usersMap = new Map <String, User>();
        for (User u: users){
            usersMap.put(u.Name, u);
        }

        for (Contact c: conts){
            User u = usersMap.containsKey(c.Name) ? usersMap.get(c.Name) : new User ();

            person p = new person (c, u);
            persons.add(p);
        }
        return persons;


    }

    public class person {
        @AuraEnabled public contact cont {get; set;}
        @AuraEnabled public user u {get; set;}
        public person (Contact cont, User u){
            this.cont = cont;
            this.u = u;
        }
    }
}