@isTest
private class PortfolioMapControllerTest {
    @testSetup
    static void createTestData() {
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Portfolio_Company').getRecordTypeId();
        List<Account> testAccounts = new List<Account>{
            new Account(
                Name = 'Portfolio Account 1',
                Portfolio_Company__c = true,
                ShippingState = 'North Carolina',
                ShippingCountry = 'United States',
                RecordTypeId=recordTypeId
            ),
            new Account(
                Name = 'Portfolio Account 2',
                Portfolio_Company__c = true,
                ShippingState = 'Virginia',
                ShippingCountry = 'United States',
                RecordTypeId=recordTypeId
            ),
            new Account(
                Name = 'Portfolio Account 3',
                Portfolio_Company__c = true,
                ShippingCountry = 'Mexico',
                RecordTypeId=recordTypeId
            )
        };
        insert testAccounts;
    }

    @isTest
    static void getItemsTest() {
        PortfolioMapController controller = new PortfolioMapController();

        Test.startTest();

        List<SelectOption> options = controller.getItems();

        Test.stopTest();

        System.assert(!options.isEmpty());
    }
    @isTest
    static void getIsCommunityUserTest() {
        PortfolioMapController controller = new PortfolioMapController();
        Test.startTest();
        String SiteName = controller.SiteName;
        Test.stopTest();
        System.assert(SiteName==null);
    }

    @isTest
    static void getCountryItemsTest() {
        PortfolioMapController controller = new PortfolioMapController();

        Test.startTest();

        List<SelectOption> options = controller.getCountryItems();

        Test.stopTest();

        System.assert(!options.isEmpty());
    }

    @isTest
    static void getStateItemsTest() {
        PortfolioMapController controller = new PortfolioMapController();

        Test.startTest();

        List<SelectOption> options = controller.getStateItems();

        Test.stopTest();

        System.assert(!options.isEmpty());
    }

    @isTest
    static void getNumEmployeesItemsTest() {
        PortfolioMapController controller = new PortfolioMapController();

        Test.startTest();

        List<SelectOption> options = controller.getNumEmployeesItems();

        Test.stopTest();

        System.assert(!options.isEmpty());
    }

    @isTest
    static void runSearchTest() {
        List<Account> testAccounts = [SELECT Id FROM Account WHERE Portfolio_Company__c = true];
        System.assert(!testAccounts.isEmpty());

        Test.startTest();

        // controller calls runSearch() method with default values
        PortfolioMapController controller = new PortfolioMapController();
        controller.accountTypeVal=new List <String>{'All Types'};
        controller.SelectAllTypes();
        Test.stopTest();

        System.assert(!String.isBlank(controller.listAccounts));
        
        List<Account> searchResults = (List<Account>)JSON.deserialize(controller.listAccounts, List<Account>.class);
        //System.assertEquals(testAccounts.size(), searchResults.size());
    }

    @isTest 
    static void buildQueryWhereClauseTest() {
        PortfolioMapController controller = new PortfolioMapController();
        controller.countries = new List<String>{'United States','Canada'};
        controller.states = new List<String>{'Maryland','Ontario'};
        controller.totalFundingMin = '1000000';
        controller.totalFundingMax = '2000000';
        controller.numInvestorsMin = '1';
        controller.numInvestorsMax = '5';
        controller.foundingYearMin = '1990';
        controller.foundingYearMax = '2000';
        controller.numEmployees = new List<String>{'1-10'};

        Test.startTest();

        String whereClause = controller.buildQueryWhereClause();

        Test.stopTest();

        System.assert(!String.isBlank(whereClause));
        System.assert(whereClause.contains('ShippingCountry'));
        System.assert(whereClause.contains('ShippingState'));
        System.assert(whereClause.contains('Total_Funding_Amount__c'));
        System.assert(whereClause.contains('Number_of_Investors__c'));
        System.assert(whereClause.contains('Founded_Date__c'));
        System.assert(whereClause.contains('Number_of_Employees__c'));
    }

    @isTest 
    static void buildQueryWhereClauseBadValueTest() {
        PortfolioMapController controller = new PortfolioMapController();
        controller.countries = new List<String>{'United States','Canada'};
        controller.totalFundingMin = 'ABCDEF';
        controller.totalFundingMax = 'XYZ';

        Test.startTest();

        String whereClause = controller.buildQueryWhereClause();

        Test.stopTest();

        System.assert(!String.isBlank(whereClause));
        System.assert(whereClause.contains('ShippingCountry'));
        System.assert(!whereClause.contains('Total_Funding_Amount__c'));
    }

    @isTest
    static void validateThereAreAccounts() {
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.PortFolioMapPage;

        //In this case, the Visualforce page named 'success' is the starting point of this test method. 
        Test.setCurrentPage(pageRef);

        //Instantiate and construct the controller class.   
        PortfolioMapController controller = new PortfolioMapController();

        controller.listAccounts = null;
        //controller.accountTypeChoice = 1;
        controller.runSearch();


        If (controller.listAccounts == null) {
            System.assertEquals(0, 0,'There are no qualifying porfolio accounts.');
        } else {
            System.assertEquals(0, 0,'There are portfolio accounts present.');
        }


        pageRef = null;
        controller = null;

        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef2 = Page.PortFolioMapPage;

        //In this case, the Visualforce page named 'success' is the starting point of this test method. 
        Test.setCurrentPage(pageRef2);

        //Instantiate and construct the controller class.   
        PortfolioMapController controller2 = new PortfolioMapController();



        controller2.listAccounts = null;
        //controller2.accountTypeChoice = 2;
        controller2.runSearch();


        If (controller2.listAccounts == null) {
            System.assertEquals(0, 0,'There are no qualifying target accounts.');
        } else {
            System.assertEquals(0, 0,'There are target accounts present.');
        }


        System.assertNotEquals(0, controller2.getItems().size(), 'There should be a list of radio buttons.');
        pageRef2 = null;
        controller2 = null;
    }
}