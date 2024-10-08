/*
*   @Class          :   EnhancedSlotHelper
*
*   @Author         :   James Boutel <james.boutel@empaua.com>
*   @Created        :   1 October 2019
*   @Description    :   Helper for Enhanced Slot Object
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       James Boutel					1 October 2019				Creation            
*
*/
public class EnhancedSlotHelper {
	
    /*
	 * @Method          :   webAPISyncInsert
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called when a new Enhanced Slot needs creating
	 */
    public static void webAPISyncInsert(List<Enhanced_Slot__c> slots){
        
        //Pass I for Insert
        WebAPIUtils.createMessage('I',slots);
    }
       
    /*
	 * @Method          :   webAPISyncDelete
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called when a Enhanced Slot needs deleting
	 */
    public static void webAPISyncDelete(List<Enhanced_Slot__c> slots){
       	
        // Pass D for Delete
        WebAPIUtils.createMessage('D',slots);
    }
}