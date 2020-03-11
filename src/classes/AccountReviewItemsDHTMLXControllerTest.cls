@IsTest
public class AccountReviewItemsDHTMLXControllerTest {
    @IsTest
    private static void test1() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Assessment__c assess = new Assessment__c(Account__c = acc.id);
        insert assess;

        
        review_item__c ri = new review_item__c(
                Assessment__c = assess.Id, 
                Review_Item_Name__c = 'Bronze 1',
                Item_Category__c = 'Bronze',
                Item_Category_Description__c = 'Bronze items');
            
        insert ri;

        AccountReviewItemsDHTMLXController.getReviewItems(assess.id);
        AccountReviewItemsDHTMLXController.GetAccountsRelatedLists(assess.id);
        AccountReviewItemsDHTMLXController.GetRIFiltered(assess.id, 'Bronze');
        AccountReviewItemsDHTMLXController.setRIData(ri.id,'test','test');
        AccountReviewItemsDHTMLXController.getRIData(ri.id);
        AccountReviewItemsDHTMLXController.getWrapper(ri.id);
        AccountReviewItemsDHTMLXController.saveRecord(JSON.serialize(ri));
        AccountReviewItemsDHTMLXController.isReviewItemCreateable();

    }

}