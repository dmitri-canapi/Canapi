trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    //This trigger will share all Chatter files with Community Users
    for(ContentDocumentLink l:Trigger.new) {
        system.debug('CONT DOC TRIGGER ----------------');
        l.Visibility='AllUsers';
    }
}