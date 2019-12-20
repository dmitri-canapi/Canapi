@isTest
private class AppLevelConfigHelperTest {
	
	@isTest static void testGetConfig() {
		insert new AppLevelConfig__c(Name = 'config name', Value__c = 'config value');

        Test.startTest();
        String val = AppLevelConfigHelper.getConfig('config name');
        Test.stopTest();

        System.assertEquals('config value', val, 'incorrect config value');
	}
	
	@isTest static void testGetConfigNull() {

        Test.startTest();
        String val = AppLevelConfigHelper.getConfig('config name');
        Test.stopTest();

        System.assertEquals(null, val, 'incorrect config value - expected null');
	}
	
    @isTest static void testGetConfigNullWithDefault() {

        Test.startTest();
        String val = AppLevelConfigHelper.getConfig('config name', 'default value');
        Test.stopTest();

        System.assertEquals('default value', val, 'incorrect config value');
    }

    @isTest static void testSetConfig() {

        Test.startTest();
        AppLevelConfigHelper.setConfig('config name', 'config value');
        Test.stopTest();

        AppLevelConfig__c config = AppLevelConfig__c.getInstance('config name');
        System.assertEquals('config value', config.Value__c, 'incorrect config value');
    }
}