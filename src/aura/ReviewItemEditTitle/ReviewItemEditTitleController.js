({
    doInit : function(cmp, evt, hlp) {
        cmp.set('v.value',  cmp.get('v.documentToEdit').Notes);
    },
	 hideRowDetails : function(cmp, evt, hlp) {
       cmp.set('v.documentToEdit', cmp.get('v.documentToEdit').Notes= cmp.get('v.value'));
       cmp.find("overlayLib").notifyClose();
       
    },
})