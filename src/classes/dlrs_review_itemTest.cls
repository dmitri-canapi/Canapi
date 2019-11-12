/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_review_itemTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_review_itemTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new review_item__c());
    }
}