({
	 init: function (cmp, event, helper) {
		var userId = $A.get("$SObjectType.CurrentUser.Id");
		cmp.set('v.uId',userId);
	}
})