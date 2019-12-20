public class TriggerDispatcher {
    
    /*
        Call this method from your trigger, passing in an instance of a trigger handler which implements ITriggerHandler.
        This method will fire the appropriate methods on the handler depending on the trigger context.
    */
    public static void Run(ITriggerHandler handler) {
            
        // Check to see if the trigger has been disabled. If it has, return
        if (handler.isDisabled())
            return;
             
        // Detect the current trigger context and fire the relevant methods on the trigger handler:
 
        // Before trigger logic
        if (Trigger.isBefore ) {
            handler.bulkBefore();
            
            if (Trigger.IsInsert)
                handler.beforeInsert(Trigger.new);
 
            if (Trigger.IsUpdate)
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
 
            if (Trigger.IsDelete)
                handler.beforeDelete(Trigger.oldMap);
        }
         
        // After trigger logic
        if (Trigger.IsAfter) {
            handler.bulkAfter();
            
            if (Trigger.IsInsert)
                handler.afterInsert(Trigger.newMap);
 
            if (Trigger.IsUpdate)
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
 
            if (Trigger.IsDelete)
                handler.afterDelete(Trigger.oldMap);
 
            if (Trigger.IsUndelete)
                handler.afterUndelete(Trigger.newMap);
        }
        
        handler.andFinally();
    }
}