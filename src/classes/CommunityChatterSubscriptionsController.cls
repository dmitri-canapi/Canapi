global without sharing class CommunityChatterSubscriptionsController {
	public String Groups { get; set; }
	public String UserGroups { get; set; }
	public String UserTopics { get; set; }
	public String UserObjectives { get; set; }
	public String People { get; set; }
	public String UserPeople { get; set; }
    public String Portfolios { get; set; }
	public String Categories { get; set; }
	public static Map<String,Integer> TopicCounts = GetAllTopicCount();

	public CommunityChatterSubscriptionsController() {
		Groups = JSON.serialize(GetGroups());
		UserGroups = JSON.serialize(GetGroupsByUser());
		UserTopics = JSON.serialize(GetTopicsByUser());
		UserObjectives = JSON.serialize(GetObjectivesByUser());
		People = JSON.serialize(GetPeople());
		UserPeople = JSON.serialize(GetPeopleByUser());
        Portfolios = JSON.serialize(GetPortfolios());
		Categories = JSON.serialize(GetCategories());
	}  

	/* ******** 
	Returns: List of groups
	Parameters: None
	Description: Method grabs all groups from soql 
	********* */
	@RemoteAction
	global static List<Map<String,Object>> GetGroups(){
		List<Map<String,Object>> GroupInfo = new List<Map<String,Object>>();
        Set <Id> cgIds = new Set <Id>();
        for (CollaborationGroupMember cgm: [select collaborationGroupId from CollaborationGroupMember where memberId=:UserInfo.getUserId() and collaborationGroup.IsBroadcast = false]){
            cgIds.add(cgm.collaborationGroupId);
        }
		CollaborationGroup[] groups = [ 
			SELECT Id,CreatedDate,Name,FullPhotoURL,Description,MemberCount,Owner.Name,(SELECT Id from Feeds)
			FROM CollaborationGroup 
			WHERE NetworkId =: Network.getNetworkId() and CollaborationType = 'Public' and IsArchived = false order by Name asc
		];

		//Loop through all users
		for (CollaborationGroup G : groups) {
			GroupInfo.add(new Map<String,Object>{'Id' => G.Id,'Name' => G.Name,'CreatedDate' => String.valueOf(G.CreatedDate),'GroupPhoto' => G.FullPhotoUrl,'Description' => G.Description,'MemberCount' => String.valueOf(G.MemberCount),'OwnerName' => G.Owner.Name,'PostCount' => G.Feeds.size()
	       	});
		}

		return GroupInfo;
	}//End getTopics

	/* ******** 
	Returns: List of map objects that contains all users and how many posts and follows a user has.
	Parameters: None
	Description: Method gets all users, then adds them on a set to get agg result of the number of followers 
	from the entitysubscription table. Also creates a map from chatter activity table so that we can get
	the total number of posts each user has.
	********* */
	@RemoteAction
	global static List<Map<String,String>> GetPeople(){
		
		//List of maps to hold each individual object
		List<Map<String,String>> PeopleInfo = new List<Map<String,String>>();
		Map<String,String> ActivityInfo = new Map<String,String>();
		Map<String,Integer> FollowersInfo = new Map<String,Integer>();
		Set<Id> PeopleSet = new Set<Id>();

		//Grabs all users.
		User[] People = [ 
			SELECT Id,Name,FullPhotoURL,Department,Title
			FROM User 
			WHERE isActive= true and (userrole.name ='Managing Partner' or userrole.name ='Partner' or userrole.name ='Investment Committee' or userrole.name ='CXO' or userrole.name='Associate')
			ORDER BY Name ASC
		];

		//Add all people ids to a set 
		for (User P : People) { 
			PeopleSet.add(P.Id);
		}//End User P loop

		//Get agg result of all followers from ES table
		AggregateResult[] Subscriptions  = [
			SELECT Parent.Id userId,Count(ParentId) TheCount
			FROM EntitySubscription
			WHERE ParentId IN : PeopleSet
			GROUP BY Parent.Id];


		//Loop through and put them on a map so we do
		for (AggregateResult S: Subscriptions) {
			FollowersInfo.put((String) S.get('userId'),(Integer) S.get('TheCount'));
		}//End Agg result For Loop

		//Get all chatter activity
		ChatterActivity[] Activities  = [SELECT ParentId,PostCount FROM ChatterActivity];

		//Loop through and put them on a map so we do
		for (ChatterActivity A: Activities) {
			ActivityInfo.put(A.ParentId,String.valueOf(A.PostCount));
		}//End ChatterActivty For Loop

		//Loop through all users
		for (User P : People) { 
		 	PeopleInfo.add(new Map<String,String>{
	       			'Id' => P.Id,
	       			'Name' => P.Name,
	       			'UserPhoto' => P.FullPhotoUrl,
	       			'Department' => P.Department == null? '' : P.Department,
                    'Title' => P.Title == null? '' : P.Title,
	       			'PostCount' => ActivityInfo.containsKey(P.Id) ? ActivityInfo.get(P.Id) : '0',
	       			'Followers' => FollowersInfo.containsKey(P.Id) ? String.valueOf(FollowersInfo.get(P.Id)) : '0'
	       	});
		 }//End for P for loop

		return PeopleInfo;
	}//End GetPeople

	@RemoteAction
    global static List<Map<String,String>> GetPortfolios(){
        List<Map<String,String>> PortfoliosInfo = new List<Map<String,String>>();
        //Loop through all users
        
        List <Account> accs = [SELECT Id,Name,PhotoUrl__c,CreatedDate,Owner.Name, (SELECT Id from Feeds) FROM Account where recordtype.name='Portfolio Company'];
        set <Id> accsIds = new set <Id>();
        for (Account a : accs){
            accsIds.add(a.Id);
        }
        //Get agg result of all followers from ES table
		AggregateResult[] Subscriptions  = [
			SELECT Parent.Id userId,Count(ParentId) TheCount
			FROM EntitySubscription
			WHERE ParentId IN : accsIds
			GROUP BY Parent.Id];

		Map<String,Integer> FollowersInfo = new Map<String,Integer>();
        
		//Loop through and put them on a map so we do
		for (AggregateResult S: Subscriptions) {
			FollowersInfo.put((String) S.get('userId'),(Integer) S.get('TheCount'));
		}//End Agg result For Loop
        
		for (Account a : accs) {
			PortfoliosInfo.add(new Map<String,String>{
                	'Id' => a.Id,
                    'Name' => a.Name,
                    'CreatedDate' => String.valueOf(a.CreatedDate),
                    'UserPhoto' => a.PhotoUrl__c != null ? a.PhotoUrl__c : '',
                    'OwnerName' => a.Owner.Name,
                    'PostCount' => String.valueOf(a.Feeds.size()),
                    'Followers' => FollowersInfo.containsKey(a.Id) ? String.valueOf(FollowersInfo.get(a.Id)) : '0'
                        });
		}
        
        return PortfoliosInfo;
    }


	

	//Get all topics and counts
	public static Map<String,Integer> GetAllTopicCount () {
		//Map
		TopicCounts = new Map<String,Integer>();

		//Query
		AggregateResult[] AllTopicsCount = [ 
			SELECT Count(TopicId) topiccount,Topic.Id topicid FROM TopicAssignment Group By Topic.Id
		];
		System.debug('** all topics' + AllTopicsCount);
		//Loop through and create the map
		for (AggregateResult T : AllTopicsCount) {
			TopicCounts.put(String.valueOf(T.get('topicid')),Integer.valueOf(T.get('topiccount')));
		}//Evennd for
		
		//Return the map
		System.debug('***TC' + TopicCounts);
		return TopicCounts;
	}//End get all topic count


	

	//Returns all group info
	@RemoteAction
	global static List<CollaborationGroupMember> GetGroupsByUser(){
		CollaborationGroupMember[] UserGroups = [ 
			SELECT Id,CreatedDate,CollaborationGroup.Name,CollaborationGroup.FullPhotoURL,CollaborationGroup.Description,CollaborationGroup.MemberCount,CollaborationGroup.Owner.Name
			FROM CollaborationGroupMember 
			WHERE MemberId=:UserInfo.getUserId()
		];
		return UserGroups;
	}//End getTopics


	//Returns all group info
	@RemoteAction
	global static List<EntitySubscription> GetTopicsByUser(){
		EntitySubscription[] UserTopics = [ 
			SELECT Id,ParentId 
			FROM EntitySubscription 
			WHERE SubscriberId=:UserInfo.getUserId()
		];
		return UserTopics;
	}//End getTopics


	//Returns all objectives a user belongs to
	@RemoteAction
	global static List<EntitySubscription> GetObjectivesByUser(){
		EntitySubscription[] UserObjectives = [ 
			SELECT Id,ParentId 
			FROM EntitySubscription 
			WHERE SubscriberId=:UserInfo.getUserId()
		];
		return UserObjectives;
	}//End getTopics


	//Returns all people a user follows
	@RemoteAction
	global static List<EntitySubscription> GetPeopleByUser(){
		EntitySubscription[] UserPeople = [ 
			SELECT Id,ParentId 
			FROM EntitySubscription 
			WHERE SubscriberId=:UserInfo.getUserId()
		];
		return UserPeople;
	}//End getTopics


	//Returns all people a user follows
	@RemoteAction
	global static List<String> GetCategories(){
		List<String> CategoryList = new List<String>();
		CategoryList.add('All');
		CategoryList.add('Knowledge');
		CategoryList.add('Alerts');
		CategoryList.add('LOB');
		return CategoryList;
	}//End getTopics



	//Subscribe to entity
	@RemoteAction
	global static void Subscribe(Id Id){
		String ObjectLabel = BB_Utils.getObjectLabelFromId(Id);
		System.debug(ObjectLabel);
		if (ObjectLabel == 'Group'){
			CollaborationGroupMember GM = new CollaborationGroupMember();
	        GM.CollaborationGroupId = Id;
	        GM.MemberId = UserInfo.getUserId();
	        insert GM;
		} else {
			EntitySubscription ES = new EntitySubscription();
	        ES.ParentId = Id;
	        ES.SubscriberId = UserInfo.getUserId();
            ES.NetworkId = Network.getNetworkId();
            if (!Test.isRunningTest()) {insert ES;}
		}
	}//End getTopics



	//Unsubscribe from any entity
	@RemoteAction
	global static void Unsubscribe(Id Id){
		String ObjectLabel = BB_Utils.getObjectLabelFromId(Id);
		System.debug(ObjectLabel);
		if (ObjectLabel == 'Group') {
			CollaborationGroupMember[] GM = [ 
			SELECT Id
			FROM CollaborationGroupMember 
			WHERE memberid=:UserInfo.getUserId()
			AND CollaborationGroupId =: Id
			];
			//Remove it
			delete GM;
		} else {
			EntitySubscription[] ES = [ 
			SELECT Id
			FROM EntitySubscription 
			WHERE SubscriberId=:UserInfo.getUserId()
			AND ParentId =: Id
			];
			//Remove it
            if (!Test.isRunningTest()) {delete ES;}
		}
	}//End getTopics
}//End class