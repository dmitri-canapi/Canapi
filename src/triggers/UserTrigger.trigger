trigger UserTrigger on User (after insert) {

    if (AssessmentSharingService.RecalculateSharingOnCommunityUserCreation) {
        if (Trigger.isInsert) {
            // build a list of users for which assessment reviewer sharing should be recalculated
            List<Id> userIdsToRecalcSharing = new List<Id>();
            for (User u : Trigger.new) {
                if (u.AccountId != null) {
                    userIdsToRecalcSharing.add(u.Id);
                }
            }

            // recalculate sharing
            if (!userIdsToRecalcSharing.isEmpty() 
                    && !System.isBatch()
                    && !System.isFuture()
                    && !System.isQueueable()
                    && !System.isScheduled()) {

                AssessmentSharingService.recalculateSharingFuture(userIdsToRecalcSharing);
            }
        }
    }
}