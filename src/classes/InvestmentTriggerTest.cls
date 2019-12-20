@IsTest
private class InvestmentTriggerTest {

    @TestSetup
    static void setup() {
        AppLevelConfigHelper.setConfig('InvestmentTriggerHandler.Disabled', 'false');
        AppLevelConfigHelper.setConfig('AutoCalcSharesAndAmount.Disabled', 'false');
    }

    @IsTest
    static void testIsDisabled() {
        InvestmentTriggerHandler handler = new InvestmentTriggerHandler();
        System.assertEquals(false, handler.isDisabled());
        AppLevelConfigHelper.setConfig('InvestmentTriggerHandler.Disabled', 'true');
        System.assertEquals(true, handler.isDisabled());
    }

    @IsTest
    static void testGetWholeNumSharesFromAmount() {
        System.assertEquals(81, InvestmentTriggerHandler.GetWholeNumSharesFromAmount(100, 1.23));
        System.assertEquals(47438, InvestmentTriggerHandler.GetWholeNumSharesFromAmount(500000, 10.54));
        System.assertEquals(0, InvestmentTriggerHandler.GetWholeNumSharesFromAmount(1, 100));
    }

    @IsTest
    static void testIsAutoCalcSharesAndAmountDisabled() {
        System.assertEquals(false, InvestmentTriggerHandler.isAutoCalcSharesAndAmountDisabled());
        AppLevelConfigHelper.setConfig('AutoCalcSharesAndAmount.Disabled', 'true');
        System.assertEquals(true, InvestmentTriggerHandler.isAutoCalcSharesAndAmountDisabled());
    }

    @IsTest
    static void testInsertWhenTriggerDisabled() {

        // disable the auto calc functionality
        AppLevelConfigHelper.setConfig('InvestmentTriggerHandler.Disabled', 'true');

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 111.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Amount1__c = 1000;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;

        Test.startTest();
        insert testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(1000, testInvestment.Amount1__c);
        System.assertEquals(2000, testInvestment.Shares_Voting__c);
        System.assertEquals(3000, testInvestment.Shares_Non_Voting__c);
    }

	@IsTest
    static void testInsertAutoCalcSharesAndAmountDisabled() {

        // disable the auto calc functionality
		AppLevelConfigHelper.setConfig('AutoCalcSharesAndAmount.Disabled', 'true');

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 111.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Amount1__c = 1000;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;

        Test.startTest();
        insert testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(1000, testInvestment.Amount1__c);
        System.assertEquals(2000, testInvestment.Shares_Voting__c);
        System.assertEquals(3000, testInvestment.Shares_Non_Voting__c);
	}
	
    @IsTest
    static void testInsertPromoteSeries() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 111.23,
            Promote_Series__c = true
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Amount1__c = 1000;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;

