global without sharing class CommunityLoginController {
 
        @AuraEnabled
        global static String checkPortal(String username, String password) {
            try {
                ApexPages.PageReference lgn = Site.login(username,password, '');
                aura.redirect(lgn);
            return null;
            }
            catch (Exception ex) {
                return ex.getMessage();
            }
        }
         
        @AuraEnabled
        global static String forgotPassowrd(String username) {
            String procesMsg = '';
            
            if ([select id from User where username=:username].size()>0) {
            Site.forgotPassword(username);
                procesMsg = 'Your password was successfully reset';
            }
            else {
                procesMsg = 'User name you entered is invalid. Please check your user name and try again';
            }
            return procesMsg;
        }

        @AuraEnabled
        public static String getTerms (){
           return [select HTML_code__c from Terms_of_Service__mdt limit 1].HTML_code__c;
        }
    }