global without sharing class ChatterSubscriptionsController {
	public String Groups { get; set; }
	public String UserGroups { get; set; }
	public String Topics { get; set; }
	public String TopicInfo { get; set; }
	public String UserTopics { get; set; }
	public String Objectives { get; set; }
	public String UserObjectives { get; set; }
	public String People { get; set; }
	public String UserPeople { get; set; }
	public String Departments { get; set; }
	public String Categories { get; set; }
	public static Map<String,Integer> TopicCounts = GetAllTopicCount();

	public ChatterSubscriptionsController() {
		Groups = JSON.serialize(GetGroups());
		UserGroups = JSON.serialize(GetGroupsByUser());
		TopicInfo = JSON.serialize(GetTopics());
		UserTopics = JSON.serialize(GetTopicsByUser());
		UserObjectives = JSON.serialize(GetObjectivesByUser());
		People = JSON.serialize(GetPeople());
		UserPeople = JSON.serialize(GetPeopleByUser());
		Departments = JSON.serialize(GetDepartments());
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
		CollaborationGroup[] groups = [ 
			SELECT Id,CreatedDate,Name,FullPhotoURL,Description,MemberCount,Owner.Name,(SELECT Id from Feeds)
			FROM CollaborationGroup 
			WHERE CollaborationType = 'Public'
		];

		//Loop through all users
		for (CollaborationGroup G : groups) {
			GroupInfo.add(new Map<String,Object>{
	       			'Id' => G.Id,
	       			'Name' => G.Name,
	       			'CreatedDate' => String.valueOf(G.CreatedDate),
	       			'GroupPhoto' => G.FullPhotoUrl,
	       			'Description' => G.Description,
	       			'MemberCount' => String.valueOf(G.MemberCount),
	       			'OwnerName' => G.Owner.Name,
	       			'PostCount' => G.Feeds.size() 
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
			SELECT Id,Name,FullPhotoURL,Department
			FROM User 
			//WHERE Include_in_LOB_Directory__c = true
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
	       			'Department' => P.Department,
	       			'PostCount' => ActivityInfo.get(P.Id),
	       			'Followers' => String.valueOf(FollowersInfo.get(P.Id))
	       	});
		 }//End for P for loop

		return PeopleInfo;
	}//End GetPeople

	


	/* ******** 
	Returns: List of map objects that contains all topics and topic info. References other methods too to get
	post / followers / photo too.
	Parameters: None
	Description: Method gets all topics that we specify bc we are not tracking all topics only 15 or so. Also 
	uses three other methods that should possibly be refactored or subqueried so we dont waste soql calls.
	********* */
	@RemoteAction
	global static List<Map<String,Object>> GetTopics(){

		//List of maps to hold each individual object
		List<Map<String,Object>> TopicInfo = new List<Map<String,Object>>();

		//Holds our topics
		List<String> TrackingTopics = new List<String> { 'IndustryInfo', 'TechTips', 'SOP', 'Process', 'Credit', 'SiteVisit', 'LoanClosing', 'FinancialReport', 'Survey', 'Health', 'Events', 'Jobs', 'Promotions' };

		//Query to get topics
		Topic[] Topics = [ 
			SELECT Id,Name,CreatedDate,CreatedBy.Name,Description,(SELECT Id FROM FeedSubscriptionsForEntity) 
			FROM Topic
			//WHERE Name IN :TrackingTopics 
		];

		for (Topic T : Topics) { 
			String TopicCategory;
			if (T.Name == 'IndustryInfo') {
				TopicCategory = 'Knowledge';
			} else if (T.Name == 'TechTips') {
				TopicCategory = 'Knowledge';
			} else if (T.Name == 'SOP') {
				TopicCategory = 'Knowledge';
			} else if (T.Name == 'Process') {
				TopicCategory = 'Knowledge';
			} else if (T.Name == 'Credit') {
				TopicCategory = 'Knowledge';
			} else if (T.Name == 'SiteVisit') {
				TopicCategory = 'Alerts';
			} else if (T.Name == 'LoanClosing') {
				TopicCategory = 'Alerts';
			} else if (T.Name == 'FinancialReport') {
				TopicCategory = 'Alerts';
			} else if (T.Name == 'Survey') {
				TopicCategory = 'Alerts';
			} else if (T.Name == 'Health') {
				TopicCategory = 'LOB';
			} else if (T.Name == 'Events') {
				TopicCategory = 'LOB';
			} else if (T.Name == 'Jobs') {
				TopicCategory = 'LOB';
			} else if (T.Name == 'Promotions') {
				TopicCategory = 'LOB';
			}
		 	TopicInfo.add(new Map<String,Object>{
	       			'Id' => T.Id,
	       			'CreatedDate' => T.CreatedDate,
	       			'Name' => T.Name,
	       			'TopicDescription' => T.Description,
	       			'TopicCategory' => TopicCategory,
	       			'TopicOwner' => T.CreatedBy.Name,
	       			'TopicPhoto' => GetTopicPhoto(T.Name),
	       			'Followers' => T.FeedSubscriptionsForEntity, 
	       			'Posts' => GetTopicPostCount(String.valueOf(T.Id))
	       	});
		 }//End for T for loop

		return TopicInfo;
	}//End getTopics

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


	/* ******** 
	Returns: Count of posts for a topic.
	Parameters: Id of topic 
	Description: Method returns number of posts for a topic
	********* */
	public static Integer GetTopicPostCount(String id) {
		//return TopicCounts.get(id) == null ? 0 : 0;	
		return TopicCounts.get(id);
	}//End get topic post count

	//Returns users given Topic id
	public static Integer GetUsersForTopic(Id id) {
		//Query to get topics
		EntitySubscription[] UserCount = [ 
			SELECT Id FROM EntitySubscription where ParentId =:id
		];
		return UserCount.size();
	}//End getusersfortpic


	/* ******** 
	Returns: Returns image name for topic.
	Parameters: Name of topic
	Description: Method determines which filename to return based on the topic name
	********* */
	public static String GetTopicPhoto(String name) {
		String TopicImage;
		if (name == 'IndustryInfo') {
			TopicImage = 'icons/knowledge-industry-info.png';
		} else if (name == 'TechTips') {
			TopicImage = 'icons/knowledge-tech-tips.png';
		} else if (name == 'SOP') {
			TopicImage = 'icons/knowledge-sop.png';
		} else if (name == 'Process') {
			TopicImage = 'icons/knowledge-process.png';
		} else if (name == 'Credit') {
			TopicImage = 'icons/knowledge-credit.png';
		} else if (name == 'SiteVisit') {
			TopicImage = 'icons/alerts-site-visit.png';
		} else if (name == 'LoanClosing') {
			TopicImage = 'icons/alerts-loan-closed.png';
		} else if (name == 'FinancialReport') {
			TopicImage = 'icons/alerts-financial-report.png';
		} else if (name == 'Survey') {
			TopicImage = 'icons/alerts-survey.png';
		} else if (name == 'Health') {
			TopicImage = 'icons/lob-health.png';
		} else if (name == 'Events') {
			TopicImage = 'icons/lob-events.png';
		} else if (name == 'Jobs') {
			TopicImage = 'icons/lob-jobs.png';
		} else if (name == 'Promotions') {
			TopicImage = 'icons/lob-promotion.png';
		}
		return TopicImage;
	}//End get topic post count


	/* ******** 
	Returns: Count of posts for an objective.
	Parameters: Id of objective -- but could be any entity bc we use entity subscription.
	Description: Method returns number of posts for an entity based on id.
	********* */
	public static Integer GetObjectivePostCount(Id id) {
		//Query to get topics
		FeedItem[] ObjectiveCount = [ 
			SELECT ID,ParentId FROM FeedItem where ParentId =: id
		];
		return ObjectiveCount.size();
	}//End get topic post count

	/* ******** 
	Returns: Count of users following an objective.
	Parameters: Id of objective -- but could be any entity bc we use entity subscription.
	Description: Method returns number of followers for an entity based on id.
	********* */
	public static Integer GetUsersForObjective(Id id) {
		//Query to get topics
		EntitySubscription[] UserCount = [ 
			SELECT Id FROM EntitySubscription where ParentId =:id
		];
		return UserCount.size();
	}//End getusersfortpic




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
	global static List<String> GetDepartments(){
		AggregateResult[] Departments = [ 
			SELECT Department D
			FROM User
			WHERE Department !=null 
			GROUP BY Department
		];

		List<String> DepartmentList = new List<String>();
		DepartmentList.add('All');
		for (AggregateResult D : Departments) {
			if (String.valueOf(D.get('D')) == 'Business Advisory Group'){
				DepartmentList.add('BAG');
			} else if (String.valueOf(D.get('D')) == 'Family Entertainment Centers'){
				DepartmentList.add('FEC');
			} else {
				DepartmentList.add(String.valueOf(D.get('D')));
			}
		}//End for
		
		return DepartmentList;
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
	        insert ES;
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
			delete ES;
		}
	}//End getTopics
}//End class