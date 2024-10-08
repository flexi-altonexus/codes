/*
 * @who     : James Boutel <james.boutel@empaua.com>
 * @when    : 23-10-2019
 * @what    : IntroductionTriggerHandler - Class to set Intros as Automatic or Manual, and also call introduction Helper to match Intros with Contacts or Leads
 */
public class IntroductionTriggerHandler {
    
    /*
     * @method      : isBeforeInsert()
     * @description : Method to handle Before Insert of Introduction records
     * @return      : void
     * @params      : List of Introductions
    */
    public void isBeforeInsert(List<Introduction__c> newlist){
             
        IntroductionHelper.setAutomaticIntros(newlist);     
        IntroductionHelper.setInformationBefore(newlist);
        IntroductionHelper.identifyIncommingDuplicates(newlist);
        IntroductionHelper.assingIntroductionsToLeadOrOpp(newlist);
        IntroductionHelper.setEmailFieldsIfAJWithRelatedDeal(newlist);

    }
    /*
     * @method      : isAfterInsert()
     * @description : Method to handle After Insert of Introduction records
     * @return      : void
     * @params      : List of Introductions
    */
    public void isAfterInsert(List<Introduction__c> newlist){
        IntroductionHelper.callAmberJonesIntrosByDistanceQueueable(newlist);
      
       
    }

}