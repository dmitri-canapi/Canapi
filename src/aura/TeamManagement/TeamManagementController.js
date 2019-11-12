({
    init: function (cmp, event, helper) {
        
        var actions = [
            { label: 'Edit', name: 'Edit' }
        ];

        cmp.set('v.columns', [
            /*{label: 'Id', fieldName: 'Id', type: 'text' },*/
            {label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name'}, target: '_self'}},
            {label: 'Title', fieldName: 'Title', type: 'text'},
            {label: 'Phone', fieldName: 'Phone', type: 'phone' },
            {label: 'Email', fieldName: 'Email', type: 'email'  }  ,
            { type: 'action', typeAttributes: { rowActions: actions } }
            
        ]);
        helper.fetchData(cmp,event, helper);
    },
    handleRowAction: function (cmp, event, helper) {
         console.log('row');
        var row = {};
        try { 
            row.Id = event.target.getAttribute("data-rowId");
            
        } catch (e){
            row = event.getParam('row');

        }
        console.log('row'+row.Id);
        var modalBody;
        $A.createComponent("c:TeamManagementUserEdit", { recordId : row.Id },
                           function(content, status) {
                               console.log(status);
                               if (status === "SUCCESS") {
                                   cmp.find('overlayLib').showCustomModal({
                                       header: "User  Edit",
                                       body: content, 
                                       showCloseButton: true,
                                       cssClass: "mymodal",
                                       
                                   })
                               }                               
                           });
        
        
    },
    
    closeModal:function(component,event,helper){    
		var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    	},
	openmodal:function(component,event,helper) {
		var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.addClass(cmpBack, 'slds-backdrop--open'); 
	},
    createUser:function(component,event,helper) {
    	helper.createUser(component,event, helper);
    }
})