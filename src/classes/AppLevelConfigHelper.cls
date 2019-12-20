public without sharing class AppLevelConfigHelper {

    public static String getConfig(String name) {
        return getConfig(name, null);
    }

    public static String getConfig(String name, String valueIfNull) {
        AppLevelConfig__c config = AppLevelConfig__c.getInstance(name);
        if (config != null) {
            return config.Value__c;
        } else {
            return valueIfNull;
        }
    }

    public static void setConfig(String name, String value) {
        AppLevelConfig__c config = AppLevelConfig__c.getInstance(name);
        if (config != null) {
            config.Value__c = value;
            update config;
        } else {
            insert new AppLevelConfig__c(Name = name, Value__c = value);
        }
    }
}