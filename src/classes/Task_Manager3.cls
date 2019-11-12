/**
 * Task Manager v1.2.3
 * Includes in-line editing and follow up task creation
 * @author  Matthew Craig <matt.craig@liveoakbank.com>
 * @date 11 Dec 2014
 * --------------------------------------
 * 22 Dec 2014 - Task manager 1.2.2 Released (MPC)
 */
global without sharing class Task_Manager3 {

    // Performance testing configuration
    global static long classStartTime                     = System.currentTimeMillis();
    global static System.LoggingLevel performanceLogLevel = LoggingLevel.FINEST; // ERROR, WARN, INFO, DEBUG, FINE, FINER, FINEST
    global static Boolean enableBenchmarking              = false;

    /**
     * a map containing table keyPrefixis
     * @type {Map}
     */
    global static Map<String, String> objectKeyPrefix = new Map<String, String>();

    // Label => API Name
    global static Map<String, String> RELATED_TO_MAP = new Map<String, String> {
        'None'                => 'null',
        'Account'             => 'Account',
        'Opportunity'         => 'Opportunity',
        'Series'              => 'Round__c',
        'Investment'          => 'Investment__c'
    };
    global static String RELATED_TO_MAP_JSON {
        get {
            RELATED_TO_MAP_JSON = JSON.serializePretty(RELATED_TO_MAP.keySet());
            return RELATED_TO_MAP_JSON;
        }
        private set;
    }

    /**
     * Statuses a user is allowed to select
     * @type {Set}
     */
    global static Set<String> ALLOWED_STATUSES = new Set<String> {
        'Not Started',
        'In Progress',
        'Completed'
    };
    global static String ALLOWED_STATUSES_JSON {
        get {
            ALLOWED_STATUSES_JSON = JSON.serializePretty(ALLOWED_STATUSES);
            return ALLOWED_STATUSES_JSON;
        }
        private set;
    }

    /**
     * Priorites a user is allowed to select
     * @type {Set}
     */
    global static Set<String> ALLOWED_PRIORITIES = new Set<String> {
        'Low',
        'Normal',
        'High'
    };
    global static String ALLOWED_PRIORITIES_JSON {
        get {
            ALLOWED_PRIORITIES_JSON = JSON.serializePretty(ALLOWED_PRIORITIES);
            return ALLOWED_PRIORITIES_JSON;
        }
        private set;
    }

    /**
     * The types of OBJECTS that users can associate "who" with in tasks. Users
     * can only search for these types when assigning "Name/Who".
     * @type {Set}
     */
    global static Map<String, String> AVAIL_WHO_TYPES = new Map<String, String> {
        'None' => 'null',
        'Contact' => 'Contact',
        'Lead' => 'Lead'
    };
    global static String AVAIL_WHO_TYPES_JSON {
        get {
            AVAIL_WHO_TYPES_JSON = JSON.serializePretty(AVAIL_WHO_TYPES.keySet());
            return AVAIL_WHO_TYPES_JSON;
        }
        private set;
    }

    /**
     * Available Assigned to types
     */
    global static Map<String, Set<String>> AVAIL_ASSIGNED_TO_TYPES = new Map<String, Set<String>> {
        'User' => new Set<String> {
            'LOB Standard Platform User',
            'LOB Standard User',
            'LOB System Administrator',
            'LOB Standard User ANTISKUID',
            'LOB System Administrator Skuid',
            'Executive',
            'System Administrator',
            'Standard User'
        },
        'Partner User' => new Set<String> {
            'LOB_Partner_User',
            'LOB_Partner_Platform'
        },
        'Customer Portal User' => new Set<String> {
            'CP_CommunityPlusUser',
            'CP_Community',
            'CP_CommunityLogin',
            'CP_CommunityLoginPlus',
            'CP_Profile',
            'LOB_Portal_User'
        }
    };
    global static String AVAIL_ASSIGNED_TO_TYPES_JSON {
        get {
            AVAIL_ASSIGNED_TO_TYPES_JSON = JSON.serializePretty(AVAIL_ASSIGNED_TO_TYPES.keySet());
            return AVAIL_ASSIGNED_TO_TYPES_JSON;
        }
        private set;
    }

    /**
     * How far back to LIMIT the query
     * @type {[Date]}
     */
    global static Date HOW_FAR_BACK = system.today().addDays(-7);
    /**
     * How far back to grab entries with no due dated
     * @type {Datetime}
     */
    global static Datetime HOW_FAR_BACK_TO_ALLOW_NO_DUE_DATES = system.today().addDays(-60);

    /**
     * The max results to pull in an auto-complete query.
     * @type {Number}
     */
    global static Integer AUTOCOMPLETE_QUERY_LIMIT     = 100;

    /**
     * The minimum length of an auto-complete string before performing query.
     * @type {Number}
     */
    global static Integer AUTOCOMPLETE_MIN_LENGTH      = 2;
    global static Integer AUTOCOMPLETE_MIN_LENGTH_JSON {
        get {
            return AUTOCOMPLETE_MIN_LENGTH;
        }
    }

    /**
     * Output options (pretty json or not.)
     * @type {Boolean}
     */
    global static Boolean JSON_PRETTY                  = true;

    /**
     * The most tasks to query in a single run.
     * @type {Number}
     */
    global static Integer  MAX_ALLOWED_TASKS = 250;

    /************************************************************************'
     * Custom Error Class and Error messages.
     */

    /**
     * Error message describing invalid object error
     * @type {String}
     */
    global static final String INVALID_OBJECT_ERROR    = 'You have specified something that is NOT a valid object name.';

    global class TaskManager2Exception extends Exception{}

    /**
     * Class to return jquery Auto-complete information.
     */
    global class JQueryUIAutocomplete {
        public String id;
        public String label;
        public String value;
        public String smallPhotoUrl;
        public String profileName;
        public String userType;
    }

    /**
     * The details about a person/contact/user
     */
    global class PersonDetails {
        Id id                = null;
        String name          = '';
        String smallPhotoUrl = null;
        String objectType    = null;
    }

    /**
     * Details about an object of ANY type
     */
    global class ObjectDetails {
        Id id             = null;
        String name       = '';
        String objectType = '';
    }

    /**
     * Details about a Task.
     */
    global class TaskOut {
        Id id                        = null;
        String name                  = '';
        Id ownerId                   = null;
        PersonDetails ownerDetails   = new PersonDetails();
        PersonDetails creatorDetails = new PersonDetails();
        Date activityDate            = null;
        String subject               = '';
        String priority              = '';
        String status                = '';
        String whatId                = null;
        Integer whatCount            = 0;
        ObjectDetails what           = new ObjectDetails();
        Id whoId                     = null;
        String whoName               = '';
        String whoType               = '';
        Integer whoCount             = 0;
        List<ObjectDetails> who      = new List<ObjectDetails>();
        String description           = '';
    }

    global Task_Manager3() { }

    global static String taskList = '';
    global static String getTaskList() {
        taskList = JSON.serializePretty(getUserTasks(UserInfo.getUserId(),null));
        return taskList;
    }

    /**
     * the ID of the current users manager
     * @type {String}
     */
    global static String managerId = '';

    /**
     * getter for managerId
     */
    global static String getManagerId () {
        Id tempId = UserInfo.getUserId();
        String answer = '';
        List<User> userList = [SELECT ManagerId FROM User WHERE Id =: tempId LIMIT 1];
        if (!userList.isEmpty()) {
            answer = userList[0].ManagerId;
        }
        managerId = JSON.serialize(answer);
        return managerId;
    }

    /**
     * the ID of the current users manager
     * @type {String}
     */
    global static String userName = '';
    global static String getUserName () {
        userName = JSON.serialize(UserInfo.getName());
        return userName;
    }

    /**
     * @type {String}
     */
    global static String userPhoto = '';
    global static String getUserPhoto () {
        Id tempId = UserInfo.getUserId();
        String answer = '';
        List<User> userList = [SELECT SmallPhotoUrl FROM User WHERE Id =: tempId LIMIT 1];
        if (!userList.isEmpty()) {
            answer = userList[0].SmallPhotoUrl;
        }
        userPhoto = JSON.serialize(answer);
        return userPhoto;
    }

    /**
     * get the LABEL of an object by its ID
     * @param  inId the id to inspect
     * @return      the SF Label of the object that the ID belongs to
     */
    global static String getObjectTypeById (Id inId) {
        Long funtionTimeStart = System.currentTimeMillis();
        String objectType = '';
        // Validate input
        if (inId != null) {
            String prefix = (String) inId;
            prefix = prefix.substring(0, 3);
            // Check to see if we KNOW this prefix already
            if (objectKeyPrefix.containsKey(prefix)) {
                // if we know it send it
                objectType = (String) objectKeyPrefix.get(prefix);
            } else {
                // If we don't know it get it then send it
                Schema.SObjectType token        = inId.getSObjectType();
                Schema.DescribeSObjectResult dr = token.getDescribe();
                objectType                      = dr.getLabel();
                objectKeyPrefix.put(prefix, objectType);
            }
        }
        // Benchmarking
        if (enableBenchmarking) {
            System.debug(performanceLogLevel, 'getObjectTypeById Finish time: ' + (System.currentTimeMillis() - funtionTimeStart));
            System.debug(performanceLogLevel, 'Total Time: ' + (System.currentTimeMillis() - classStartTime));
        }
        return objectType;
    }

    /**
     * get names from a specified Object type and perform an auto-complete helper query.
     * @param  inType        the type of OBJECT to query
     * @param  inPartialName the partial name to match
     * @return               a list of elements matching the criteria for jquery auto-complete
     */
    @RemoteAction @ReadOnly
    global static List<JQueryUIAutocomplete> getRelatedObjects (String inType, String inPartialName) {
        Long funtionTimeStart = System.currentTimeMillis();
        List<JQueryUIAutocomplete> returnData = new List<JQueryUIAutocomplete>();
        Boolean isUsable = true;
        if (inPartialName == null || (inPartialName.length() < AUTOCOMPLETE_MIN_LENGTH)) {
            isUsable = false;
        }
        if (inType == '' || inType == null || inType.length() == 0 || inType == 'null' || inType == 'undefined') {
            isUsable = false;
        }
        if (isUsable) {
            try {
                if (RELATED_TO_MAP.containsKey(inType) || AVAIL_WHO_TYPES.containsKey(inType)) {
                    String tableToQuery = '';
                    if (RELATED_TO_MAP.containsKey(inType)) {
                        tableToQuery = (String) RELATED_TO_MAP.get(inType);
                    }
                    if (AVAIL_WHO_TYPES.containsKey(inType)) {
                        tableToQuery = (String) AVAIL_WHO_TYPES.get(inType);
                    }
                    String queryString = 'SELECT Id, Name FROM ' + tableToQuery + ' WHERE ';
                    queryString        += 'Name LIKE \'' + String.escapeSingleQuotes(inPartialName) + '%\' ';
                    if (inType == 'Lead') {
                        queryString += ' AND IsConverted = false ';
                    }
                    queryString        += 'ORDER BY Name ASC ';
                    queryString        += 'LIMIT ' + AUTOCOMPLETE_QUERY_LIMIT;
                    List<SObject> relatedList = Database.query(queryString);
                    Integer len = relatedList.size();
                    Set<Id> foundSet = new Set<Id>();
                    for (Integer ii = 0; ii < len; ii++) {
                        if (!foundSet.contains(relatedList[ii].Id)) {
                            foundSet.add(relatedList[ii].Id);
                        }
                    }
                    if (relatedList.size() < AUTOCOMPLETE_QUERY_LIMIT) {
                        String queryString2 = 'SELECT Id, Name FROM ' + tableToQuery + ' WHERE ';
                        queryString2        += 'Name LIKE \'%' + String.escapeSingleQuotes(inPartialName) + '%\' ';
                        if (inType == 'Lead') {
                            queryString2 += ' AND IsConverted = false ';
                        }
                        queryString2        += 'AND Id NOT IN: foundSet '; // prevent duplicates.
                        queryString2        += 'ORDER BY Name ASC ';
                        queryString2        += 'LIMIT ' + (AUTOCOMPLETE_QUERY_LIMIT - relatedList.size());
                        List<SObject> relatedList2 = Database.query(queryString2);
                        if (relatedList2.size() > 0) {
                            relatedList.addAll(relatedList2);
                        }
                    }
                    len = relatedList.size();
                    for (Integer ii = 0; ii < len; ii++) {
                        JQueryUIAutocomplete tempAC = new JQueryUIAutocomplete();
                        SObject tempObj = relatedList[ii];
                        tempAC.id     = tempObj.Id;
                        tempAC.label  = (String) tempObj.get('Name');
                        tempAC.value  = (String) tempObj.get('Name');
                        returnData.add(tempAC);
                    }
                } else {
                     throw new TaskManager2Exception(INVALID_OBJECT_ERROR);
                }
            } catch (Exception e) {
                // Don't Do anything.
                System.debug(e);
            }
        }
        if (enableBenchmarking) {
            System.debug(performanceLogLevel, 'getRelatedObjects Finish time: ' + (System.currentTimeMillis() - funtionTimeStart));
            System.debug(performanceLogLevel, 'Total Time So Far: ' + (System.currentTimeMillis() - classStartTime));
        }
        return returnData;
    }

    /**
     * Get the Assign To "TYPE" of a user (owner) to display properly.
     * @param  inUserProfileName the profile name of the user
     * @return                   the string description of the profile to display.
     */
    global static String getUserType (String inUserProfileName) {
        Long funtionTimeStart = System.currentTimeMillis();
        String userType = '';
        List<String> listOfprofileTypes = new List<String>(AVAIL_ASSIGNED_TO_TYPES.keySet());
        Integer len = listOfProfileTypes.size();
        for (Integer ii = 0; ii < len; ii++) {
            Set<String> profileNames = (Set<String>) AVAIL_ASSIGNED_TO_TYPES.get(listOfprofileTypes[ii]);
            if (profileNames.contains(inUserProfileName)) {
                userType = listOfprofileTypes[ii];
                break;
            }
        }
        if (enableBenchmarking) {
            System.debug(performanceLogLevel, 'getUserType Finish time: ' + (System.currentTimeMillis() - funtionTimeStart));
            System.debug(performanceLogLevel, 'Total Time So Far: ' + (System.currentTimeMillis() - classStartTime));
        }
        return userType;
    }

    /**
     * get users to assign a task to
     * @param  inType        the type of user to search for
     * @param  inPartialName the type name to search for
     * @return               a jquery autocomplete object
     */
    @RemoteAction @ReadOnly
    global static List<JQueryUIAutocomplete> getAvailUser (String inType, String inPartialName) {
        Long funtionTimeStart = System.currentTimeMillis();
        List<JQueryUIAutocomplete> returnData = new List<JQueryUIAutocomplete>();
        if (AVAIL_ASSIGNED_TO_TYPES.containsKey(inType)) {
            Set<String> profiles = (Set<String>) AVAIL_ASSIGNED_TO_TYPES.get(inType);
            String queryString = 'SELECT Id, Name, smallPhotoUrl, Profile.Name FROM User WHERE ';
            queryString        += '(FirstName LIKE \'' + String.escapeSingleQuotes(inPartialName) + '%\' ';
            queryString        += 'OR LastName LIKE \'' + String.escapeSingleQuotes(inPartialName) + '%\') ';
            queryString        += 'AND isActive = true ';
            queryString        += 'AND Profile.Name IN: profiles ';
            queryString        += 'ORDER BY FirstName ASC, LastName ASC ';
            queryString        += 'LIMIT ' + AUTOCOMPLETE_QUERY_LIMIT;
            List<User> userList = Database.query(queryString);
            Integer len = userList.size();
            Set<Id> foundSet = new Set<Id>();
            for (Integer ii = 0; ii < len; ii++) {
                if (!foundSet.contains(userList[ii].Id)) {
                    foundSet.add(userList[ii].Id);
                }
            }
            if (userList.size() < AUTOCOMPLETE_QUERY_LIMIT) {
                // if we did not get enough results results dig deeper
                String queryString2 =  'SELECT Id, Name, smallPhotoUrl, Profile.Name FROM User WHERE ';
                queryString2        += 'Name LIKE \'%' + String.escapeSingleQuotes(inPartialName) + '%\' ';
                queryString2        += 'AND isActive = true ';
                queryString2        += 'AND Profile.Name IN: profiles ';
                queryString2        += 'AND Id NOT IN: foundSet ';  // Exclude previously found data
                queryString2        += 'ORDER BY Name ASC ';
                queryString2        += 'LIMIT ' + (AUTOCOMPLETE_QUERY_LIMIT - userList.size());
                List<User> userList2 = Database.query(queryString2);
                if (userList2.size() > 0) {
                    userList.addAll(userList2);
                }
            }

            len = userList.size();
            for (Integer ii = 0; ii < len; ii++) {
                JQueryUIAutocomplete tempAC = new JQueryUIAutocomplete();
                User tempUser = userList[ii];
                tempAC.id     = tempUser.Id;
                tempAC.label  = tempUser.Name;
                tempAC.value  = tempUser.Name;
                tempAC.smallPhotoUrl = tempUser.smallPhotoUrl;
                tempAC.profileName = tempUser.Profile.Name;
                tempAC.userType = inType;
                returnData.add(tempAC);
            }
        }
        if (enableBenchmarking) {
            System.debug(performanceLogLevel, 'getAvailUser Finish time: ' + (System.currentTimeMillis() - funtionTimeStart));
            System.debug(performanceLogLevel, 'Total Time So Far: ' + (System.currentTimeMillis() - classStartTime));
        }
        return returnData;
    }

    /**
     * get all the tasks for a specific user
     * @param  userId The ID of the user to get tasks for
     * @return a List of Tasks
     */
    @RemoteAction @ReadOnly
    global static List<TaskOut> getUserTasks(Id userId,String status) {
        system.debug(status);
        Long funtionTimeStart = System.currentTimeMillis();
        List<TaskOut> returnData = new List<TaskOut>();
        // Perform quick sanity check
        
        if (userId != null) {
            // This query gets all tasks that are not complete
            List<Task> internalTaskList = new List<Task> ();
            string query = 'SELECT Id, Subject, Description, ActivityDate, Priority, Status, IsClosed, IsDeleted, CreatedById, CreatedBy.Name, CreatedBy.smallPhotoUrl, OwnerId, Owner.Id, Owner.Name, Owner.Profile.Name, WhatId, What.Id, What.Name, WhatCount, WhoId,  Who.Id, Who.Name, (SELECT RelationId, Relation.Name, isWhat from TaskRelations WHERE isWhat = false) FROM Task WHERE IsDeleted = false';
             if (status==null || status=='All Open'){
                query+=' AND Status!=\'Completed\'';
             } else if (status=='Any Status'){
             } else if (status=='Completed'){
                 query+=' AND Status=:status AND (ActivityDate >= :HOW_FAR_BACK  OR (ActivityDate = null AND LastModifiedDate >=: HOW_FAR_BACK_TO_ALLOW_NO_DUE_DATES ))';
             } else {
                query+=' AND Status=:status';
            }
            //status='Open';
            //
            query+= ' AND (OwnerId =: userId OR CreatedById =: userId ) ORDER BY Priority DESC, ActivityDate ASC NULLS FIRST LIMIT :MAX_ALLOWED_TASKS';
           

                            
            internalTaskList =  Database.query(query);
            system.debug(query);
            system.debug(internalTaskList);
            
            // Build a list of users we need photos for
            Integer len = 0;
            Set<Id> idsNeedingPhotos = new Set<Id>();
            len = internalTaskList.size();
            for (Integer ii = 0; ii < len; ++ii) {
                Task t = internalTaskList[ii];
                if (!idsNeedingPhotos.contains(t.OwnerId)) {
                    idsNeedingPhotos.add(t.OwnerId);
                }
            }
            // Get the usere photo urls
            Map<Id, User> userPhotos = new Map<Id, User> ([
                SELECT
                    Id,
                    smallPhotoUrl
                FROM
                    User
                WHERE
                    Id IN: idsNeedingPhotos
            ]);
            idsNeedingPhotos.clear();

            len = internalTaskList.size();
            for (Integer ii = 0; ii < len; ++ii) {
                Integer len2          = 0;
                Task t                = internalTaskList[ii];
                TaskOut temp          = new TaskOut();
                PersonDetails owner   = new PersonDetails();
                PersonDetails creator = new PersonDetails();
                ObjectDetails what    = new ObjectDetails();
                ObjectDetails who     = new ObjectDetails();
                User tempUser         = new User();
                tempUser              = (User) userPhotos.get(t.OwnerId);

                // Owner Details
                owner.id            = t.OwnerId;
                owner.name          = t.Owner.Name;
                owner.smallPhotoUrl = tempUser.smallPhotoUrl;
                owner.objectType    = getUserType(t.Owner.Profile.Name);
                temp.ownerDetails   = owner;
                temp.ownerId        = t.OwnerId;

                // Creator Details
                creator.id            = t.CreatedById;
                creator.name          = t.CreatedBy.Name;
                creator.smallPhotoUrl = t.CreatedBy.smallPhotoUrl;
                creator.objectType    = getObjectTypeById(t.CreatedById);
                temp.creatorDetails   = creator;

                // What Details
                what.id         = t.WhatId;
                what.name       = t.What.Name;
                what.objectType = getObjectTypeById(t.WhatId);
                temp.what       = what;
                temp.whatCount  = t.WhatCount;
                temp.whatId     = t.WhatId;

                // Who Details
                temp.whoId   = t.WhoId;
                temp.whoName = t.Who.Name;
                temp.whoType = getObjectTypeById(t.WhoId);

                // Task Details
                temp.id           = t.Id;
                temp.name         = null;
                temp.subject      = t.Subject;
                temp.priority     = t.Priority;
                temp.status       = t.Status;
                temp.activityDate = t.ActivityDate;
                temp.description  = t.Description;

                len2 = t.TaskRelations.size();
                for (Integer jj = 0; jj < len2; ++jj) {
                    TaskRelation tr            = t.TaskRelations[jj];
                    ObjectDetails tempRelation = new ObjectDetails();
                    tempRelation.id            = tr.RelationId;
                    tempRelation.name          = tr.Relation.Name;
                    tempRelation.objectType    = getObjectTypeById(tr.RelationId);
                    temp.who.add(tempRelation);
                }
                temp.whoCount     = temp.who.size();
                returnData.add(temp);
            }

            // Memory Cleanup
            internalTaskList.clear();
            userPhotos.clear();
        }
        if (enableBenchmarking) {
            System.debug(performanceLogLevel, 'getUserTasks Finish time: ' + (System.currentTimeMillis() - funtionTimeStart));
            System.debug(performanceLogLevel, 'Total Time So Far: ' + (System.currentTimeMillis() - classStartTime));
        }
        return returnData;
    }

    /**
     * Create a new task
     * @param  inTaskJSON           JSON task to insert
     * @param  inAdditionalContacts additional conacts to add to the task
     * @return                      the ID of the new task
     */
    @RemoteAction
    global static Id createTask (String inTaskJSON, List<Id> inAdditionalContacts) {
        Long funtionTimeStart = System.currentTimeMillis();
        inTaskJSON.replaceAll('\n', '\\\\n');
        Task inTask = (Task) JSON.deserialize(inTaskJSON, Task.class);
        if (inTask.ActivityDate != null) {
            if (inTask.ActivityDate.year() <= 1970) {
                inTask.ActivityDate = null;
            }
        }
        insert inTask;
        Integer len = inAdditionalContacts.size();
        List<TaskRelation> relatedContactList = new List<TaskRelation>();
        Set<Id> additionalContactSet = new Set<Id>();
        for (Integer ii = 0; ii < len; ii++) {
            Id currentId = inAdditionalContacts[ii];
            // Prevent Duplicates
            if (currentId != inTask.WhoId && !additionalContactSet.contains(currentId)) {
                TaskRelation contactEntry = new TaskRelation();
                contactEntry.TaskId       = inTask.Id;
                contactEntry.RelationId   = currentId;
                contactEntry.isWhat       = false;
                relatedContactList.add(contactEntry);
                additionalContactSet.add(currentId);
            }
        }
        if (relatedContactList.size() > 0) {
            insert relatedContactList;
        }
        if (enableBenchmarking) {
            System.debug(performanceLogLevel, 'createTask Finish time: ' + (System.currentTimeMillis() - funtionTimeStart));
            System.debug(performanceLogLevel, 'Total Time So Far: ' + (System.currentTimeMillis() - classStartTime));
        }
        return inTask.Id;
    }

    /**
     * Update a task information
     * @param  inTasks the tasks to update (JSON FORMAT)
     * @return         the count of the tasks updated.
     */
    @RemoteAction
    global static void updateTask (String inTaskJSON, List<Id> inAdditionalContacts) {
        Long funtionTimeStart = System.currentTimeMillis();
        inTaskJSON.replaceAll('\n', '\\\\n');
        Task inTask = (Task) JSON.deserialize(inTaskJSON, Task.class);
        if (inTask.ActivityDate != null) {
            if (inTask.ActivityDate.year() <= 1970) {
                inTask.ActivityDate = null;
            }
        }
        update inTask;
        if (inAdditionalContacts.size() > 0) {
            // Clear out old relations
            Integer len = inAdditionalContacts.size();
            List<TaskRelation> relatedContactList = new List<TaskRelation>();
            Set<Id> additionalContactSet = new Set<Id>();
            for (Integer ii = 0;ii < len; ii++) {
                Id currentId = inAdditionalContacts[ii];
                // Prevent Duplicates
                if (currentId != inTask.WhoId && !additionalContactSet.contains(currentId)) {
                    TaskRelation contactEntry = new TaskRelation();
                    contactEntry.TaskId       = inTask.Id;
                    contactEntry.RelationId   = currentId;
                    contactEntry.isWhat       = false;
                    relatedContactList.add(contactEntry);
                    additionalContactSet.add(currentId);
                }
            }
            // Delete everything that is NOT the primary contact
            Id taskId = inTask.Id;
            Id whoId = inTask.WhoId;
            delete [
                Select
                    Id
                FROM
                    TaskRelation
                WHERE
                    TaskId =: taskId
                    AND isWhat = false
                    AND RelationId != :whoId
            ];
            // Insert the rest.
            insert relatedContactList;
        } else {
            // Delete All the who's
            Id taskId = inTask.Id;
            Id whoId = inTask.WhoId;
            delete [
                Select
                    Id
                FROM
                    TaskRelation
                WHERE
                    TaskId =: taskId
                    AND isWhat = false
                    AND RelationId != :whoId
            ];
        }
        if (enableBenchmarking) {
            System.debug(performanceLogLevel, 'updateTask Finish time: ' + (System.currentTimeMillis() - funtionTimeStart));
            System.debug(performanceLogLevel, 'Total Time So Far: ' + (System.currentTimeMillis() - classStartTime));
        }
    }

    /**
     * Delete tasks by ID
     * @param  inTaskIds a list of IDs to delete
     * @return           the number of tasks deleted.
     */
    @RemoteAction
    global static void deleteTaskById (Id inTaskId) {
        Long funtionTimeStart = System.currentTimeMillis();
        delete [
            SELECT
                Id
            FROM
                Task
            WHERE
                Id =: inTaskId
            LIMIT 1
        ];
        if (enableBenchmarking) {
            System.debug(performanceLogLevel, 'deleteTaskById Finish time: ' + (System.currentTimeMillis() - funtionTimeStart));
            System.debug(performanceLogLevel, 'Total Time So Far: ' + (System.currentTimeMillis() - classStartTime));
        }
    }
}