/*
*   @Class          :   AgentReSendIntroEmailsController
*
*   @Author         :   James Boutel <james.boutel@empaua.com>
*   @Created        :   29 August 2019
*   @Description    :   Class used with the Re-Send Emails component to handle all Server side actions
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       James Boutel    				29 August 2019				Creation            
*
*/
public class AgentReSendIntroEmailsController {
    @AuraEnabled
    public static List<IntroWrapper> getIntroductions(String selected){

        List<IntroWrapper> tableData = new List<IntroWrapper>();
        List<String> introIds = (List<String>)JSON.deserialize(selected, List<String>.class);
        List<Introduction__c> intros = [SELECT Id, Name, LastIntroductionSent__c, IntroductionsSent__c, BusinessCentre__r.Name, Send_to_customer__c, Send_to_BC__c, Lead__c, Contact__c FROM Introduction__c WHERE Id IN:introIds];

        for(Introduction__c i : intros){
            i.Send_to_customer__c = true;
            i.Send_to_BC__c = true;
            tableData.add(new IntroWrapper(i.Id, i.Name, i.BusinessCentre__c, i.BusinessCentre__r.Name, i.Send_to_BC__c, i.Send_to_customer__c, i.Lead__c, i.Contact__c));
        }
        
        return tableData;
    }

    @AuraEnabled
    public static List<IntroWrapper> saveIntroductions(String newData, String originalData){

        List<IntroWrapper> newDataList = (List<IntroWrapper>)JSON.deserialize(newData, List<IntroWrapper>.class);
        List<IntroWrapper> originalDataList = (List<IntroWrapper>)JSON.deserialize(originalData, List<IntroWrapper>.class);

        for(IntroWrapper od : originalDataList){
            for(IntroWrapper nd : newDataList){
                if(nd.Id == od.Id){
                    if(nd.ReSendEmailtoProvider == FALSE){
                        od.ReSendEmailtoProvider = FALSE;
                    }
                    else if(nd.ReSendEmailtoProvider == TRUE){
                        od.ReSendEmailtoProvider = TRUE;
                    }
                    if(nd.ReSendEmailtoCustomer == FALSE){
                        od.ReSendEmailtoCustomer = FALSE;
                    }
                    else if(nd.ReSendEmailtoCustomer == TRUE){
                        od.ReSendEmailtoCustomer = TRUE;
                    }
                }
            }
        }
        return originalDataList;
    }

    @AuraEnabled
    public static Response sendEmailsApex(String data){
		
        //Here we simply update the Send_to_customer__c and Send_to_BC__c fields to fire the email alert
        List<IntroWrapper> newDataList = (List<IntroWrapper>)JSON.deserialize(data, List<IntroWrapper>.class);
        List<Introduction__c> introsToUpdate = new List<Introduction__c>();
        Set<String> ids = new Set<String>();
        Set<Id> introIds = new Set<Id>();
        
        for(IntroWrapper i : newDataList){
            introIds.add(i.Id);
            if(!ids.contains(i.Contact) && !ids.contains(i.Lead)){
                Introduction__c intro = new Introduction__c(Id = i.Id, Send_to_customer__c = i.ReSendEmailtoCustomer, Send_to_BC__c = i.ReSendEmailtoProvider);
                if(intro.Contact__c != null){
                    ids.add(intro.Contact__c);
                } else{
                    ids.add(intro.Lead__c);
				}
                introsToUpdate.add(intro);
            } else{
                Introduction__c intro = new Introduction__c(Id = i.Id, Re_Send_Email_to_Customer__c = i.ReSendEmailtoCustomer, Send_to_BC__c = i.ReSendEmailtoProvider);
                introsToUpdate.add(intro);
            }
        }
        
        try{
            update introsToUpdate;
            return new Response(true, 'Emails sent successfully!');
        }
        catch (DMLException e){
            return new Response(e);
        }

    }

    public class IntroWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String BusinessCentre;
        @AuraEnabled
        public String bcName;
        @AuraEnabled
        public Boolean ReSendEmailtoProvider;
        @AuraEnabled
        public Boolean ReSendEmailtoCustomer;
        @AuraEnabled
        public String Contact;
        @AuraEnabled
        public String Lead;

        public IntroWrapper(String Id, String Name, String BusinessCentre, String bcName, Boolean ReSendEmailtoProvider, Boolean ReSendEmailtoCustomer, String Contact, String Lead){
            this.Id = Id;
            this.Name = Name;
            this.BusinessCentre = BusinessCentre;
            this.bcName = bcName;
            this.ReSendEmailtoCustomer = ReSendEmailtoCustomer;
            this.ReSendEmailtoProvider = ReSendEmailtoProvider;
            this.Contact = Contact;
            this.Lead = Lead;
        }
    }
    //Response Class for toast messages
    public class Response {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String vsId;
        
        public Response(Boolean isSuccess, String message){
            this.isSuccess = isSuccess;
            this.message = message;
            this.type = isSuccess ? 'success' : 'error';
            this.title = isSuccess ? 'Success!' : 'An Error Occurred!';
        }
        
        public Response(){
            
        }

        public Response(DMLException e){
            this(false, '');
            
            for(Integer i = 0; i < e.getNumDml(); i++)
                this.message += '\u2022 ' + e.getDmlMessage(i) + '\r\n';
        }
    }

}