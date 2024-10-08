/*
*   @Class          :   SearchParameterHelper
*
*   @Author         :   James Boutel <james.boutel@empaua.com>
*   @Created        :   26 September 2019
*   @Description    :   Helper for Search Parameter Object
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       James Boutel					26 September 2019				Creation            
*
*/
public class SearchParameterHelper {
	
    
	

	 /*
	 * @Method          :   webAPISyncInsert
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called when a new Search parameter needs creating
	 */
    public static void addYearUpFront(List<Search_Parameter__c> searchParams){
        
        //List To Insert
        list<Enhanced_Listing__c> listToInsert = new list<Enhanced_Listing__c>();
        
        //First day of this month
        Date dateMonth = System.Date.today().addmonths(1).toStartOfMonth();

        // Pass I for Insert
       	for (Integer i=1; i < 12; i++) {
			
			for(Search_Parameter__c sp:searchParams){
   				   				
   				Enhanced_Listing__c newRec = new Enhanced_Listing__c();
   				newRec.Month_Date__c = dateMonth;
   				newRec.Search_Parameter__c = sp.Id;

   				listToInsert.add(newRec);
   			}

   			dateMonth = dateMonth.addMonths(1);

		}
		
		insert listToInsert;
           
    }

    /*
	 * @Method          :   webAPISyncInsert
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called when a new Search parameter needs creating
	 */
    public static void webAPISyncInsert(List<Search_Parameter__c> searchParams){
        
        // Pass I for Insert
        WebAPIUtils.createMessage('I',searchParams);
    }
    
    /*
	 * @Method          :   webAPISyncUpdate
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called when a Search parameter needs updating
	 */
    public static void webAPISyncUpdate(List<Search_Parameter__c> searchParams){
        
        // Pass U for Update
        WebAPIUtils.createMessage('I',searchParams);
    }
    
    /*
	 * @Method          :   webAPISyncDelete
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called when a Search Parameter needs deleting
	 */
    public static void webAPISyncDelete(List<Search_Parameter__c> searchParams){
       	
        // Pass D for Delete
        WebAPIUtils.createMessage('D',searchParams);
    }
}