global class ReportShedulerMonthly implements Schedulable {
   global void execute(SchedulableContext sc) {
      
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'MonthlyReports'];
        Set <Id> usersIds = new Set <Id>();

        for (ReportSubscription__c rs: [select User__c from ReportSubscription__c where Subscribed__c = 'Monthly']){
            usersIds.add(rs.User__c);
        }

        List <Messaging.SingleEmailMessage> messages = new List <Messaging.SingleEmailMessage>();

        for (id Uid: usersIds){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(Uid); 
        message.setSenderDisplayName('Canapi Connect'); 
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.setTemplateID(emailTemplate.Id); 
        message.setWhatId(Uid); 
        messages.add(message);
        }
        if (messages.size() > 0){
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }

        }
}