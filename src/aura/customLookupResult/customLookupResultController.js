({
    selectRecord: function (component, event, helper) {
        //if (component.get("v.objectAPIField") != 'Title') {
        // get the selected record from list  
        var getSelectRecord = component.get("v.oRecord");
        // call the event   
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.  
        compEvent.setParams({ "objectTitle": component.get("v.objectAPIField") });
        compEvent.setParams({ "recordByEvent": getSelectRecord });
        if (component.get("v.objectAPIField") == 'Title') {
            compEvent.setParams({ "recordLabel": component.get("v.oRecord").Label });
        } else {
            compEvent.setParams({ "recordLabel": component.get("v.oRecord")[component.get("v.objectAPIField")] });
        }

        console.log(component.get("v.oRecord")[component.get("v.objectAPIField")]);
        // fire the event  
        compEvent.fire();
        console.log(component.get("v.objectAPIField"));
        console.log(getSelectRecord.Id);

        //}
    },
})