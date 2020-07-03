global without sharing class VC_MainCatalogController {

    @AuraEnabled
    global static Map<String, List<Vendor_Catalog__c>> getCatalogMap (String recId){
        Map <String, List<Vendor_Catalog__c>> catalog = new Map <String, List<Vendor_Catalog__c>>();
        
        List <Vendor_Catalog__c> tempCatalog = [select Id, Name__c, Type__c, Priority_category__c, Priority_item__c  from Vendor_Catalog__c where (Account__c = : recId or User__c = : recId) order by Type__c asc, Name__c asc];
        List<VC_Template__mdt> VCTemplate = [select id,Name__c, Type__c, Priority__c from VC_Template__mdt];
        Map <String, Decimal> categoryPrior = new Map <String, Decimal>();
        for (Vendor_Catalog_Category__mdt vcCat : [select Name__c, Priority__c from Vendor_Catalog_Category__mdt]){
            categoryPrior.put(vcCat.Name__c, vcCat.Priority__c);
        }

        if (tempCatalog.size()==0){
            for (VC_Template__mdt vct: VCTemplate){
                
                Vendor_Catalog__c vc = new Vendor_Catalog__c(Name__c = vct.Name__c, Type__c = vct.Type__c, Vendor__c = null, Priority_item__c = vct.Priority__c, Priority_category__c = categoryPrior.get(vct.Type__c));
                
                if (id.valueOf(recId).getSObjectType().getDescribe().getName()=='Account'){
                    vc.Account__c = recId;
                } else {
                    vc.User__c = recId;
                }
                
                tempCatalog.add(vc);
                
            }
            insert tempCatalog;
        
        } else {
            Map <String, Decimal> templItemPriors = new Map <String, Decimal>();
            for (VC_Template__mdt t: VCTemplate){
                templItemPriors.put(t.Name__c + t.Type__c, t.Priority__c);
            }

            List <Vendor_Catalog__c> vcUpdlist = new List <Vendor_Catalog__c> ();
            for (Vendor_Catalog__c vc: tempCatalog){
                Vendor_Catalog__c vcUpd = new Vendor_Catalog__c();
                if (categoryPrior.containsKey(vc.Type__c) && categoryPrior.get(vc.Type__c) != vc.Priority_category__c){
                    vcUpd.Id=vc.Id;
                    vcUpd.Priority_category__c = categoryPrior.get(vc.Type__c);
                }
                if (templItemPriors.containsKey(vc.Name__c + vc.Type__c) && templItemPriors.get(vc.Name__c + vc.Type__c) != vc.Priority_item__c){
                    vcUpd.Id=vc.Id;
                    vcUpd.Priority_item__c = templItemPriors.get(vc.Name__c + vc.Type__c);
                }

                if(vcUpd.Id != null)
                vcUpdlist.add(vcUpd);
            }
            update vcUpdlist;


        }
        
        tempCatalog = [select Id, Name__c, Type__c, Vendor__c, Vendor__r.Name  from Vendor_Catalog__c where (Account__c = : recId or User__c = : recId) order by Priority_category__c desc, Type__c asc, Priority_item__c desc, Name__c asc];
        
        for (Vendor_Catalog__c vc: tempCatalog){
            if (!catalog.containsKey(vc.Type__c)){
                catalog.put(vc.Type__c, new List <Vendor_Catalog__c> {vc});
            } else {
                List <Vendor_Catalog__c> vcList = catalog.get(vc.Type__c);
                vcList.add(vc);
                catalog.put(vc.Type__c,vcList);
            }
        }
        return catalog;
    }
    
    
    @AuraEnabled
    global static void updateVendor(String VCid, String VendorId){
        Vendor_Catalog__c vc = new Vendor_Catalog__c(id = VCid, Vendor__c = VendorId);
        update vc;
    }
    @AuraEnabled
    public static InitialSettings getInitialSettings(String recId) {
        boolean isCommunityUser;
        boolean isBank;
        if (recId == null) {
            isCommunityUser = true;
            recId = [select id,Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
            if (recId == null){
                recId = UserInfo.getUserId();
                isBank = false;
            } else {
                isBank = [select recordType.Name from account where id = : recId].recordType.Name == 'Bank';
            }
            
        } else {
            isCommunityUser = false;
            isBank = [select recordType.Name from account where id = : recId].recordType.Name == 'Bank';
        }
        
        return new InitialSettings(isBank, isCommunityUser, recId);
    }
     public class InitialSettings {
        @AuraEnabled public Boolean isBank { get; set;}
        @AuraEnabled public Boolean isCommunityUser { get; set;}
        @AuraEnabled public String accountId { get; set;}
        public InitialSettings (Boolean isBank, Boolean isCommunityUser, String accountId){
            this.isBank = isBank;
            this.isCommunityUser = isCommunityUser;
            this.accountId = accountId;
        }
    }
    
}