        Test.startTest();
        insert testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(1000, testInvestment.Amount1__c);
        System.assertEquals(2000, testInvestment.Shares_Voting__c);
        System.assertEquals(3000, testInvestment.Shares_Non_Voting__c);
    }

    @IsTest
    static void testUpdateAutoCalcSharesAndAmountDisabled() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 111.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Amount1__c = 1000;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;
        insert testInvestment;
        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];

        // couple sanity checks - these should have all been recalculated
        System.assertNotEquals(1000, testInvestment.Amount1__c);
        System.assertNotEquals(2000, testInvestment.Shares_Voting__c);
        System.assertNotEquals(3000, testInvestment.Shares_Non_Voting__c);

        testInvestment.Amount1__c = 1000;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;

        // disable auto calc for our test
        AppLevelConfigHelper.setConfig('AutoCalcSharesAndAmount.Disabled', 'true');

        Test.startTest();
        update testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(1000, testInvestment.Amount1__c);
        System.assertEquals(2000, testInvestment.Shares_Voting__c);
        System.assertEquals(3000, testInvestment.Shares_Non_Voting__c);
    }

    @IsTest
    static void testUpdatePromoteSeries() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 111.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Amount1__c = 1000;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;
        insert testInvestment;
        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];

        // couple sanity checks - these should have all been recalculated
        System.assertNotEquals(1000, testInvestment.Amount1__c);
        System.assertNotEquals(2000, testInvestment.Shares_Voting__c);
        System.assertNotEquals(3000, testInvestment.Shares_Non_Voting__c);

        testInvestment.Amount1__c = 1000;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;

        // change the Series to a Promote series
        testRound.Promote_Series__c = true;
        update testRound;

        Test.startTest();
        update testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(1000, testInvestment.Amount1__c);
        System.assertEquals(2000, testInvestment.Shares_Voting__c);
        System.assertEquals(3000, testInvestment.Shares_Non_Voting__c);
    }

    @IsTest
    static void testInsertWithAmountAutoCalcSharesAndAmount() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 14.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Amount1__c = 1000;

        Integer expectedNumVotingShares = InvestmentTriggerHandler.getWholeNumSharesFromAmount(testInvestment.Amount1__c, testRound.Share_Price__c);
        Integer expectedNumNonVotingShares = 0;
        Decimal expectedAmount = (expectedNumVotingShares + expectedNumNonVotingShares) * testRound.Share_Price__c;

        Test.startTest();
        insert testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];

        System.assertEquals(expectedAmount, testInvestment.Amount1__c);
        System.assertEquals(expectedNumVotingShares, testInvestment.Shares_Voting__c);
        System.assertEquals(expectedNumNonVotingShares, testInvestment.Shares_Non_Voting__c);
    }

    @IsTest
    static void testInsertWithSharesAutoCalcSharesAndAmount() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 1.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 1000;

        Integer expectedNumVotingShares = (Integer) testInvestment.Shares_Voting__c;
        Integer expectedNumNonVotingShares = (Integer) testInvestment.Shares_Non_Voting__c;
        Decimal expectedAmount = (expectedNumVotingShares + expectedNumNonVotingShares) * testRound.Share_Price__c;

        Test.startTest();
        insert testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];

        System.assertEquals(expectedAmount, testInvestment.Amount1__c);
        System.assertEquals(expectedNumVotingShares, testInvestment.Shares_Voting__c);
        System.assertEquals(expectedNumNonVotingShares, testInvestment.Shares_Non_Voting__c);
    }

    @IsTest
    static void testInsertWithBothAutoCalcSharesAndAmount() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 12.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Amount1__c = 1000;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;

        Integer expectedNumVotingShares = InvestmentTriggerHandler.getWholeNumSharesFromAmount(testInvestment.Amount1__c, testRound.Share_Price__c);
        Integer expectedNumNonVotingShares = 0;
        Decimal expectedAmount = (expectedNumVotingShares + expectedNumNonVotingShares) * testRound.Share_Price__c;

        Test.startTest();
        insert testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(expectedAmount, testInvestment.Amount1__c);
        System.assertEquals(expectedNumVotingShares, testInvestment.Shares_Voting__c);
        System.assertEquals(expectedNumNonVotingShares, testInvestment.Shares_Non_Voting__c);
    }

    @IsTest
    static void testUpdateIncreaseAmountAutoCalcSharesAndAmount() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 1.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Shares_Voting__c = 1000;
        testInvestment.Shares_Non_Voting__c = 300;
        insert testInvestment; // Amount will be (voting + nonvoting) * share price

        // add 500 bucks to the investment - it should all go to voting shares
        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.debug('testInvestment.Amount1__c = ' + testInvestment.Amount1__c);
        testInvestment.Amount1__c += 500;
        System.debug('testInvestment.Amount1__c = ' + testInvestment.Amount1__c);

        Integer expectedNumTotalShares = InvestmentTriggerHandler.getWholeNumSharesFromAmount(testInvestment.Amount1__c, testRound.Share_Price__c);

        // the number of non-voting shares shouldn't change since we're adding money to the investment
        // and we should only be added voting shares
        Integer expectedNumNonVotingShares = (Integer) testInvestment.Shares_Non_Voting__c;

        // the number of voting shares we end up with should be the expected number of total
        // shares minus the number of non voting shares
        Integer expectedNumVotingShares = expectedNumTotalShares - expectedNumNonVotingShares;

        Decimal expectedAmount = expectedNumTotalShares * testRound.Share_Price__c;

        Test.startTest();
        update testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(expectedNumVotingShares, testInvestment.Shares_Voting__c);
        System.assertEquals(expectedNumNonVotingShares, testInvestment.Shares_Non_Voting__c);
        System.assertEquals(expectedAmount, testInvestment.Amount1__c);
    }

    @IsTest
    static void testUpdateDecreaseAmountAutoCalcSharesAndAmount() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 1.00  // 1.00 share price for easy math
        );
        insert testRound;

        // we'll remove enough money to get rid of all the voting shares and then also
        // some of the non-voting shares
        Investment__c testInvestment1 = new Investment__c();
        testInvestment1.Round__c = testRound.Id;
        testInvestment1.Shares_Voting__c = 100;
        testInvestment1.Shares_Non_Voting__c = 400;
        insert testInvestment1; // Amount 500

        // we'll remove enough money to just get rid of some voting shares
        Investment__c testInvestment2 = new Investment__c();
        testInvestment2.Round__c = testRound.Id;
        testInvestment2.Shares_Voting__c = 100;
        testInvestment2.Shares_Non_Voting__c = 400;
        insert testInvestment2; // Amount 500

        testInvestment1 = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment1.Id];
        // subtract 300 bucks to the investment - which will result in 200 amount total
        testInvestment1.Amount1__c -= 300;

        testInvestment2 = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment2.Id];
        // subtract 300 bucks to the investment - which will result in 200 amount total
        testInvestment2.Amount1__c -= 50;

        Test.startTest();
        update new List<Investment__c> {testInvestment1, testInvestment2};
        Test.stopTest();

        testInvestment1 = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment1.Id];
        // we had $500, removed $300
        System.assertEquals(200, testInvestment1.Amount1__c);
        // since we're removing 300 shares, we'll start with removing all 100 of the voting
        // shares, then the remaining 200 shares will be removed from the non-voting shares,
        // ending up at 200 left.
        System.assertEquals(0, testInvestment1.Shares_Voting__c);
        System.assertEquals(200, testInvestment1.Shares_Non_Voting__c);

        testInvestment2 = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment2.Id];
        // we had $500, removed $50
        System.assertEquals(450, testInvestment2.Amount1__c);
        // since we're removing 50 shares, we'll just remove 50 of the voting shares and leave
        // the non-voting shares alone
        System.assertEquals(50, testInvestment2.Shares_Voting__c);
        System.assertEquals(400, testInvestment2.Shares_Non_Voting__c);
    }

    @IsTest
    static void testUpdateWithSharesAutoCalcSharesAndAmount() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 1.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Shares_Voting__c = 1000;
        testInvestment.Shares_Non_Voting__c = 500;
        insert testInvestment;

        // add an aggregate of 50 shares
        testInvestment.Shares_Voting__c += 100;
        testInvestment.Shares_Non_Voting__c -= 50;

        Integer expectedNumVotingShares = (Integer) testInvestment.Shares_Voting__c;
        Integer expectedNumNonVotingShares = (Integer) testInvestment.Shares_Non_Voting__c;
        Decimal expectedAmount = (expectedNumVotingShares + expectedNumNonVotingShares) * testRound.Share_Price__c;

        Test.startTest();
        update testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(expectedAmount, testInvestment.Amount1__c);
        System.assertEquals(expectedNumVotingShares, testInvestment.Shares_Voting__c);
        System.assertEquals(expectedNumNonVotingShares, testInvestment.Shares_Non_Voting__c);
    }

    @IsTest
    static void testUpdateWithBothAutoCalcSharesAndAmount() {

        Account testAccount = new Account(Name = 'testAccount');
        insert testAccount;

        Round__c testRound = new Round__c(
            Target_Company__c = testAccount.Id,
            Series_Type__c = 'test',
            Share_Price__c = 1.23
        );
        insert testRound;

        Investment__c testInvestment = new Investment__c();
        testInvestment.Round__c = testRound.Id;
        testInvestment.Shares_Voting__c = 2000;
        testInvestment.Shares_Non_Voting__c = 3000;
        insert testInvestment;

        Integer originalNumVotingShares = (Integer) testInvestment.Shares_Voting__c;
        Integer originalNumNonVotingShares = (Integer) testInvestment.Shares_Non_Voting__c;

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];

        // do the update that we'll test for
        testInvestment.Shares_Non_Voting__c += 2345;
        testInvestment.Amount1__c += 500;

        Integer expectedNumShares = InvestmentTriggerHandler.getWholeNumSharesFromAmount(testInvestment.Amount1__c, testRound.Share_Price__c);
        Integer expectedNumNonVotingShares = originalNumNonVotingShares;
        Integer expectedNumVotingShares = expectedNumShares - expectedNumNonVotingShares;
        Decimal expectedAmount = expectedNumShares * testRound.Share_Price__c;

        Test.startTest();
        update testInvestment;
        Test.stopTest();

        testInvestment = [select Amount1__c, Shares_Voting__c, Shares_Non_Voting__c from Investment__c where Id = :testInvestment.Id];
        System.assertEquals(expectedAmount, testInvestment.Amount1__c);
        System.assertEquals(expectedNumVotingShares, testInvestment.Shares_Voting__c);
        System.assertEquals(expectedNumNonVotingShares, testInvestment.Shares_Non_Voting__c);
    }

    @IsTest
    static void testNoDuplicateInvestorRounds() {
        Account testInvestorAccount1 = new Account(Name = 'testInvestorAccount1');
        insert testInvestorAccount1;

        Account testInvestorAccount2 = new Account(Name = 'testInvestorAccount2');
        insert testInvestorAccount2;

        Account testTargetAccount = new Account(Name = 'testTargetAccount');
        insert testTargetAccount;

        Round__c testRound1 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound1',
            Share_Price__c = 111.23
        );
        insert testRound1;

        Round__c testRound2 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound2',
            Share_Price__c = 111.23
        );
        insert testRound2;

        List<Investment__c> investments = new List<Investment__c> {
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 500
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 600
            ),
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 700
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 800
            )
        };
        insert investments;

        investments[0].Investor__c = testInvestorAccount2.Id;
        investments[2].Investor__c = testInvestorAccount1.Id;

        update investments;
    }

    @IsTest
    static void testInsertInvestmentsWithDuplicateInvestorRounds() {
        Account testInvestorAccount1 = new Account(Name = 'testInvestorAccount1');
        insert testInvestorAccount1;

        Account testInvestorAccount2 = new Account(Name = 'testInvestorAccount2');
        insert testInvestorAccount2;

        Account testTargetAccount = new Account(Name = 'testTargetAccount');
        insert testTargetAccount;

        Round__c testRound1 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound1',
            Share_Price__c = 111.23
        );
        insert testRound1;

        Round__c testRound2 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound2',
            Share_Price__c = 111.23
        );
        insert testRound2;

        List<Investment__c> investments = new List<Investment__c> {
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 500
            ),
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 600
            ),
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 700
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 800
            )
        };

        List<Database.SaveResult> insertResults = Database.insert(investments, false);

        // just make sure the invalid ones didn't get inserted, we take care of validating
        // error messaging and stuff in other unit tests
        System.assertEquals(null, investments[0].Id);
        System.assertEquals(null, investments[1].Id);
        System.assert(investments[2].Id != null);
        System.assert(investments[3].Id != null);
    }

    @IsTest
    static void testUpdateInvestmentsToHaveDuplicateInvestorRounds() {
        Account testInvestorAccount1 = new Account(Name = 'testInvestorAccount1');
        insert testInvestorAccount1;

        Account testInvestorAccount2 = new Account(Name = 'testInvestorAccount2');
        insert testInvestorAccount2;

        Account testTargetAccount = new Account(Name = 'testTargetAccount');
        insert testTargetAccount;

        Round__c testRound1 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound1',
            Share_Price__c = 111.23
        );
        insert testRound1;

        Round__c testRound2 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound2',
            Share_Price__c = 111.23
        );
        insert testRound2;

        List<Investment__c> investments = new List<Investment__c> {
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 500
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 600
            ),
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 700
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 800
            )
        };
        insert investments;

        // these updates will overlap with existing data
        investments[0].Investor__c = testInvestorAccount2.Id;
        investments[1].Investor__c = testInvestorAccount2.Id;

        List<Database.SaveResult> updateResults = Database.update(new List<Investment__c> {investments[0], investments[1]}, false);
        // just make sure the invalid ones didn't get updated, we take care of validating
        // error messaging and stuff in other unit tests
        System.assertEquals(2, updateResults.size());
        System.assertEquals(false, updateResults[0].isSuccess());
        System.assertEquals(false, updateResults[1].isSuccess());
    }

    @IsTest
    static void testInsertInvestmentDuplicateExistingInvestorRounds() {
        Account testInvestorAccount1 = new Account(Name = 'testInvestorAccount1');
        insert testInvestorAccount1;

        Account testInvestorAccount2 = new Account(Name = 'testInvestorAccount2');
        insert testInvestorAccount2;

        Account testTargetAccount = new Account(Name = 'testTargetAccount');
        insert testTargetAccount;

        Round__c testRound1 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound1',
            Share_Price__c = 111.23
        );
        insert testRound1;

        Round__c testRound2 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound2',
            Share_Price__c = 111.23
        );
        insert testRound2;

        List<Investment__c> investments = new List<Investment__c> {
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 500
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 600
            ),
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 700
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 800
            )
        };
        insert investments;

        Investment__c errorInsertInvestment = new Investment__c(
            Round__c = testRound2.Id,
            Investor__c = testInvestorAccount2.Id,
            Amount1__c = 900
        );

        Database.SaveResult insertResult = Database.insert(errorInsertInvestment, false);
        System.assert(!insertResult.isSuccess());
        System.assertEquals(1, insertResult.getErrors().size());
        System.assertEquals(
            InvestmentTriggerHandler.buildDuplicateRoundInvestorErrorMessage(errorInsertInvestment),
            insertResult.getErrors()[0].getMessage()
        );
    }
    
    @isTest
    static void testMultipleInvestmentsWithSameInvestorUpsert(){
        Account testInvestorAccount1 = new Account(Name = 'testInvestorAccount1');
        insert testInvestorAccount1;

        Account testInvestorAccount2 = new Account(Name = 'testInvestorAccount2');
        insert testInvestorAccount2;

        Account testTargetAccount = new Account(Name = 'testTargetAccount');
        insert testTargetAccount;

        Round__c testRound1 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound1',
            Share_Price__c = 111.23
        );
        insert testRound1;

        Round__c testRound2 = new Round__c(
            Target_Company__c = testTargetAccount.Id,
            Series_Type__c = 'testRound2',
            Share_Price__c = 111.23
        );
        insert testRound2;

        List<Investment__c> investments = new List<Investment__c> {
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 500
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount1.Id,
                Amount1__c = 600
            ),
            new Investment__c(
                Round__c = testRound1.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 700
            ),
            new Investment__c(
                Round__c = testRound2.Id,
                Investor__c = testInvestorAccount2.Id,
                Amount1__c = 800
            )
        };
        insert investments;

        Investment__c errorInsertInvestment = new Investment__c(
            Round__c = testRound2.Id,
            Investor__c = testInvestorAccount2.Id,
            Amount1__c = 900
        );
        investments.add(errorInsertInvestment);
        
        investments[0].Investor__c = testInvestorAccount2.id;
        investments[1].Investor__c = testInvestorAccount2.id;
        Database.UpsertResult[] updateInvestments = Database.upsert(investments, false);
        for(Database.UpsertResult sr:updateInvestments) {
            Integer i = 0;
            System.assert(!sr.isSuccess());
			System.assertEquals(1,sr.getErrors().size());
            System.assertEquals(
                InvestmentTriggerHandler.buildDuplicateRoundInvestorErrorMessage(investments[i]),
                updateInvestments[i].getErrors()[0].getMessage());
            i++;
        }        
                
    }
}