@IsTest 
private with sharing class FinancialsChartTest {
    @IsTest
    private static void test1() {
    Account acc = new Account(Name = 'Test Account');
    insert acc; 
    FinancialsChart.getFins(acc.Id);
    }
}