({
    doInit: function (component, event, helper) {
        if (window.location.href.includes('https://canapi.force.com/alliance')) {
            component.set("v.CommunityName", 'alliance');
        } else {
            component.set("v.CommunityName", 'fintech');
        }
        if (component.get("v.objectName").includes('Latest Activity')) {
            window.setInterval(function () {
                var value = sessionStorage.getItem('setTopicFilteringHeader');

                sessionStorage.removeItem('setTopicFilteringHeader');
                if (value != null) {
                    if (value !== 'All Topics') {
                        component.set("v.objectName", "Latest Activity - " + JSON.parse(value).name);
                    } else {
                        component.set("v.objectName", "Latest Activity");
                    }

                }
            }, 500);
        }
        if (component.get("v.recordId") != '' && component.get("v.recordId") != null && (component.get("v.recordId").substring(0, 3) != '01Z' && component.get("v.recordId").substring(0, 3) != '00O')) {
            var objToImageMap = new Map([['Account', '18-Canapi-Icons-05.svg'], ['Contact', '18-Canapi-Icons-14.svg'], ['Board_Meeting__c', '18-Canapi-Icons-24.svg'],
            ['Opportunity', '18-Canapi-Icons-30.svg'], ['Assessment__c', '18-Canapi-Icons-37.svg'], ['Financial_Report__c', '18-Canapi-Icons-39.svg'],
            ['Round__c', '18-Canapi-Icons-41.svg'], ['Investment__c', '18-Canapi-Icons-41.svg'], ['Activity', '18-Canapi-Icons-09.svg']]);
            var objToPluralMap = new Map([['Account', 'Fintech'], ['Contact', 'Contacts'], ['Board_Meeting__c', 'Board Meetings'],
            ['Opportunity', 'Opportunities'], ['Assessment__c', 'Due Diligence Checklists'], ['Financial_Report__c', 'Financial Reports'],
            ['Round__c', 'Series'], ['Investment__c', 'Investors'], ['Activity', 'Activities']]);
            var objToLinkMap = new Map([['Account', 'fintech-companies'], ['Contact', 'Contacts'], ['Board_Meeting__c', 'Board_Meetings__r'],
            ['Opportunity', 'Opportunities'], ['Assessment__c', 'Assessments__r'], ['Financial_Report__c', 'Financial_Reports__r'],
            ['Round__c', 'Investment__r'], ['Investment__c', 'Investments__r'], ['Activity', 'Activities']]);


            var action = component.get("c.getInitValues");
            action.setParams({ recId: component.get("v.recordId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    var ow = response.getReturnValue();
                    console.log(ow);
                    component.set("v.objectName", ow.recordName);
                    component.set("v.sobjName", ow.sobjName);
                    if (ow.obj) {
                        if (!ow.obj.External_Logo__c)
                            ow.obj.External_Logo__c = null;
                    }
                    component.set("v.accObj", ow.obj);
                    component.set("v.breadcrumb2", ow.recordName);
                    component.set("v.breadcrumb2Link", "/alliance/s/detail/" + component.get("v.recordId"));
                    component.set("v.recType", ow.RecordType);
                    if (objToImageMap.has(ow.sobjName)) {
                        component.set("v.imageName", objToImageMap.get(ow.sobjName));
                        component.set("v.breadcrumb1", objToPluralMap.get(ow.sobjName));
                        if (ow.sobjName == 'Account') {

                            component.set("v.breadcrumb1Link", "/alliance/s/" + objToLinkMap.get(ow.sobjName));
                            if (ow.RecordType != 'Fintech') {
                                component.set("v.breadcrumb1", ow.RecordType);
                                component.set("v.breadcrumb1Link", "/alliance/s/account/Account/Default?Account-filterId=00B6A000004x5jTUAQ");
                                component.set("v.accLink", 'https://canapi.force.com/alliance/s/account/Account/Default?Account-filterId=00B6A000004x5jTUAQ');
                            }
                        } else {
                            component.set("v.breadcrumb1Link", "/alliance/s/relatedlist/" + ow.accID + '/' + objToLinkMap.get(ow.sobjName));
                            if (ow.RecordType != 'Fintech') {
                                component.set("v.accLink", 'https://canapi.force.com/alliance/s/account/Account/Default?Account-filterId=00B6A000004x5jTUAQ');
                            } else {
                                component.set("v.accLink", 'https://canapi.force.com/alliance/s/fintech-companies');
                            }
                        }

                        if ((ow.sobjName == 'Account' || ow.sobjName == 'Contact') && ow.UserAccountRT) {
                            if (
                                (ow.UserAccountRT == 'Bank' && (ow.RecordType == "Limited Partner" || ow.recordName.includes('(individual)'))) ||
                                (ow.RecordType == "Bank" && (ow.UserAccountRT == 'Limited Partner' || ow.UserAccountName.includes('(individual)')))
                            ) {
                                window.history.back();
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Error',
                                    message: 'You don\'t have access to this record.',
                                    duration: ' 5000',
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                            }

                        }

                    }

                    if (ow.accID != null) {
                        component.set("v.accountId", ow.accID);
                        component.set("v.accName", ow.accName);
                    }
                    if (ow.accDescription != null) {
                        component.set("v.accDescr", ow.accDescription);
                    }

                } else {
                    console.log(response.getError()[0].message)
                }
            });
            $A.enqueueAction(action);

        } else if (component.get("v.recordId") != '' && component.get("v.recordId") != null && (component.get("v.recordId").substring(0, 3) == '01Z' || component.get("v.recordId").substring(0, 3) == '00O')) {
            component.set("v.recordId", null);
        }

    }
})