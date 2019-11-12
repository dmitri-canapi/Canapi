({
    doInit : function(cmp) {
        var tagSerchCondition = cmp.get("v.tagSerchCondition");
        var action = cmp.get("c.getTags");
        action.setParams({ tagSerchCondition : tagSerchCondition});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                
                console.log(resp);
                var tagsLoad = [];
                for(let tag of resp){
                    tag.isOpen=false;
                    tagsLoad.push(tag.Id);
                }
                
                cmp.set('v.tagsLoad',tagsLoad);
                cmp.set('v.tags',resp);
                cmp.set('v.LoadData', true);
            }else if (state === "ERROR") {
                console.log('ERROR');
                var errors = response.getError();
                console.log(errors);
                console.log(errors[0]);
                //  cmp.set('v.LoadData', true);
                this.showErrorToast(component, errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    refreshDocuments: function(cmp) {
    	var selectedTag = cmp.get('v.selectedTags');
        var serchCondition  =  cmp.get('v.documentSerchCondition');
        var selectedRow =  cmp.get('v.selectedDocumentRows');
        if(selectedTag.length>0){
            var action = cmp.get("c.getDocumentsByTags");
        action.setParams({ 
            tags : selectedTag,
            serchCondition :serchCondition ,
			recordId: cmp.get('v.recordId')            
                         });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                
           		var listToDel =[];
                for(let doc of resp){
                    doc.ClassName= '';
                    var exist = false;
                    for(var selected of selectedRow){
                        if(selected.Id==doc.Id){
                            exist = true;
                            listToDel.push(doc);
                        }
                 	}
                    
                    if(!exist){
                        if(doc.TagDocumentAssociations__r&&doc.TagDocumentAssociations__r!=null&&doc.TagDocumentAssociations__r.length>0){
                            var tags = "";
                            for(let tag of doc.TagDocumentAssociations__r) {
                                
                                tags += tag.Tag__r.Name+'; ';
                            }
                            doc.Tags = tags;
                        }
                       
                        if(doc.Junctions_Document_ReviewItem__r&&doc.Junctions_Document_ReviewItem__r!=null&&doc.Junctions_Document_ReviewItem__r.length>0){
                            var notes = "";
                            for(let note of doc.Junctions_Document_ReviewItem__r) {
                                if(note.Notes__c!=undefined){
                                	notes += note.Notes__c;
                                    doc.ClassName= 'greenCell';
                                }
                            }
                            doc.Notes = notes;
                        }
                    }
                    
                }
                for(let del of listToDel){
                    resp.splice( resp.indexOf(del), 1 );
                }
				console.log(selectedRow.concat(resp));
                cmp.set('v.documents',selectedRow.concat(resp));
               // cmp.set('v.LoadData', true);
            }else if (state === "ERROR") {
                console.log('ERROR');
                var errors = response.getError();
                console.log(errors);
                console.log(errors[0]);
                //  cmp.set('v.LoadData', true);
                this.showErrorToast(component, errors[0].message);
            }
        });
        $A.enqueueAction(action);
        }else{
            cmp.set('v.documents',selectedRow);
        }
	},
    addTag: function(cmp,value) {
        console.log("IN ADD TAG "+value);
        var selectedTag = cmp.get('v.selectedTags');
        if(!selectedTag.includes(value)){
            selectedTag.push(value);
            cmp.set('v.selectedTags', selectedTag);
        }
    },
    removeTag : function(cmp,value) {
        console.log("IN REMOVE TAG "+value);
        var selectedTag = cmp.get('v.selectedTags');
        var tags = cmp.get('v.tags');
        for(let tag of tags){
            if(tag.isOpen&&tag.Name==value){
                value="";
            }
        }
        if(selectedTag.includes(value)){
            selectedTag.splice( selectedTag.indexOf(value), 1 );
            cmp.set('v.selectedTags', selectedTag);
        }
    },
    linkDocumentTReview : function(cmp) {
            var selectedRow =  cmp.get('v.selectedDocumentRows');
        
        var jsonObj = [];
        for(let selected of selectedRow){
            jsonObj.push({DocumentId: selected.Id, Notes:selected.Notes});
        }
        console.log(jsonObj);
            var action = cmp.get("c.LinkDocumentToReview");
        action.setParams({ recordId: cmp.get('v.recordId'),
                          jsonObj:JSON.stringify( jsonObj)
                         });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                
                console.log(resp);
                cmp.find("overlayLib").notifyClose();
               // cmp.set('v.tags',resp);
               // cmp.set('v.LoadData', true);
            }else if (state === "ERROR") {
                console.log('ERROR');
                var errors = response.getError();
                console.log(errors);
                console.log(errors[0]);
                //  cmp.set('v.LoadData', true);
                this.showErrorToast(component, errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    createPopapToEditTitle :function(cmp){
         var modalBody;
        $A.createComponent("c:ReviewItemEditTitle", {documentToEdit : cmp.getReference('v.documentToEdit')},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   cmp.find('overlayLib').showCustomModal({
                       header: "Link Documents",
                       body: modalBody, 
                       showCloseButton: true,
                       cssClass: "mymodal",
                       closeCallback: function() {
                          cmp.set('v.documents', cmp.get('v.documents'));
                            var selectedRow =  cmp.get('v.selectedDocumentRows');
                            var selectedList = [];
                            for(let selected of selectedRow){
                                selectedList.push(selected.Id);
                            }
                            cmp = cmp.find("documentTable");
                            cmp.set("v.selectedRows", selectedList);
                       }
                   })
               }  
           });
    }
    
    
    
})