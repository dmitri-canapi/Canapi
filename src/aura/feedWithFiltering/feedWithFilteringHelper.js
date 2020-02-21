({
    filterFeed: function (component, data) {
        if (data !== 'All Topics') {
            $A.createComponent("forceChatter:feed", { "type": "Topics", "subjectId": JSON.parse(data).id }, function (feed) {
                var feedContainer = component.find("feedContainer");
                feedContainer.set("v.body", feed);
            });

        } else {
            $A.createComponent("forceChatter:feed", { "type": "News" }, function (feed) {
                var feedContainer = component.find("feedContainer");
                feedContainer.set("v.body", feed);
            });

        }
    }
})