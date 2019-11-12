({
    doInit : function(cmp, evt, hlp) {
        cmp.set('v.documentColums', [
            {label: 'Title', fieldName: 'Name__c', type: 'text', cellAttributes:{  class:{   fieldName:"ClassName"} } },
            {label: 'Tags', fieldName: 'Tags', type: 'text', cellAttributes:{   class:{  fieldName:"ClassName"}}},
             {label: 'Notes', fieldName: 'Notes', type: 'text', title:"@@@",  cellAttributes:{   class:{  fieldName:"ClassName" }}, typeAttributes: { label: 'Edit Note', name: 'edit_note', title: { fieldName: 'Notes' }}},
            {label: 'NoteButton', type: 'button', initialWidth: 135, cellAttributes:{   class:{  fieldName:"ClassName"}}, typeAttributes: { label: 'Edit Note', name: 'edit_note', title: { fieldName: 'Notes' }}} ]);
            cmp.set('v.activeSections',  []);
        hlp.doInit(cmp);
    },
        doInit1 : function(cmp, evt, hlp) {
       console.log(cmp.get('v.tags'));
    },
    
    handleSectionToggle: function (cmp, event,hlp) {
        var openSections = event.getParam('openSections');
        var tags = cmp.get('v.tags');
        for(let tag of tags){
            var closed = true;
           for(let selected of openSections){
               if(tag.Id==selected){
                   tag.isOpen= true;
                   closed = false;
                    hlp.addTag(cmp, tag.Name);
               }
        	}
            if(closed&&tag.isOpen){
                tag.isOpen= false;
                hlp.removeTag(cmp, tag.Name);
            }
        }
        cmp.set('v.tags', tags);
        cmp.set('v.activeSections',  openSections);
    },
    
    addTag : function(cmp, evt, hlp) {
        var value = evt.getSource().get("v.value");
        
        var menuValue = evt.detail.menuItem.get("v.value");
        switch(menuValue) {
            case "Add": hlp.addTag(cmp, value); break;
            case "Remove": hlp.removeTag(cmp, value); break;
        }
    },
    SetFromChild : function(cmp, evt, hlp) {
        var value = evt.getParam("tag"); 
        var menuValue = evt.getParam("action"); 
        switch(menuValue) {
            case "Add": hlp.addTag(cmp, value); break;
            case "Remove": hlp.removeTag(cmp, value); break;
        }
    },
    
    removeTag : function(cmp, evt, hlp) {
        var value =evt.getSource().get("v.name");
        hlp.removeTag(cmp, value);
    },
    
    refreshDocuments: function(cmp, evt, hlp) {
        hlp.refreshDocuments(cmp);
        
        
    },
    
    changeTitle : function(cmp, evt, hlp){
        var action = evt.getParam('action');
        var row = evt.getParam('row');
        cmp.set('v.documentToEdit',row);
        hlp.createPopapToEditTitle(cmp);
    },
    
    textAreaChange : function (cmp){ 
        cmp.set('v.documents', cmp.get('v.documents'));
        var selectedRow =  cmp.get('v.selectedDocumentRows');
        var selectedList = [];
        for(let selected of selectedRow){
            selectedList.push(selected.Id);
        }
        cmp = cmp.find("documentTable");
        cmp.set("v.selectedRows", selectedList);
    },
    
    setSelectedRow: function(cmp, evt, hlp) {
        var selectedRows = evt.getParam('selectedRows');
        cmp.set('v.selectedDocumentRows',selectedRows);
    },
    
    save: function(cmp, evt, hlp) {
        hlp.linkDocumentTReview(cmp);
    },
    
    hideRowDetails : function(cmp, evt, hlp) {
       cmp.find("overlayLib").notifyClose();
       
    },
    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');

        console.log(draftValues);
    },
    
    test :function(){
        var doc =document.getElementById('dataTable');
        
        console.log(doc.innerHTML);
       console.log(JSON.stringify(doc));
    }
    
})