/*
*   @Class          :   EnhancedSlotHandler
*
*   @Author         :   James Boutel <james.boutel@empaua.com>
*   @Created        :   1 October 2019
*   @Description    :   Handler for Enhanced Slot Object
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       James Boutel					1 October 2019				Creation            
*
*/
public class EnhancedSlotHandler {
	
    /*
	 * @Method          :   isAfterInsert
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called after insert of Enhanced Slot
	 */
    public void isAfterInsert(List<Enhanced_Slot__c> newList){

        if(!System.isBatch())  {

            Set<Id> enhancedSlotIds = new Set<Id>();
            List<Enhanced_Slot__c> slotsToInsert = new List<Enhanced_Slot__c>();
            
            for(Enhanced_Slot__c es : newList){
                enhancedSlotIds.add(es.Id);
            }
            
            List<Enhanced_Slot__c> slotsWithListings = [SELECT Id, Name, Business_Center__c, Impressions__c, Views__c, Number_of_Quotes__c, Enhanced_Listing__r.Month_Date__c, Enhanced_Listing__r.Search_Parameter__r.Url__c, Unique_key__c FROM Enhanced_Slot__c WHERE Id IN: enhancedSlotIds];
            
            for(Enhanced_Slot__c es : slotsWithListings){
                if(es.Business_Center__c != null && es.Enhanced_Listing__r.Month_Date__c != null){
                    slotsToInsert.add(es);
                }
            }
            
            if(slotsToInsert.size() > 0){
                EnhancedSlotHelper.webAPISyncInsert(slotsToInsert);
            }
        }
        
    }
    
    /*
	 * @Method          :   isAfterUpdate
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called after update of Enhanced Slot
	 
    public void isAfterUpdate(List<Enhanced_Slot__c> newList, Map<Id,Enhanced_Slot__c> oldMap){
        
        List<Enhanced_Slot__c> searchParams = new List<Enhanced_Slot__c>();
        
    }*/
    
    /*
	 * @Method          :   isAfterDelete
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called after delete of Enhanced Slot
	 */
    public void isAfterDelete(List<Enhanced_Slot__c> oldList){
        
        Set<Id> enhancedSlotIds = new Set<Id>();
        List<Enhanced_Slot__c> slotsToDelete = new List<Enhanced_Slot__c>();
        
        for(Enhanced_Slot__c es : oldList){
            enhancedSlotIds.add(es.Id);
        }
        
        List<Enhanced_Slot__c> slotsWithListings = [SELECT Id, Business_Center__c, Enhanced_Listing__r.Month_Date__c, Enhanced_Listing__r.Search_Parameter__r.Url__c, Unique_key__c FROM Enhanced_Slot__c WHERE Id IN: enhancedSlotIds ALL ROWS];
        
        EnhancedSlotHelper.webAPISyncDelete(slotsWithListings);
    }
}