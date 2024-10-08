/*
    * @Method          :   SendToDoubleClickQueueable
    * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
    * @Created         :   06 Aug 2020
    * @Description     :   Call Diffent GA Api methods depending of the type of records, each record must be send individually
    */ 
    
    public class SendToDoubleClickQueueable implements Queueable,Database.AllowsCallouts {

        private list<id> list_recordsId;
        private boolean isLead;
        private boolean isOpp;
    
        public SendToDoubleClickQueueable(list<id> newsIds, boolean isLead, boolean isOpp) {
    
            this.list_recordsId  = new list<id>();
            this.list_recordsId.addAll(newsIds);
            this.isLead = isLead;
            this.isOpp = isOpp;
            
        }
    
        public void execute(QueueableContext context) {
    
    
            if(isLead) {
                DoubleClickApi.call_LeadStatusTracking(this.list_recordsId[0]);
            }else if(isOpp) {
                DoubleClickApi.call_OpportunityStatusTracking(this.list_recordsId[0]);
            }
            this.list_recordsId.remove(0);
    
            if(this.list_recordsId.size() != 0
                && !Test.isRunningTest() ) {
                System.enqueueJob(new SendToDoubleClickQueueable(this.list_recordsId,this.isLead,this.isOpp));
            }
    
        }
    }