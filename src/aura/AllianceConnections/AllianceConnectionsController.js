({
    init: function (cmp, event, helper) {
        helper.fetchData(cmp, event, helper);
    },
    performSearch: function (cmp, event, helper) {

        var timer = cmp.get('v.timer');
        clearTimeout(timer);

        var timer = setTimeout(function () {
            helper.fetchData(cmp, event, helper);
            clearTimeout(timer);
            cmp.set('v.timer', null);
        }, 400);
        cmp.set('v.timer', timer);
    },
    clearFilter: function (component, event, helper) {
        component.set('v.filter', '');
        var a = component.get('c.performSearch');
        $A.enqueueAction(a);
    },
})