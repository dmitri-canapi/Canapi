public without sharing class TermsOfService {
    @AuraEnabled
    public static TermsWrapper getTermsState (){

        Boolean termsState = [select Accepted_Terms__c from User where id =: UserInfo.getUserId()].Accepted_Terms__c;
        String terms = [select HTML_code__c from Terms_of_Service__mdt limit 1].HTML_code__c;
        return new TermsWrapper (termsState, terms);
    }

    @AuraEnabled
    public static void acceptTerms (){
        User u = new User (id = UserInfo.getUserId(), Accepted_Terms__c = true);
        update u;
    }

    public class TermsWrapper {
        @AuraEnabled public boolean TermsState { get; set;}
        @AuraEnabled public String Terms { get; set;}
        public TermsWrapper (boolean TermsState, String Terms){
            this.TermsState = TermsState;
            this.Terms = Terms;
        }
    }

}