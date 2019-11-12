({
    init: function (cmp, event, helper) {
        helper.getTotalCount(cmp);
        helper.fetchData(cmp,event, helper);
    },
    performSearch: function(cmp, event, helper) {
        cmp.set("v.pageNumber", 1);
        helper.getTotalCount(cmp);
        helper.fetchData(cmp,event, helper);
    },
    clearFilter: function(component,event,helper){
        component.set('v.filter','');
        var a = component.get('c.performSearch');
        $A.enqueueAction(a);
    },
    handleNext : function(cmp, event, helper) { 
        var pageNumber = cmp.get("v.pageNumber");
        cmp.set("v.pageNumber", pageNumber + 1);
        helper.fetchData(cmp,event, helper);
    },
     
    handlePrev : function(cmp, event, helper) {        
        var pageNumber = cmp.get("v.pageNumber");
        cmp.set("v.pageNumber", pageNumber - 1);
        helper.fetchData(cmp,event, helper);
    },
})