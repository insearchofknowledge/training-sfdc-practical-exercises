global with sharing class EmailSchedulerForSummarizedOpportunities implements Schedulable {
    
    /* ########## Code to be used in developer console to schedule the job ########## 
    
    EVERY DAY AT 10AM:
    EmailSchedulerForSummarizedOpportunities scheduleDaily = new EmailSchedulerForSummarizedOpportunities();
    String daily = '0 0 10 ? * * *';
    System.schedule('DailyAt10AM', daily, scheduleDaily);
    
    Every Friday at 1PM:
    EmailSchedulerForSummarizedOpportunities scheduleWeekly = new EmailSchedulerForSummarizedOpportunities();
    String weekly = '0 0 13 ? * FRI *';
    System.schedule('Weekly at 1PM', weekly, scheduleWeekly);

    Monthly -last Friday of the month 6 PM:
    EmailSchedulerForSummarizedOpportunities scheduleMonthly = new EmailSchedulerForSummarizedOpportunities();
    String monthly = '0 0 18 ? * 6L';
    System.schedule('Monthly at 6PM', monthly, scheduleMonthly);
    */
    
    global void execute(SchedulableContext context) {
        SummarizeOpportunityAmounts sumOppAmounts = new SummarizeOpportunityAmounts();
        Database.executeBatch(sumOppAmounts);
    }
}