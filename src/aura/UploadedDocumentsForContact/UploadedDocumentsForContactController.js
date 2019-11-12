({
	doInit : function(component, event, helper) {
        window.addEventListener("message", function(event) {
            if (event.data.includes('showFilePreview')) {
                console.log(event.data);
                var fileId = event.data.split('-del-')[1];
                component.set("v.currentFileId", fileId);
            	component.set("v.isOpen", true);

            }
        }, false);
	},
    onUploadFinished : function(component, event, helper) {
        component.set("v.ReviewItemFiles", null);
        var action = component.get("c.getFileRecords");
        action.setParams({ parentId : component.get("v.Document.Id")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ReviewItemFiles", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    saveRecord: function (component, event, helper) {
        var record = component.get("v.Document");
        var riFiles = component.get("v.ReviewItemFiles");
        if(riFiles==null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please, attach documents.',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        } else {
            component.set("v.Document.Contact__c", component.get("v.recordId"));
            var action = component.get("c.saveRecordContr");
            action.setParams({ rec: JSON.stringify(component.get("v.Document"))});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state == 'SUCCESS') {   
                    document.getElementById('vfFrame').src = document.getElementById('vfFrame').src;
                    var cmpTarget = component.find('Modalbox');
                    var cmpBack = component.find('Modalbackdrop');
                    $A.util.removeClass(cmpBack,'slds-backdrop--open');
                    $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
                } else {
                    console.log('Failed with state: ' + state);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: response.getError()[0].message,
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    chageViewToUpload:function(component,event,helper){ 

        var action = component.get("c.getTags");
        action.setParams({ docHid: component.get("v.Document.Id")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {   
                var resultArray = response.getReturnValue();
                var options2 = [];
                if (resultArray!=null){
                    var res = resultArray;
                    console.log(res);
                    for (var i=0;i<res.length;i++){
                        var tName = res[i].Tag__r.Name;
                        if (res[i].Tag__r.ParentTag__c!=null){
                            tName = res[i].Tag__r.ParentTag__r.Name + ':' + tName;
                        
                            if (res[i].Tag__r.ParentTag__r.ParentTag__c!=null){
                                tName = res[i].Tag__r.ParentTag__r.ParentTag__r.Name + ':' + tName;
                            }
                        }
                        
                        options2.push({ value: res[i].Id, label: tName}); 
                    }
                }
                component.set("v.defaultOptions", options2);

            } else {
                console.log('Failed with state: ' + state);
            }
        });
        $A.enqueueAction(action);
        
        component.set("v.uploadView", 'uploadView');
    },
    chageViewToEditTags:function(component,event,helper){ 
        component.set("v.uploadView", 'tagEditView');
    },
    chageViewToTags:function(component,event,helper){ 
        component.set("v.uploadView", 'tagView');
    },
    handleRemove: function (component, event) {
        console.log(event.getSource().get('v.name'));
        
        var action = component.get("c.removeDocHelperTagAssoc");
        
        action.setParams({ dhTagAssocid: event.getSource().get('v.name')});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {   
				var pills = component.get('v.defaultOptions');

                for (var i = 0; i < pills.length; i++) {
                  if (event.getSource().get('v.name') === pills[i].value) {
                    pills.splice(i, 1);
                    break;
                  }
                }
            
                component.set('v.defaultOptions', pills);
            }
        });
        $A.enqueueAction(action); 
        
    },
    handleChange: function (component, event) {
        var selectedOptionsList = event.getParam("value");
        
        var action = component.get("c.setTags");
        
        action.setParams({ docHid: component.get("v.Document.Id"), tags: selectedOptionsList,newTag:''});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {   
                //component.set("v.selectedArray", selectedOptionsList);
            }
        });
        $A.enqueueAction(action); 
        
    }, 
    addNewTag:function(component,event,helper){ 
        var newTagVal = component.get("v.NewTagValue");
         if (newTagVal!=''){
             console.log(newTagVal);
                          
             var opt = [];
             opt = component.get("v.defaultOptions");
             var opt2=[];
             opt2= component.get("v.listOptions");
             var isDupl = false;
             
             for (var i =0; i< opt2.length;i++){
                 if (opt2[i].value==newTagVal){
                     isDupl = true;
                 }
             }
             
             if(!opt.includes(newTagVal)){
                 opt.push(newTagVal);
             } 
            
             if(!opt2.includes(newTagVal)){
                 opt2.push({ value: newTagVal, label: newTagVal} );
             }
             
             if (isDupl){
                 newTagVal='';
             }
             var action = component.get("c.setTags");
             action.setParams({ docHid: component.get("v.Document.Id"), tags: opt, newTag:newTagVal});
             action.setCallback(this, function(response) {
                 var state = response.getState();
                 if (component.isValid() && state == 'SUCCESS') {   
                     
                     component.set("v.defaultOptions",opt);
                     component.set("v.listOptions",opt2);
                     component.set("v.NewTagValue",'');
                 }
             });
             $A.enqueueAction(action); 
             
         }
    },
    
    closeModal:function(component,event,helper){ 
        
        var action = component.get("c.DeleteRec");
        action.setParams({ recId : component.get("v.Document.Id")});
        action.setCallback(this, function(response){
            component.set("v.Document.Id", '');
            //document.getElementById('vfFrame').src = document.getElementById('vfFrame').src;
        });
        $A.enqueueAction(action);
        
		var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    	},
	openmodal:function(component,event,helper) {
        component.set("v.ReviewItemFiles", null);
        var action = component.get("c.createNewRec");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Document.Id", response.getReturnValue());
                
                var cmpTarget = component.find('Modalbox');
                var cmpBack = component.find('Modalbackdrop');
                $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                $A.util.addClass(cmpBack, 'slds-backdrop--open');
            }
        });
        $A.enqueueAction(action);
	},
    closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   }
})