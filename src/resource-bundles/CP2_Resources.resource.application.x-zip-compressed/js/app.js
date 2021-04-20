
//------  AngularJS functions----------------------------------
//var cModule = angular.module('cPortal', []);
var cModule = angular.module("cPortal", ['ui', 'ngResource']).
    config(function($routeProvider) {
        $routeProvider.
			when('#/', { controller: FormsController, templateUrl: 'dashboard.html' }).
            when('/application', { controller: FormsController, templateUrl: 'application.html' }).
			when('/dashboard', { controller: DashController, templateUrl: 'dashboard.html' }).
			when('/docs', { controller: DocsController, templateUrl: 'docs.html'}).
			when('/issues', { controller: IssuesController, templateUrl: 'issues.html'}).
            otherwise({ redirectTo: '/dashboard' });
   		}).run(['$rootScope', '$location', function($rootScope, $location){		//code to toggle active tabs
			var path = function() { return $location.path();};
		   $rootScope.$watch(path, function(newVal, oldVal){
		     $rootScope.activetab = newVal;
		   });
		}]);
		
		
		
		
//angular.bootstrap('cPortal', ['ngResource'], ['ui']);
	
cModule.directive('fadey', function() {
    return {
        restrict: 'A',
        link: function(scope, elm, attrs) {
            var duration = parseInt(attrs.fadey);
            if (isNaN(duration)) {
                duration = 500;
            }
            elm = jQuery(elm);
            elm.hide();
            elm.fadeIn(duration)

            scope.destroy = function(complete) {
                elm.fadeOut(duration, function() {
                    if (complete) {
                        complete.apply(scope);
                    }
                });
            };
        }
    };
});
cModule.filter('fCurrency', function() {
    return function(input) {
      if(input)
      {
		return (input + "$$$");
      }         
    }
});
cModule.filter('addCommas', function () {
    return function (input) {
        input += '';
        x = input.split('.');
        x1 = x[0];
        x2 = x.length > 1 ? '.' + x[1] : '';
        var rgx = /(\d+)(\d{3})/;
        while (rgx.test(x1)) {
            x1 = x1.replace(rgx, '$1' + ',' + '$2');
        }
        return x1 + x2;
    }
});
cModule.filter('stripSpaces', function () {
    return function (input) {
        var t = input.replace(/ /g, '');
        var s = t.replace(',', '');
        var r = s.replace('.', '');
        return (r);
    }
});

function getCount(word, arr) {
    var i = 0, n = arr.length, count = 0;
    for (; i < n; ++i) {
        if (arr[i].indexOf(word) >= 0) {
            ++count;
        }
    }
    return count;
}

function rekey(obj) {
    //This function takes an array with numbered property names and if neccesary renumbers them starting at 0.
    //If any properties missing in a numeric sequence, it renumbers them so they are consecutive and don't skip any.
    //For ex: friend4:bob, friend9:sam => friend0:bob, friend1:sam. Section5-9 are skipped because they are actual field Names.
    var rekey = /^(.*?)(\d+)$/;
    var nestedobj = {}, newobj = {}, skipped = {};
    var key, basekeyrv, newkey, oldidx, newidx;
    function basekey(key) {
        return rekey.exec(key).splice(1);
    }
    for (key in obj) {
        if (obj.hasOwnProperty(key) && key.regexIndexOf('^[A-z]+$') && key.regexIndexOf('Section[5-9]')) {  //checks for key and regex checks to make sure key has a number at the end
            basekeyrv = basekey(key);
            newkey = basekeyrv[0];
            oldidx = parseInt(basekeyrv[1], 10);
            if (!nestedobj[newkey]) {
                nestedobj[newkey] = [];
            }
            nestedobj[newkey].push([oldidx, obj[key]]);
        }
            //else put the skipped properties in a new array. They don't need to be reordered and we'll combine them back at the end.
        else {
            if (!skipped[key]) {
                skipped[key] = [];
            }
            skipped[key].push(obj[key]);
        }
    }
    //Merge the two. First off, add the skipped items back into the array.
    for (key in skipped) {
        newobj[key] = skipped[key][0];
    }
    //Now add the reoderable ones
    for (key in nestedobj) {
        if (nestedobj.hasOwnProperty(key)) {
            nestedobj[key].sort();
            for (newidx = 0; newidx < nestedobj[key].length; newidx++) {
                newobj[key + newidx] = nestedobj[key][newidx][1];
            }
        }
    }
    return newobj;
}

function DashController($scope, $location, $http){
	$scope.currentDate = moment().format('MMMM Do YYYY');
	
	$http.get('jsonData/dashboardData.json').success(function (data) {
        $scope.dashboardData = data;
    });

}

