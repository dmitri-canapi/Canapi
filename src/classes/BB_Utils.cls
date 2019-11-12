public with sharing class BB_Utils {
	private static Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    private static Map<String, String> prefixToObjectType = new Map<String, String>();
    private static Map<String, String> prefixToObjectLabel = new Map<String, String>();
    
    static {
        for(String sObj : globalDescribe.keySet()) {
            Schema.DescribeSObjectResult describeSObjectResult =  globalDescribe.get(sObj).getDescribe();
            prefixToObjectType.put(describeSObjectResult.getKeyPrefix(), describeSObjectResult.getName());
            prefixToObjectLabel.put(describeSObjectResult.getKeyPrefix(), describeSObjectResult.getLabel());
        }
    }
    

    public static String getObjectLabelFromId(String id) {
        return prefixToObjectLabel.get(id.subString(0,3));
    }
    
}