/*
*   @Class          :   EnhancedSListingHandler
*
*   @Author         :   James Boutel <james.boutel@empaua.com>
*   @Created        :   26 September 2019
*   @Description    :   Handler for Enhanced Listing
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       James Boutel					26 September 2019				Creation            
*
*/
public class EnhancedSListingHandler {
	
       
    /*
	 * @Method          :   isAfterUpdate
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called after update of Enhanced_Listing__c
	 */
    public void isAfterUpdate(List<Enhanced_Listing__c> newList, Map<Id,Enhanced_Listing__c> oldMap){
        
        EnhancedSListingHelper.calculateSlots(newList,oldMap);
    }
    
    /*
	 * @Method          :   isAfterInsert
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called after update of Enhanced_Listing__c
	 */
    public void isAfterInsert(List<Enhanced_Listing__c> newList){
        
        EnhancedSListingHelper.calculateSlots(newList);
    }
    
   
}