function FormsController($scope, $location, $http, $timeout) {
    $http.get('jsonData/forms.json').success(function (data) {
        $scope.formsData = data;
    });

	$scope.special = "GREOGIJEROIGJER";
    $scope.saveData = {};
    $scope.saveDataHidden = false;
    $scope.saveDataKeys = {};
    $scope.saveInProgress = false;

	//these arrays represent the fields in different multiple entry objects. They allow us to  walk through the saveData object and
	//delete relevant fields (when a user hits the remove button on a multiple object)
    $scope.EducationElements = ["Institution", "InstitutionType", "EducationDateFrom", "EducationDateTo"];
    $scope.WorkElements = ["WorkExperienceBusinessName", "Location", "LocationDateFrom", "LocationDateTo", "Title", "Duties"];
    $scope.NotesPayableElements = ["NotesPayableToBankNameAndAddress", "NotesPayableToBankOriginalBalance", "NotesPayableToBank", "NotesPayableToBankHowSecured", "NotesPayableToBankFrequency", "NotesPayableToBankPaymentAmount", "NotesPayableToBankCurrentBalance"];
    $scope.StocksBondsElements = ["TotalValue", "DateOfQuotation", "MarketValue", "Cost", "NumberOfShares"];
    $scope.BusinessOwnershipElements = ["OwnerAddress", "OwnerEmail", "OwnershipPct", "OwnerName"];

    $http.get('jsonData/saveData.json').success(function (data) {
        $scope.saveData = data; // if you want fields prepopulated with save data
        $scope.saveDataKeys = _.keys(data); //Gets an array of only the properties
        //console.log($scope.saveDataKeys);
    });

    $scope.getArrayFromSavedDataContaining = function (word) {
        var i = 0, n = $scope.saveDataKeys.length, outarr = [];
        for (; i < n; ++i) {
            if ($scope.saveDataKeys[i].indexOf(word) >= 0) {  //works, just trying a regex version
                outarr.push($scope.saveDataKeys[i]);
            }
        }
        //console.log(outarr);
        return outarr;
    }

    $scope.toggleSaveData = function () {
        $scope.saveDataHidden = !$scope.saveDataHidden;
    }

	$scope.clearData = function(){
		$scope.saveData = {};
		$scope.totalWorkExperience = 0;
	}

    $scope.addMultipleItem = function (type) {
        //debugger;
	    var t = $scope.getArrayFromSavedDataContaining(type); //Gets an array of all properties containing this substring(type) as 1d strings
	    $scope.saveData[type+t.length] = ""; //Creates an incremented property name of type, assigns it to null so that a new item is displayed in list
	    $scope.saveDataKeys = _.keys($scope.saveData); //Update the  array of only the properties
	};

    $scope.removeSingleMultipleItem = function (type, index) {
        //debugger;
        //this.destroy(function () {  //This fadeout method is not updating the model correctly.
            var i = 0, n = $scope[type].length;

            for (; i < n; i++) {
                $scope.saveData = _.omit($scope.saveData, $scope[type][i] + index); //Removes all items from saveData of type+index. Does not re-number existing properties at this time.
            }

            $scope.saveDataKeys = _.keys($scope.saveData); //Update the  array of only the properties
            $scope.saveData = rekey($scope.saveData);
        //});
    };

    $scope.saveSection = function () {
        $scope.saveInProgress = true;
        $timeout(function () {
            $scope.saveInProgress = false;
        }, 3000);
    }
	
	$scope.renumberProperties = function (data, type){
	    var i = 0, n = $scope[type].length;
	    for (; i < n; i++) {
	        //Rename each instance of a property name $scope[type][i] in saveData
	        //Get how many properties containing each of the elements in type
	        var arr = $scope.getArrayFromSavedDataContaining($scope[type][i]);
	        //console.log(arr);
	    }
	}

	// $scope.totalWorkExperience = 1;
	// 
	// $scope.workExperienceList = [
	// 	{ value: "1", text: "1" }
	// ];

	// $scope.addWorkExperience = function () {
	//     $scope.workExperienceList.push({ value: "2", text: "2" });
	// };
	// 
	// $scope.removeWorkExperience = function (index) {
	//     $scope.workExperienceList.splice(index, 1);
	// };

	$scope.getFields = function(obj){
		return obj.Fields;
	}
	
	$scope.getOptions = function(field){
		return field.Options;
	}
	$scope.getDescriptionItem = function(field){
		return field.Description;
	}

	$scope.getMultipleItemFields = function (field) {
	    return field.Fields;
	}
	
	$scope.getDescriptionItemOptions = function(descriptionItem)
	{
		return descriptionItem.Options;
	}
	
	$scope.collapseAllSections = function(){
		$('.box-content').slideUp();
		$('.halflings-icon.chevron-up').removeClass('chevron-up').addClass('chevron-down');
	}
}

