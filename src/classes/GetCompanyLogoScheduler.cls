global class GetCompanyLogoScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      GetCompanyLogoBatch b = new GetCompanyLogoBatch(); 
      database.executebatch(b,10);
   }
}