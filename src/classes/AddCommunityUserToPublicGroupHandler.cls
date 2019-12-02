public class AddCommunityUserToPublicGroupHandler {
	@future
    public static void subscribe(List<Id> usersIds){
        ID netwkId = [select id from network where name = 'Canapi Connect' limit 1].Id;
        List<CollaborationGroupMember> listGroupMember = new List<CollaborationGroupMember>(); 
        List<EntitySubscription> listEntitySubscription = new List<EntitySubscription>(); 
        ID canapiConnectProfileId = [select id,name from Profile where name ='Community: Alliance Portal' limit 1].Id;
        List <CollaborationGroup> cgroups = [select Id,name,NetworkId from CollaborationGroup where NetworkId =: netwkId];
        List <Account> portfolios = [SELECT Id FROM Account where recordtype.name='Portfolio Company'];
        for (Id uId: usersIds){
            for ( CollaborationGroup cg: cgroups){
                CollaborationGroupMember gm = new CollaborationGroupMember(); 
                gm.CollaborationGroupId = cg.id;
                gm.MemberId = uId;
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