({
	formatPhone : function(component, event, helper) {
        console.log(component.find("phoneNumber").get("v.value"));
		//component.set("v.phone",helper.formatPhoneNumber(component.get("v.phone")));
		var fn = helper.formatPhoneNumber(component,component.find("phoneNumber").get("v.value"));
        console.log(fn);
        component.find("phoneNumber").set("v.value", fn);
	}
})