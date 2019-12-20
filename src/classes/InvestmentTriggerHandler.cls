public class InvestmentTriggerHandler implements ITriggerHandler {

    public Boolean isDisabled() {
        return AppLevelConfigHelper.getConfig('InvestmentTriggerHandler.Disabled', 'false').equalsIgnoreCase('true');
    }

    public void bulkBefore() {}
    public void bulkAfter() {}
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    public void afterInsert(Map<Id, SObject> newItems) {
        addErrorsToIncomingDuplicateInvestorsRounds(newItems.values());
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        addErrorsToIncomingDuplicateInvestorsRounds(newItems.values());
    }
    public void afterDelete(Map<Id, SObject> oldItems) {}
    public void afterUndelete(Map<Id, SObject> newItems) {}
    public void andFinally() {}

    public void beforeInsert(List<SObject> newItems) {
        recalculateAmountsAndShares(newItems, null);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        recalculateAmountsAndShares(newItems.values(), oldItems);
    }

    private String buildInvestorRoundKey(Investment__c inv) {
        return inv.Investor__c + ':' + inv.Round__c;
    }

    // NOTE: From a performance standpoint it would be better if this was done
    // in the "BEFORE" context, however in the interest of increased readability
    // and reduced complexity we went with "AFTER".  If there are performance issues
    // then this can be revisited.
    private void addErrorsToIncomingDuplicateInvestorsRounds(List<Investment__c> investments) {

        // query existing investments in database - we're in an AFTER context here, so all the
        // incoming investments should be in the database (uncommitted) at this point
        Set<Id> rounds = new Set<Id>();
        for (Investment__c i:investments) {
            rounds.add(i.Round__c);
        }
        List<Investment__c> queriedInvestments = [SELECT Id, Investor__c, Investor__r.Name, Round__c, Round__r.Series_Type__c, Round__r.Target_Company__r.Name FROM Investment__c WHERE Round__c IN: rounds];

        // Build a map of Round/Investor keys to list of investments that have those rounds/investors
        // Basically, any key that is mapped to a List with more than 1 entry is a problem
        Map<String, List<Investment__c>> keyToInvestmentList = new Map<String, List<Investment__c>>();
        for (Investment__c queriedInvestment : queriedInvestments) {
            
            // if there's no round (impossible b/c master-detail) or investor then ignore
            if (queriedInvestment.Round__c == null || queriedInvestment.Investor__c == null) {
                continue;
            }

            String key = buildInvestorRoundKey(queriedInvestment);

            if (!keyToInvestmentList.containsKey(key)) {
                keyToInvestmentList.put(key, new List<Investment__c>());
            }
            keyToInvestmentList.get(key).add(queriedInvestment);
        }

        // build a map of our incoming investments so we can find them by Id
        Map<Id, Investment__c> incomingInvestmentMap = new Map<Id, Investment__c>(investments);

        // Now that we have all of our Investment records organized, go through the map we built and
        // look for any keys that map to Lists with more than 1 investment record.  Those are problematic.
        // Once we find one, see if it's a result of one of our incoming records - look it up by Id - and
        // if so add the error to it
        for (String key : keyToInvestmentList.keySet()) {
            List<Investment__c> investmentsWithSameRoundAndInvestor = keyToInvestmentList.get(key);
            if (investmentsWithSameRoundAndInvestor.size() > 1) {
                for (Investment__c dupeInvestment : investmentsWithSameRoundAndInvestor) {
                    Investment__c matchingIncomingInvestment = incomingInvestmentMap.get(dupeInvestment.Id);
                    if (matchingIncomingInvestment != null) {
                        matchingIncomingInvestment.addError(
                            buildDuplicateRoundInvestorErrorMessage(matchingIncomingInvestment)
                        );
                    }
                }
            }
        }
    }

    @TestVisible
    private static String buildDuplicateRoundInvestorErrorMessage(Investment__c inv) {
        return
            'Cannot have multiple investments with the same Round and Investor ' +
            '(' +
            ' Investor: ' + inv.Investor__r.Name + ';' +
            ' Target Company/Round: ' + inv.Round__r.Target_Company__r.Name + '/' + inv.Round__r.Series_Type__c +
            ')';
    }
    

    private static Map<Id, Round__c> getRelevantRoundDataForInvestments(List<Investment__c> investments) {
        List<Id> relevantRoundIds = new List<Id>();
        for (Investment__c i : investments) {
            relevantRoundIds.add(i.Round__c);
        }
        return new Map<Id, Round__c>([
            select Id,
                   Promote_Series__c
              from Round__c
             where Id = :relevantRoundIds]
         );
    }

    private static void recalculateAmountsAndShares(List<Investment__c> newItems, Map<Id, SObject> oldItems) {
        if (isAutoCalcSharesAndAmountDisabled()) {
            return;
        }

        Map<Id, Round__c> roundMap = getRelevantRoundDataForInvestments(newItems);

        List<Investment__c> recalcAmountFromShares = new List<Investment__c>();
        List<Investment__c> recalcSharesFromAmount = new List<Investment__c>();

        if (oldItems == null) {

            // new Investment records - calculate based on Amount or Shares, depending
            // on what was provided (if both were provided then we're going off the amount)
            for (Investment__c newInvestment : newItems) {
                if (roundMap.get(newInvestment.Round__c).Promote_Series__c) {
                    // don't auto calc for investments in Promote Series
                    continue;
                } else if (newInvestment.Amount1__c != null) {
                    // wipe out any values provided for the shares since we're recalculating
                    // them based on the Amount
                    newInvestment.Shares_Voting__c = 0;
                    newInvestment.Shares_Non_Voting__c = 0;
                    recalcSharesFromAmount.add(newInvestment);
                } else if (newInvestment.Shares_Voting__c != null || newInvestment.Shares_Non_Voting__c != null) {
                    recalcAmountFromShares.add(newInvestment);
                }
            }

        } else {

            // updated Investment records - determine which records had the Amount changed
            // and which ones had the number of shares changed (if both were changed then
            // we're going off of the amount)
            for (Investment__c newInvestment : newItems) {
                Investment__c oldInvestment = (Investment__c) oldItems.get(newInvestment.Id);
                System.assertNotEquals(null, oldInvestment, 'if old investment records are provided, there must be one for each new investment');

                if (roundMap.get(newInvestment.Round__c).Promote_Series__c) {
                    // don't auto calc for investments in Promote Series
                    continue;
                } else if (newInvestment.Amount1__c != oldInvestment.Amount1__c) {
                    // reset any changes to the number of shares to the old values since we're
                    // recalculating them based on the changed Amount and we need to modify things
                    // based on the share amounts that were already there
                    newInvestment.Shares_Voting__c = oldInvestment.Shares_Voting__c;
                    newInvestment.Shares_Non_Voting__c = oldInvestment.Shares_Non_Voting__c;
                    recalcSharesFromAmount.add(newInvestment);
                } else if (newInvestment.Shares_Voting__c != oldInvestment.Shares_Voting__c || newInvestment.Shares_Non_Voting__c != oldInvestment.Shares_Non_Voting__c) {
                    recalcAmountFromShares.add(newInvestment);
                }
            }
        }

        recalculateAmountFromShares(recalcAmountFromShares);
        recalculateSharesFromAmount(recalcSharesFromAmount);
    }    

    private static void recalculateSharesFromAmount(List<Investment__c> investments) {

        // first recalculate the number of shares
        for (Investment__c currentInvestment : investments) {

            // this is the new TOTAL number of shares that we should have
            Integer newNumberOfShareTotal = getWholeNumSharesFromAmount(currentInvestment.Amount1__c, currentInvestment.Share_Price__c);

            if (currentInvestment.Shares_Voting__c == null) currentInvestment.Shares_Voting__c = 0;
            if (currentInvestment.Shares_Non_Voting__c == null) currentInvestment.Shares_Non_Voting__c = 0;

            // get the difference we're applying to the total number of shares
            Integer numberOfSharesDelta = newNumberOfShareTotal - (Integer) (currentInvestment.Shares_Voting__c + currentInvestment.Shares_Non_Voting__c);

            if (numberOfSharesDelta > 0) {
                // we're just adding shares, add them to the voting shares
                currentInvestment.Shares_Voting__c += numberOfSharesDelta;
            } else if (numberOfSharesDelta < 0) {
                
                // we're reducing shares, we need to remove from voting first, and then from non
                // voting when we run out of voting shares to reduce
                
                // get the number of voting shares we'll have left after applying the delta (if
                // it's negative we'll adjust the non-voting shares as well)
                Integer numberOfVotingSharesLeftAfterSubtraction = numberOfSharesDelta + (Integer) currentInvestment.Shares_Voting__c;
                if (numberOfVotingSharesLeftAfterSubtraction >= 0) {
                    // still voting shares left after applying delta - just set the field appropriately
                    currentInvestment.Shares_Voting__c = numberOfVotingSharesLeftAfterSubtraction;
                } else {
                    // negating voting shares left after applying delta - so set the number of voting
                    // shares to 0 and then subtract the remainder from the non-voting shares
                    currentInvestment.Shares_Voting__c = 0;
                    currentInvestment.Shares_Non_Voting__c += numberOfVotingSharesLeftAfterSubtraction;
                }
            }
        }
        // since there's a good chance that the Amounts divided by share prices ended up with a
        // fractional share amounts and we rounded down, now we recalc the amounts based on the
        // whole number of shares we ended up with
        recalculateAmountFromShares(investments);
    }

    private static void recalculateAmountFromShares(List<Investment__c> investments) {
        for (Investment__c currentInvestment : investments) {
            if (currentInvestment.Shares_Voting__c == null) currentInvestment.Shares_Voting__c = 0;
            if (currentInvestment.Shares_Non_Voting__c == null) currentInvestment.Shares_Non_Voting__c = 0;
            currentInvestment.Amount1__c = (currentInvestment.Shares_Voting__c + currentInvestment.Shares_Non_Voting__c) * currentInvestment.Share_Price__c;
        }
    }

    @TestVisible
    private static Integer getWholeNumSharesFromAmount(Decimal amount, Decimal sharePrice) {
        return (Integer) Math.floor(amount / sharePrice);
    }

    @TestVisible
    private static boolean isAutoCalcSharesAndAmountDisabled() {
        return AppLevelConfigHelper.getConfig('AutoCalcSharesAndAmount.Disabled', 'false').equalsIgnoreCase('true');
    }
}