({
    doInit: function (component, event, helper) {
        window.setInterval(function () {
            var value = sessionStorage.getItem('setTopicFiltering');
            sessionStorage.removeItem('setTopicFiltering');
            if (value != null) {
                helper.filterFeed(component, value);
                helper.filterFeed(component, value);
            }
        }, 200);
    }
})