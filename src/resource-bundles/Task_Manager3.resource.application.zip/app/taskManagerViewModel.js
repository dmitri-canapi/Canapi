define(
    ['knockout', 'lodash', 
     'lib/TaskManager/TaskDef', 'initialDataLoad', 'lib/TaskManager/PersonDef', 
     'lib/TaskManager/ObjectDef', 'moment', 'ConfigOptions',
     'knockout-jqueryui/datepicker'],
    function (ko, _, TaskDef, initData, PersonDef, ObjectDef, moment, ConfigOptions) {
        var prepData = function (inList) {
            var whom, whoList, task,
                taskList = [];
            // Prep the data
            _.forEach(inList, function (entry) {
                whom = null;
                whoList = [];
                if (entry.who && entry.who.length > 0) {
                    _.forEach(entry.who, function (entryWho) {
                        whom = new PersonDef()
                            .id(entry.who.id)
                            .name(entry.who.name)
                            .smallPhotoUrl(entry.who.smallPhotoUrl)
                            .objectType(entry.who.objectType);
                        whoList.push(whom);
                    });
                }
                task = new TaskDef()
                    .id(entry.id)
                    .name(entry.name)
                    .ownerDetails(
                        new PersonDef()
                            .id(entry.ownerDetails.id)
                            .name(entry.ownerDetails.name)
                            .smallPhotoUrl(entry.ownerDetails.smallPhotoUrl)
                            .objectType(entry.ownerDetails.objectType)
                    )
                    .creatorDetails(
                        new PersonDef()
                            .id(entry.creatorDetails.id)
                            .name(entry.creatorDetails.name)
                            .smallPhotoUrl(entry.creatorDetails.smallPhotoUrl)
                            .objectType(entry.creatorDetails.objectType)
                    )
                    .activityDate(moment(entry.activityDate, 'YYYY-MM-DD').format('MM/DD/YYYY'))
                    .subject(entry.subject)
                    .priority(entry.priority)
                    .status(entry.status)
                    .description(entry.description)
                    .whatId(entry.whatId)
                    .whatCount(entry.whatCount)
                    .what(
                        new ObjectDef()
                            .id(entry.what.id)
                            .name(entry.what.name)
                            .objectType(entry.what.objectType)
                    )
                    .whoId(entry.whoId)
                    .whoName(entry.whoName)
                    .whoCount(entry.whoCount)
                    .whoType(entry.whoType)
                    .who(whoList)
                    .editMode(false);
                console.log(task);
                taskList.push(task);
            });
            return taskList;
        };
        var taskManagerViewModel = function () {
            this.getRelatedTo = function (searchType, searchTerm, sourceArray) {
                Task_Manager2.getRelatedObjects(searchType, searchTerm, 
                    function (result, event) {
                        if (event.type === 'exception') {
                            alert([event.message]);
                        } else if (event.status) {
                            var len = result.length,
                                newList = [];
                            for (var ii = 0; ii < len; ii += 1) {
                                newList.push(new Person().id(result[ii].id).name(resutl[ii].label));
                            }
                            sourceArray(newList);
                        } else {
                            alert([event.message]);
                        }
                    }
                );
            };
            this.relatedToAutoCompleteList = ko.observableArray();
            this.myTaskList = ko.observableArray(prepData(initData.taskList));
            this.allowedPriorities = ko.observableArray(ConfigOptions.allowedPriorities);
            this.relatedToTypes = ko.observableArray(ConfigOptions.relatedToTypes);
            this.allowedStatuses = ko.observableArray(ConfigOptions.allowedStatuses);
            this.whoTypes = ko.observableArray(ConfigOptions.whoTypes);
        };
        return taskManagerViewModel;
    }
);