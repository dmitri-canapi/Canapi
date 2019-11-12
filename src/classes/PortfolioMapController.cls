public with sharing class PortfolioMapController {
    // public account list property
    public transient String listAccounts { get; set; }
    // public properties for filter field values
    /*public Integer accountTypeChoice { get; set; } {
        accountTypeChoice = 1;
    }*/
    public String SiteName { get { 
        if (Site.getSiteId()!=null){
        	Site currentCommunity = [SELECT Id,Name FROM Site WHERE id = :Site.getSiteId()];
            return currentCommunity.Name.TolowerCase();
        }
        return null;
    } set; }
    public List <String> accountTypeVal {get {
        if (accountTypeVal == null) {
            accountTypeVal = new List <String>() ;
        	accountTypeVal.add('Portfolio_Company');
        }
            return accountTypeVal;
        }
        set;
    }


    public List<String> countries { get; set; } {
        countries = new List<String>();
    }

    public List<String> states { get; set; } {
        states = new List<String>();
    }

    public String totalFundingMin { get; set; }
    public String totalFundingMax { get; set; }

    public String numInvestorsMin { get; set; }
    public String numInvestorsMax { get; set; }

    public String foundingYearMin { get; set; }
    public String foundingYearMax { get; set; }

    public List<String> numEmployees { get; set; } {
        numEmployees = new List<String>();
    }

    // constructor
    public PortfolioMapController() {
        runSearch();
    }

    // public select option getters for filter form fields
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('All Types','All Types'));
        List<Schema.RecordTypeInfo> recordtypes = Account.SObjectType.getDescribe().getRecordTypeInfos();
        Id siteId = Site.getSiteId(); 
        for(RecordTypeInfo rt : recordtypes){
                if (siteId == null) {
                    options.add(new SelectOption(rt.DeveloperName,rt.Name));
                } else {
                    if(rt.DeveloperName!='Master' && rt.DeveloperName!='Other' && rt.DeveloperName!='Limited_Partner' && rt.DeveloperName!='LP_Individuals' && rt.DeveloperName!='PersonAccount'){
                        options.add(new SelectOption(rt.DeveloperName,rt.Name));
                    }
                }
			
       }

        return options;
    }
    
    public void SelectAllTypes (){
        if (accountTypeVal[0]=='All Types' && accountTypeVal.size()==1){
            accountTypeVal.add('All Types');
            List<Schema.RecordTypeInfo> recordtypes = Account.SObjectType.getDescribe().getRecordTypeInfos();
            for(RecordTypeInfo rt : recordtypes){
                accountTypeVal.add(rt.DeveloperName);
           }
        }
    }

    public List<SelectOption> getCountryItems() {
        List<AggregateResult> groupedResults = [
            SELECT COUNT(Id), ShippingCountry
            FROM Account 
            GROUP BY ShippingCountry
            ORDER BY ShippingCountry
        ];
        List<SelectOption> options = new List<SelectOption>();

        for (AggregateResult groupedResult : groupedResults)  {
            String country = (String)groupedResult.get('ShippingCountry');
            if (!String.isBlank(country)) {
                options.add(new SelectOption(country,country));
            }
        }

        return options;
    }

    public List<SelectOption> getStateItems() {
        List<AggregateResult> groupedResults = [
            SELECT COUNT(Id), ShippingState
            FROM Account 
            GROUP BY ShippingState
            ORDER BY ShippingState
        ];
        List<SelectOption> options = new List<SelectOption>();

        for (AggregateResult groupedResult : groupedResults)  {
            String state = (String)groupedResult.get('ShippingState');
            if (!String.isBlank(state)) {
                options.add(new SelectOption(state,state));
            }
        }

        return options;
    }

    // public select option getters for filter form fields
    public List<SelectOption> getNumEmployeesItems() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Account.Number_of_Employees__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry pickListVal : ple){
            options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
        }

        return options;
    }

    // search action
    public void runSearch () {
        System.debug('Running the search.');
        List<Account> accs = new List<Account>();
        
        // dynamically build the query
        String query = 'SELECT Id, Name, ' +
                        'ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ' +
                        'Funding_Status__c, Total_Funding_Amount__c, Number_of_Investors__c, Founded_Date__c, ' +
                        'Number_of_Employees__c, ShippingLatitude, ShippingLongitude ' +
                        'FROM Account';

        String whereClause = buildQueryWhereClause();

        if (!String.isBlank(whereClause)) {
            query = query + ' WHERE ' + whereClause;
        }
        query = query + ' ORDER BY Name ASC LIMIT 50000';
        System.debug('Search query: ' + query);

        accs = Database.query(query);

        listAccounts = JSON.Serialize (accs);
        System.debug('All Accounts from inside run search: ' + listAccounts);
    }

    // build query where clause dynamically based on filter form values
    @TestVisible
    private String buildQueryWhereClause() {
        String whereClause = '';

        // Account Type
        /*if (accountTypeChoice == 1) {
            whereClause += 'Portfolio_Company__c = true';
        }
        else {
            whereClause += 'Portfolio_Company__c = false';
        }*/
        system.debug(accountTypeVal);
        whereClause += 'RecordType.DeveloperName IN: accountTypeVal';
        

        // Country (ShippingCountry)
        whereClause += buildStringPicklistWhereClauseFragment(countries, 'ShippingCountry');

        // State (ShippingState)
        whereClause += buildStringPicklistWhereClauseFragment(states, 'ShippingState');

        // Total Funding Amount (Total_Funding_Amount__c)
        whereClause += buildNumericRangeWhereClauseFragment(totalFundingMin, totalFundingMax, 'Total_Funding_Amount__c', true);

        // Number of Investors (Number_of_Investors__c)
        whereClause += buildNumericRangeWhereClauseFragment(numInvestorsMin, numInvestorsMax, 'Number_of_Investors__c', true);

        // Founding Year (CALENDAR_YEAR(Founded_Date__c))
        whereClause += buildNumericRangeWhereClauseFragment(foundingYearMin, foundingYearMax, 'CALENDAR_YEAR(Founded_Date__c)', false);

        // Number of Employees (Number_of_Employees__c)
        whereClause += buildStringPicklistWhereClauseFragment(numEmployees, 'Number_of_Employees__c');

        return whereClause;
    }

    // build query where clause fragment for string picklist filter
    private String buildStringPicklistWhereClauseFragment(List<String> fieldValues, String fieldAPIName) {
        String whereClauseFragment = '';

        if (!fieldValues.isEmpty()) {
            whereClauseFragment += ' AND ' + fieldAPIName + ' IN (';
            Boolean comma = false;
            for (String fieldValue : fieldValues) {
                if (comma) whereClauseFragment += ' ,';
                whereClauseFragment += '\'' + fieldValue + '\'';
                comma = true;
            }
            whereClauseFragment += ')';
        }

        return whereClauseFragment;
    }

    // build query where clause fragment for numerical range filter
    private String buildNumericRangeWhereClauseFragment(String fieldValueMin, String fieldValueMax, String fieldAPIName, Boolean treatNullsAsZeros) {
        String whereClauseFragment = '';

        if (!String.isBlank(fieldValueMin)) {
            try {
                Decimal minAmount = Decimal.valueOf(fieldValueMin);
                whereClauseFragment += ' AND (' + fieldAPIName + ' >= ' + minAmount.toPlainString();
                if (treatNullsAsZeros && minAmount <= 0) whereClauseFragment += ' OR ' + fieldAPIName + ' = null';
                whereClauseFragment += ')';
            }
            catch (Exception e) {
                fieldValueMin = '';
            }
        }
        if (!String.isBlank(fieldValueMax)) {
            try {
                Decimal maxAmount = Decimal.valueOf(fieldValueMax);
                whereClauseFragment += ' AND (' + fieldAPIName + ' <= ' + maxAmount.toPlainString();
                if (treatNullsAsZeros && maxAmount >= 0) whereClauseFragment += ' OR ' + fieldAPIName + ' = null';
                whereClauseFragment += ')';
            }
            catch (Exception e) {
                fieldValueMax = '';
            }
        }

        return whereClauseFragment;
    }
}