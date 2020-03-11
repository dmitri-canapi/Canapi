({
    createObj: function (component, label, pic, link, child, id) {
        var PageURL = decodeURIComponent(window.location);
        var obj = new Object();
        obj.label = label;
        obj.pic = pic;
        obj.link = link == 'https://canapi.force.com/' + component.get("v.CommunityName") + '/s/' ? link : 'https://canapi.force.com/' + component.get("v.CommunityName") + '/s/' + link;
        obj.active = ((PageURL.endsWith(link) && link != 'https://canapi.force.com/' + component.get("v.CommunityName") + '/s/') || (link == 'https://canapi.force.com/' + component.get("v.CommunityName") + '/s/' && PageURL.endsWith('/s/'))) ? true : false;
        if (child) {
            obj.menus = child;
        }
        if (id != null) {
            obj.Id = id;
        }
        return obj;
    }
})