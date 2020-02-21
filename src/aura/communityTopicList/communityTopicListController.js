({
    // Handle component initialization
    doInit: function (component, event, helper) {
        var action = component.get("c.getTopicsList");

        action.setCallback(this, function (response) {
            var Topicsjs = [];

            var Topicsjs = response.getReturnValue();
            var maxPosts = 1;
            var minPosts;
            var baseFont = 12;
            var maxFont = 40;
            for (let a of Topicsjs) {
                if (maxPosts < a.TopicAssignments.length) {
                    maxPosts = a.TopicAssignments.length
                }
                if (minPosts > a.TopicAssignments.length || !minPosts) {
                    minPosts = a.TopicAssignments.length
                }
            }

            for (let a of Topicsjs) {

                a.fsize = (maxFont + baseFont) - ((((maxPosts - a.TopicAssignments.length) / (maxPosts - minPosts)) * (maxFont - baseFont)) + baseFont);
            }
            component.set("v.Topics", Topicsjs);

        });
        $A.enqueueAction(action);
    },
    filter: function (component, event, helper) {
        var pass_data = { 'id': event.currentTarget.getAttribute("data-topicId"), 'name': event.currentTarget.getAttribute("data-topicName") };
        sessionStorage.setItem('setTopicFiltering', JSON.stringify(pass_data));
        sessionStorage.setItem('setTopicFilteringHeader', JSON.stringify(pass_data));
        component.set("v.currentTopic", event.currentTarget.getAttribute("data-topicId"));
    },
    showAllFeed: function (component, event, helper) {
        sessionStorage.setItem('setTopicFiltering', 'All Topics');
        sessionStorage.setItem('setTopicFilteringHeader', 'All Topics');
        component.set("v.currentTopic", 'All Topics');
    }
})