function WorkController($scope){
	$scope.totalWorkExperience = 1;
	
	$scope.workExperienceList = [
		{value:"1", text:"1"}
	];
	
	$scope.addWorkExperience = function (){
		$scope.workExperienceList.push({value:"2", text:"2"});
	};
	
	$scope.removeworkExperience = function(index){
		$scope.workExperienceList.splice(index,1);
	};
}

function IssuesController($scope, $http){
    $http.get('jsonData/issues.json').success(function (data) {
        $scope.issuesData = data;
    });
    $http.get('jsonData/messages.json').success(function (data) {
        $scope.messagesData = data;
    });
    $http.get('jsonData/loanLog.json').success(function (data) {
        $scope.loanLogData = data;
    });

	$scope.getLoanLogIcon = function(type){
		//fa-icon-map-marker = appointment
		if (type == "appointment"){
			return "fa-icon-map-marker";	
		}
		else if (type == "phone call"){
			return "fa-icon-phone";
		}
		else if (type == "video call"){
			return "fa-icon-facetime-video";
		}

	}

}

function DocsController($scope, $http){
	$scope.modalData = { name:"GFREG", description:"gregerg"};
	$scope.fullDocsData = {};
	$scope.docsBorrower = false;
	$scope.docsBank = false;
	$scope.docsAttorney = false;
	$scope.docsThirdParty = false;	
	
	//Sample data set for Applications. To be replaced by API call.
    $http.get('jsonData/docs.json').success(function (data) {
		$scope.fullDocsData = data;
        $scope.docsData = $scope.fullDocsData;
    });
	
	$scope.setModalData = function(docID){
		$scope.modalData = _.findWhere($scope.docsData, {id: docID});
	}
	
	$scope.setFilter = function(){
		if ($scope.docsBorrower || $scope.docsBank || $scope.docsAttorney || $scope.docsThirdParty){ 	//if any of the filters are checked
			$scope.docsData = $scope.fullDocsData;
			
			$scope.docsData = _.filter ($scope.fullDocsData, function(obj) {
				if (obj.owner == "Bank" && $scope.docsBank){
					return obj.owner;
				}
				if (obj.owner == "Borrower" && $scope.docsBorrower){
					return obj.owner;
				}
				if (obj.owner == "Borrower's Attorney" && $scope.docsAttorney){
					return obj.owner;
				}
				if (obj.owner == "Third Party" && $scope.docsThirdParty){
					return obj.owner;
				}
				
			   // return obj.owner == "Bank" || obj.owner == "Borrower";
			});
		}
		else{
			$scope.docsData = $scope.fullDocsData; //else nothing is checked so show everything (the original data set)
		}

	}

	$scope.getLabelType = function(status){
		if (status == "In-File"){
			return 'label-warning';
		}
		if (status == "Reviewed"){
			return 'label-info';
		}
		if (status == "Approved"){
			return 'label-success';
		}
	}

	$scope.makeStatusUserFriendly = function(status){
		if (status == "Open"){
			return ' Waiting for document upload';
		}
		if (status == "In-File"){
			return ' Pending';
		}
		if (status == "Reviewed"){
			return ' Needs resolving';
		}
		if (status == "Approved"){
			return ' Complete';
		}
	}
	//This function creates a button if necessary if needed for the action column based on the status field
	$scope.createActionButton = function(action, id){
		if (action == "Open")
			return '<a href="#docModal" data-toggle="modal"><button type="button" class="btn btn-small"><i class="halflings-icon flag"></i> Upload</button></a>';
		if (action == "Reviewed")
			return '<a href="#docModal" data-toggle="modal"><button type="button" class="btn btn-small"><i class="halflings-icon flag"></i> Resolve</button></a>';	
	}
	
	//This function completes the icon class name based on the owner field in json data
	$scope.getIconType = function(owner){
		switch (owner){
			case "Borrower":
				return 'user';
			case "Bank":
				return 'home';
			case "Borrower's Attorney":
				return 'briefcase';
			case "Third Party":
				return 'tasks'
		}
	}
	
	//This function creates the Status html cel of the Docs table.
	$scope.createStatus = function(status){
		if (status == "Open"){
			return '<span class="label"> Waiting for document upload</span>';
		}
		if (status == "In-File"){
			return '<span class="label label-warning"> Pending</span>';
		}
		if (status == "Reviewed"){
			return '<span class="label label-info"> Needs resolving</span>';
		}
		if (status == "Approved"){
			return '<span class="label label-success"> Complete</span>';
		}
	}
}





