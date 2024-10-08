/*
*   @Class          :   SearchParameterHandler
*
*   @Author         :   James Boutel <james.boutel@empaua.com>
*   @Created        :   26 September 2019
*   @Description    :   Handler for Search Parameter Object
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       James Boutel					26 September 2019				Creation            
*
*/
public class SearchParameterHandler {
	
    /*
	 * @Method          :   isAfterInsert
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called after insert of Search Parameter 
	 */
    public void isAfterInsert(List<Search_Parameter__c> newList){
        
        //Add 12 Months up front to configure BCs
        SearchParameterHelper.addYearUpFront(newList);
        System.debug('Is batch' + System.isBatch());
        System.debug('Is isFuture' + System.isFuture());
        System.debug('Is isQueueable' + System.isQueueable());
        System.debug('Is isScheduled' + System.isScheduled());
        //Sync Parameter with Custom Web API
         if(!System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled()) {
            SearchParameterHelper.webAPISyncInsert(newList);
        }


    }
    
    /*
	 * @Method          :   isAfterUpdate
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called after update of Search Parameter 
	 */
    public void isAfterUpdate(List<Search_Parameter__c> newList, Map<Id,Search_Parameter__c> oldMap){
        System.debug('Is batch' + System.isBatch());
        System.debug('Is isFuture' + System.isFuture());
        System.debug('Is isQueueable' + System.isQueueable());
        System.debug('Is isScheduled' + System.isScheduled());
        List<Search_Parameter__c> searchParams = new List<Search_Parameter__c>();
        
        for(Search_Parameter__c sp : newList){
            if(oldMap.get(sp.Id).Url__c != sp.Url__c){
                searchParams.add(sp);
            }
        }
        
        if(searchParams.size() > 0){
            if(!System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled()) {
                SearchParameterHelper.webAPISyncInsert(newList);
            }
        }
    }
    
    /*
	 * @Method          :   isAfterDelete
	 * @Author          :   James Boutel
	 * @Created         :   26 Sep 2019
	 * @Description     :   Method called after delete of Search Parameter 
	 */
    public void isAfterDelete(List<Search_Parameter__c> oldList){
        System.debug('Is batch' + System.isBatch());
        System.debug('Is isFuture' + System.isFuture());
        System.debug('Is isQueueable' + System.isQueueable());
        System.debug('Is isScheduled' + System.isScheduled());
         if(!System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled()) {
            SearchParameterHelper.webAPISyncInsert(oldList);
        }
        
    }
}