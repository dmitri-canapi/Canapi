public class AddCommunityUserToPublicGroupHandler {
	@future
    public static void subscribe(List<Id> usersIds){
        ID netwkId = [select id from network where name = 'Canapi Connect' limit 1].Id;
        List<CollaborationGroupMember> listGroupMember = new List<CollaborationGroupMember>(); 
        List<EntitySubscription> listEntitySubscription = new List<EntitySubscription>();
        List <CollaborationGroup> cgroups = [select Id, Name, NetworkId from CollaborationGroup where NetworkId =: netwkId];
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
}