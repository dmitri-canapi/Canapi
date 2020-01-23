global class ReportShedulerDaily implements Schedulable {
   global void execute(SchedulableContext sc) {
      
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'DailyReports'];

        List <Messaging.SingleEmailMessage> messages = new List <Messaging.SingleEmailMessage>();

        Map <Id,Report> reps= new Map <Id,Report>([select id, Name from Report]);
        List <ReportSubscription__c> rsl = [select Id, ReportId__c from ReportSubscription__c ];
        for (ReportSubscription__c rs: rsl){
            rs.Report_Name__c = reps.get(rs.ReportId__c).Name;
        }
        update rsl;


        for (ReportSubscription__c rs: [select User__c, ReportId__c, Id from ReportSubscription__c where Subscribed__c = 'Daily']){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(rs.User__c); 
            message.setSenderDisplayName('Canapi Connect'); 
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(rs.Id); 
            messages.add(message);
        }

        if (messages.size() > 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }

    }
}