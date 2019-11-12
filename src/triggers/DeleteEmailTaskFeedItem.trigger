trigger DeleteEmailTaskFeedItem on FeedItem (after Insert) {
    /*List <Id> taskIds = new List <Id>();
    for(feedItem f:trigger.new){
        if (String.ValueOf(f.ParentId).startsWith('00T')) {
            taskIds.add(f.ParentId);
        }
    }
    
    List <Task> emailTasks = new List <Task>();
    if (taskIds.size()>0){
        Set<String> emailTasks = new  Set <String>();
        for (Task t: [select id, subject from Task where subject like '%Email:%' and id in:taskIds]){
            emailTasks.add(t.Id);
        }
        
        List <String> FIidsToDel = new List <String>();
        for(feedItem f:trigger.new){
            if(emailTasks.contains( f.ParentId )) {
                FIidsToDel.add(f.Id);
            }
        }
        
        if(FIidsToDel.size()>0){
            delete [select id from feedItem  where id in: FIidsToDel];
        }
        
    }*/
}