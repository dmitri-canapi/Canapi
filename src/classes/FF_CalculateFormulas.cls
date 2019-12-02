public class FF_CalculateFormulas {
    public static boolean firstRun = true;
    
    public static void recalculate(String AccId){
        List <Chart_of_Accounts__c> allCharts = [select id, Name, Account__c, Category__c, Formula__c from Chart_of_Accounts__c where Account__c =: AccId];
        List <Report_Period__c> allPeriods = [select id from Report_Period__c where Account__c =: AccId];
        List <Financials__c> financialsForUpdate = new List <Financials__c>();
        
        Map <String, Financials__c> financialsMap = new Map <String, Financials__c>();
        Map <String, Decimal> financialsValuesMap = new Map <String, Decimal>();
        for (Financials__c fin: [select Id, Report_Period__c, Chart_of_Accounts__c,Chart_of_Accounts__r.name, Value__c  from Financials__c where Chart_of_Accounts_AccId__c  =: AccId.substring(0, 15)]){
            financialsMap.put('' + fin.Chart_of_Accounts__c + fin.Report_Period__c, fin);
            financialsValuesMap.put('' + fin.Chart_of_Accounts__r.name + fin.Report_Period__c, fin.Value__c);
        }
        
        for (Chart_of_Accounts__c chart: allCharts){
            if (chart.Category__c ==  'Metric' && chart.Formula__c != null){
                for (Report_Period__c period : allPeriods){
                    if (financialsMap.containsKey ('' + chart.Id + period.Id)){
                        Financials__c fin = financialsMap.get('' + chart.Id + period.Id);
                        String Condition = chart.Formula__c;
                        integer fieldsInResult = 0;
                        fieldsInResult  = Condition.countMatches('{');
                        for (integer j=0; j<fieldsInResult; j++){
                            String field='';
                            field = Condition.substring(Condition.indexOf('{')+1,Condition.indexOf('}'));
                            if (financialsValuesMap.containsKey ('' + field + period.Id)){
                                Condition = Condition.replaceFirst(field,String.ValueOf(financialsValuesMap.get ('' + field + period.Id)));
                            } else {
                                Condition = Condition.replaceFirst(field,'0');
                            }
                            Condition=Condition.replaceFirst('\\{','');
                            Condition=Condition.replaceFirst('\\}','');
                        }
                        Decimal resultRT = 0;
                        try {
                        	resultRT = new RT_Expression(Condition).eval();
                        } catch (exception e){}

                        fin.Value__c = resultRT;
                        financialsForUpdate.add(fin);
                    } else {
                        Financials__c fin = new Financials__c();
                        fin.Report_Period__c = period.Id;
                        fin.Chart_of_Accounts__c = chart.Id;
                        
                        String Condition = chart.Formula__c;
                        integer fieldsInResult = 0;
                        fieldsInResult  = Condition.countMatches('{');
                        for (integer j=0; j<fieldsInResult; j++){
                            String field='';
                            field = Condition.substring(Condition.indexOf('{')+1,Condition.indexOf('}'));
                            if (financialsValuesMap.containsKey ('' + field + period.Id)){
                                Condition = Condition.replaceFirst(field,String.ValueOf(financialsValuesMap.get ('' + field + period.Id)));
                            } else {
                                Condition = Condition.replaceFirst(field,'0');
                            }
                            Condition=Condition.replaceFirst('\\{','');
                            Condition=Condition.replaceFirst('\\}','');
                        }
                        Decimal resultRT = 0;
                        try {
                        	resultRT = new RT_Expression(Condition).eval();
                        } catch (exception e){}

                        fin.Value__c = resultRT;
                        financialsForUpdate.add(fin);
                    }
                    
                }
            }
        }

        upsert financialsForUpdate;
        
    }
}