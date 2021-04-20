@IsTest public with sharing class UserContactTagAssociationTriggerTest {
    @IsTest
    private static void test1() {

        CollaborationGroup cg = new CollaborationGroup(Name = 'Alliance Leads', CollaborationType='Public');
        insert cg;

        CollaborationGroup cg2 = new CollaborationGroup(Name = 'CTO\'s Corner', CollaborationType='Public');
        insert cg2;

        Id p = [select id from profile where name='Community: Alliance Portal'].id;
       
        Account acc = new Account(name ='test') ;
        insert acc; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert con;  
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;

        id sysAdminProfile = [select id from profile where name='System Administrator'].id;
        User user2 = new User(alias = 'test3211', email='test1235@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = sysAdminProfile, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='tester244@noemail.com');
       
        insert user2;

        UserContactTag__c tag = new UserContactTag__c(name = 'Finance');
        insert tag;

        UserContactTag__c tag2 = new UserContactTag__c(name = 'Chief');
        insert tag2;

        UserContactTag__c tag3 = new UserContactTag__c(name = 'Technology');
        insert tag3;

        

        Document__c doc = new Document__c (Name__c='test',Account__c = acc.Id,Shared_with_Users_from_this_account__c = true, Shared_With_Account__c = acc.id);
        insert doc;

        //TeamManagementController.applyTag(user.Id, tag.Id);

        UserContactTagAssociation__c tagAssoc = new UserContactTagAssociation__c();
        tagAssoc.UserContactTag__c =  tag2.Id;
        
        tagAssoc.User__c = user2.Id;
        
        insert tagAssoc;

        UserContactTagAssociation__c tagAssoc2 = new UserContactTagAssociation__c();
        tagAssoc2.UserContactTag__c =  tag3.Id;
        
        tagAssoc2.User__c = user2.Id;
        
        insert tagAssoc2;

        delete tagAssoc2;

        tag3.Name = 'Tech';
        update tag3;

        UserContactTagAssociation__c tagAssoc3 = new UserContactTagAssociation__c();
        tagAssoc3.UserContactTag__c =  tag3.Id;
        
        tagAssoc3.User__c = user2.Id;
        
        insert tagAssoc3;

        tag3.Name = 'Technology';
        update tag3;
        update tagAssoc3;



        
        
        UserContactTagAssociation__c tagAssoc4 = new UserContactTagAssociation__c();
        tagAssoc4.UserContactTag__c =  tag.Id;
        
        tagAssoc4.User__c = user.Id;
        String cId = [select ContactId from User where id =: user.Id].ContactId;
        tagAssoc4.Contact__c = cId;
        delete [select id from UserContactTagAssociation__c where Contact__c =: cId and UserContactTag__c =: tag.Id];
        
        insert tagAssoc4;
        


        tag.Name = 'Fin2';
        update tag;

        delete [select id from UserContactTagAssociation__c where User__c =: user.Id];

    }

}