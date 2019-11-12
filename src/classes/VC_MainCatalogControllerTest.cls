@IsTest public class VC_MainCatalogControllerTest {
	@IsTest
    private static void testgetCapTableData() {
        account a = new account(name='test');
        insert a;
    	
        VC_Template__mdt VCTemplate = new VC_Template__mdt ();
        VCTemplate.Name__c = 'test';
        VCTemplate.Type__c = 'test';
        
        VC_MainCatalogController.getCatalogMap(a.Id);
        
        Vendor_Catalog__c vc = new Vendor_Catalog__c(Name__c ='test', Type__c = 'test', Account__c = a.id);
        insert vc;
        
        VC_MainCatalogController.updateVendor(vc.Id,a.Id);
        
        VC_MainCatalogController.getInitialSettings(a.Id);
        VC_MainCatalogController.getInitialSettings(null);
    }
        
}