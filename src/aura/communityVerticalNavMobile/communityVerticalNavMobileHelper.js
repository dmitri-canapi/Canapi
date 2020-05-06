({
    createObj: function (label, pic, link, child) {
        var CommunityName;
        if (window.location.href.includes('https://canapi.force.com/alliance')) {
            CommunityName = 'alliance';
        } else {
           CommunityName = 'fintech';
        }
        var PageURL = decodeURIComponent(window.location);
        var obj = new Object();
        obj.label = label;
        obj.pic = pic;
        /*if (link == null) {
            obj.link = null;
        } else {
            obj.link = link == 'https://canapi.force.com/alliance/s/' ? link : 'https://canapi.force.com/alliance/s/' + link;
        }
        obj.active = ((PageURL.endsWith(link) && link != 'https://canapi.force.com/alliance/s/') || (link == 'https://canapi.force.com/alliance/s/' && PageURL.endsWith('/s/'))) ? true : false;*/
        obj.link = link == 'https://canapi.force.com/' + CommunityName + '/s/' ? link : 'https://canapi.force.com/' +CommunityName + '/s/' + link;
        obj.active = ((PageURL.endsWith(link) && link != 'https://canapi.force.com/' + CommunityName + '/s/') || (link == 'https://canapi.force.com/' + CommunityName + '/s/' && PageURL.endsWith('/s/'))) ? true : false;
        
        if (child) {
            obj.menus = child;
        }
        return obj;
    }
})