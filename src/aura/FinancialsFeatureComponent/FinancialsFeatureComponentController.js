({
	doInit : function(cmp, event, hlp) {
        window.addEventListener("message", function(event) {
            if(event&&event.data&&event.data.param&&event.data.param=='new_board_meeting'){
            hlp.handlerEvent(cmp, event.data);
            }else{
                return;
            }
        }, false);
        
		cmp.set('v.url', 'https://canapi--dk--c.cs79.visual.force.com/apex/FinancialsFeatureDHTMLXPage?recordId=001V000000YWPvtIAH&isCommunity=false&skin=material&communityName=&componentHeight=400&isAllowEditing=true&returnUrl='+window.location.hostname);
	}
})