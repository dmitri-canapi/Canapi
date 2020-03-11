public with sharing class communityTopicListController {
    @AuraEnabled 
    public static List <topic> getTopicsList (){
        return [select id, name, (SELECT id,Entity.Name, EntityId,EntityType FROM TopicAssignments where EntityType = 'FeedItem' ) from topic where id in (select TopicId from TopicAssignment where EntityType = 'FeedItem' and NetworkId =: Network.getNetworkId()) order by name asc];
    }
}