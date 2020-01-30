public class AddCommunityUserToPublicGroupHandler {
	@future
    public static void subscribe(List<Id> usersIds){
        ID netwkId = [select id from network where name = 'Canapi Connect' limit 1].Id;
        List<CollaborationGroupMember> listGroupMember = new List<CollaborationGroupMember>(); 
        List<EntitySubscription> listEntitySubscription = new List<EntitySubscription>();

        
        Set <String> whiteList = new Set <String>();
        for (Auto_Enroll_Chatter_Groups__mdt wlItem: [select GroupId__c from Auto_Enroll_Chatter_Groups__mdt]){
            whiteList.add(wlItem.GroupId__c);
        }
        List<TagsTemplate__mdt> tagsTemplate = [select id,Tag_Name__c,Parent_Tag_Name__c from TagsTemplate__mdt];
        List <CollaborationGroup> cgroups = [select Id, Name, NetworkId from CollaborationGroup where NetworkId =: netwkId  and CollaborationType = 'Public' and IsArchived = false and id in: whiteList];
        List <Account> portfolios = [SELECT Id FROM Account where recordtype.name='Portfolio Company'];
        for (Id uId: usersIds){
            for ( CollaborationGroup cg: cgroups){
                CollaborationGroupMember gm = new CollaborationGroupMember(); 
                gm.CollaborationGroupId = cg.id;
                gm.MemberId = uId;
                gm.NotificationFrequency = cg.Name == 'Canapi News & Announcements' ? 'P' : 'D';
                listGroupMember.add(gm);
            }
            for (Account a: portfolios){
                EntitySubscription ES = new EntitySubscription();
                ES.ParentId = a.Id;
                ES.SubscriberId = uId;
                ES.NetworkId = netwkId;
                listEntitySubscription.add(ES);
            }
        }
        insert listGroupMember;
        insert listEntitySubscription;
    }

    @future
    public static void updateContacts(List<Id> usersIds){
        List <Contact> conts = new List <Contact> ();
        for (User u : [select ContactId, FirstName, LastName, Title, Phone, Email from User where id in: usersIds]){
            Contact c = new Contact(FirstName = u.FirstName,
            LastName = u.LastName,
            Title = u.Title,
            Phone = u.Phone,
            Email = u.Email,
            Id = u.ContactId);
            conts.add(c);
        }
        update conts;
    }
}