/*
    * @Method          :   SendToGoogleAnalyticsQueueable
    * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
    * @Created         :   30 Jul 2020
    * @Description     :   Call Diffent GA Api methods depending of the type of records, each record must be send individually
    */    
public class SendToGoogleAnalyticsQueueable implements Queueable,Database.AllowsCallouts {

    private list<id> list_recordsId;
    private boolean isLead;
    private boolean isOpp;
    private boolean isEcommerce;

    public SendToGoogleAnalyticsQueueable(list<id> newsIds, boolean isLead, boolean isOpp, boolean isEcommerce) {

        this.list_recordsId  = new list<id>();
        this.list_recordsId.addAll(newsIds);
        this.isLead = isLead;
        this.isOpp = isOpp;
        this.isEcommerce = isEcommerce;
        
    }

    public void execute(QueueableContext context) {


        if(isLead) {
            GoogleAnalyticsApi.Call_LeadInsertionTracking(this.list_recordsId[0],false);
        }else if(isOpp) {
            GoogleAnalyticsApi.Call_OpportunityStatusTracking(this.list_recordsId[0],false);
        }else if(isEcommerce) {
            GoogleAnalyticsApi.Call_EcommerceTracking(this.list_recordsId[0],false);
        }
        this.list_recordsId.remove(0);

        if(this.list_recordsId.size() != 0
            && !Test.isRunningTest() ) {
            System.enqueueJob(new SendToGoogleAnalyticsQueueable(this.list_recordsId,this.isLead,this.isOpp,this.isEcommerce));
        }

    }
}