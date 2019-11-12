({
    doInit:function(component,event,helper){
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
 
        console.log(paramValue.id);
        component.set('v.DealId',paramValue.id);
        
        var action = component.get('c.getOppMap');
        action.setParams({ dealId : paramValue.id});

        action.setCallback(this,function(response){
            component.set('v.OppMap',response.getReturnValue());
        });
        $A.enqueueAction(action);
        
    }
})