//-----  Form Tab Functions------------------------------------

$(document).on('click', '.box-header', function (e) {
    //This function toggles the visibility of form sections when you click anywhere in their header
	e.preventDefault();
    var $target = $(this).next('.box-content');
    var $itarget = $(this).children('.box-icon').children().children('.halflings-icon');
    //console.log($itarget.length);
    if ($target.is(':visible')) $($itarget).removeClass('chevron-up').addClass('chevron-down');
    else $($itarget).removeClass('chevron-down').addClass('chevron-up');
    $target.slideToggle();
    return false;
});
$(document).on('click', '.docs-header', function (e) {
    //This function toggles the visibility of form sections when you click anywhere in their header
	e.preventDefault();
    var $target = $(this).siblings('table');
    var $itarget = $(this).children('.box-icon').children().children('.halflings-icon');
    if ($target.is(':visible')) $($itarget).removeClass('chevron-up').addClass('chevron-down');
    else $($itarget).removeClass('chevron-down').addClass('chevron-up');
    $target.slideToggle();
    return false;
});

$(document).on('click', '.nextButton', function () {
    //get the TabGroup attribute and only apply the tab advance to that group. Otherwise every tab on the page moves when you click.
	var r = $(this).attr('tabGroup');
		//console.log(r);
    var f = ($('.nav-tabs[tabGroup=' + r + '] li.active').next().find('a[data-toggle="tab"]'));
    if (f.length > 0) {
        f.click();
    }
	return false; //prevent the page from jumping around
});
$(document).on('click', '.prevButton', function () {
    //get the TabGroup attribute and only apply the tab advance to that group. Otherwise every tab on the page moves when you click.
	var r = $(this).attr('tabGroup');
    var f = ($('.nav-tabs[tabGroup=' + r + '] li.active').prev().find('a[data-toggle="tab"]'));
    if (f.length > 0) {
        f.click();
    }
	return false; //prevent the page from jumping around
});


$(document).ready(function () {
    $('.control-label').tooltip();
    //$('.currency').livequery(function () { $('.currency').priceFormat({ prefix: '' }); });
    $('.currency').livequery(function () {
        $('.currency').priceFormat({prefix:''});
        //$('.currency').parseNumber({format:"#,###.00", locale:"us"});
        //$('.currency').formatNumber({format:"#,###.00", locale:"us"});
    });
	
	setTimeout(function () {
	    //Trigger all but the first section to close
        //This needs to be called from Angular rather than a timeout.
	    $('.box-header:gt(0)').trigger('click');
	}, 220);
	
//-----   Docs Tab Functions--------------------------------------------
	$('#completedApplicationCheckbox').change(function(event){
		if (!$(this).is(':checked')) {
			$('.application-approved').hide();
			return false;
		}
		else {
			$('.application-approved').show();
		}	
	});

    function nextTab() {
        var e = $('.nav-tabs li.active').next().find('a[data-toggle="tab"]');
        if (e.length > 0) {
            e.click();
        }
    }
    function prevTab() {
        var e = $('.nav-tabs li.active').prev().find('a[data-toggle="tab"]');
        if (e.length > 0) {
            e.click();
        }
    }

    //Click to close each Application section, Deprecated because entire header triggers click
    $(document).on('click', '.btn-minimize', function (e) {
    //e.preventDefault();
    //var $target = $(this).parent().parent().next('.box-content');
    //if ($target.is(':visible')) $('i', $(this)).removeClass('chevron-up').addClass('chevron-down');
    //else $('i', $(this)).removeClass('chevron-down').addClass('chevron-up');
    //$target.slideToggle();
    //return false;
    });
});


Object.defineProperty(
    Object.prototype,
    'renameProperty',
    {
        writable: false, // Cannot alter this property
        enumerable: false, // Will not show up in a for-in loop.
        configurable: false, // Cannot be deleted via the delete operator
        value: function (oldName, newName) {
            // Check for the old property name to 
            // avoid a ReferenceError in strict mode.
            if (this.hasOwnProperty(oldName)) {
                this[newName] = this[oldName];
                delete this[oldName];
            }
            return this;
        }
    }
);

String.prototype.regexIndexOf = function (regex, startpos) {
    var indexOf = this.substring(startpos || 0).search(regex);
    return (indexOf >= 0) ? (indexOf + (startpos || 0)) : indexOf;
}

