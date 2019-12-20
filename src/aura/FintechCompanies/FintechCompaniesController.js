({
    init: function (cmp, event, helper) {
        helper.getTotalCount(cmp);
        helper.fetchData(cmp,event, helper);
    },
    
    onClick: function(cmp, event, helper) {
        var id = event.target.dataset.menuItemId;
        if (!id.includes('http')){
            id = 'https://' + id;
        }
        window.open(id);
    },
    performSearch: function(cmp, event, helper) {
        
        var timer = cmp.get('v.timer');
        clearTimeout(timer);

        var timer = setTimeout(function(){
            var newlst = [];
            cmp.set("v.pageNumber", 1);
            helper.getTotalCount(cmp);
            helper.fetchData(cmp,event, helper);
            clearTimeout(timer);
            cmp.set('v.timer', null);
        }, 400);

        cmp.set('v.timer', timer);
        
        
        
    	
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