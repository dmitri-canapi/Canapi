({	
    getTotalCount :  function(component) {
        var totalCnt = component.get("c.getTotalCount");
        totalCnt.setParams({
            'filter':component.get("v.filter")
        });
        totalCnt.setCallback(this, function(a) {
            component.set("v.totalNumberOfRows", a.getReturnValue());
            if (a.getReturnValue()==0){
            	component.set("v.isLastPage", true);
            }
        });
        $A.enqueueAction(totalCnt);
    },
    fetchData: function (cmp,event,helper) {
        var action = cmp.get("c.getAccounts");
        var pageSize = cmp.get("v.pageSize").toString();
        var pageNumber = cmp.get("v.pageNumber").toString();
        action.setParams({
            'pageSize' : pageSize,
            'pageNumber' : pageNumber,
            'filter':cmp.get("v.filter")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                
                cmp.set("v.dataSize", data.length);
                
                if(((cmp.get("v.pageNumber")-1)*cmp.get("v.pageSize") + data.length) >= cmp.get("v.totalNumberOfRows")){
                    cmp.set("v.isLastPage", true);
                } else{
                    cmp.set("v.isLastPage", false);
                }
                
                cmp.set('v.data',data);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    }
})