/*
*   @Class          :   AccountHandler
*
*   @Author         :   Juan Carlos Porras Blanco
*   @Created        :   16 April 2019
*   @Description    :   Handler for Account Trigger 
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       Lisis Rodriguez 				16 Abril 2019				Creation            
*
*/
public class AccountHandler {
	
	/*
	 * @Method          :   beforeInsert
	 * @Author          :  
	 * @Created         :   
	 * @Description     :   Call the actions that handle the before insert trigger
	 */    
	
	//public void beforeInsert(List<Account> listNew){}

	/*
	 * @Method          :   beforeUpdate
	 * @Author          :   
	 * @Created         :   
	 * @Description     :   Call the actions that handle the before update trigger
	 */    
	
    //public void beforeUpdate(List<Account> listNew, Map<Id, Account> mapNew, List<Account> listOld, Map<Id, Account> mapOld){}

	/*
	 * @Method          :   beforeDelete
	 * @Author          :   
	 * @Created         :   
	 * @Description     :   Call the actions that handle the before delete trigger
	 */    
	
	//public void beforeDelete(List<Account> listOld, Map<Id, Account> mapOld){}

	/*
	 * @Method          :   afterInsert
	 * @Author          :  	Juan Carlos Porras Blanco
	 * @Created         :   16 April 2019
	 * @Description     :   Call the actions that handle the after insert trigger
	 */    
	//public void afterInsert(List<Account> listNew, Map<Id, Account> mapNew){}

	/*
	 * @Method          :   afterUpdate
	 * @Author          :   Juan Carlos Porras Blanco
	 * @Created         :   16 April 2019
	 * @Description     :   Call the actions that handle the after update trigger
	 */    
	public void afterUpdate(List<Account> listNew, Map<Id, Account> mapNew, List<Account> lstOld, Map<Id, Account> mapOld) {
		
		//Elastis Search Integration {U -> upsert D-> Delete'} 
		//-- Now Update is for insert / update BC because status is the trigger process field.
		AccountHelper.webAPISync('U',listNew,mapOld);
	}

	/*
	 * @Method          :   afterDelete
	 * @Author          :   Juan Carlos Porras Blanco
	 * @Created         :   16 April 2019
	 * @Description     :   Call the actions that handle the after delete trigger
	 */    
	public void afterDelete(List<Account> listOld){
		
		//Elastis Search Integration {U -> upsert D-> Delete'}
		AccountHelper.webAPISync('D',listOld);
	}
	
	/*
	 * @Method          :   unDelete
	 * @Author          :   
	 * @Created         :   
	 * @Description     :   Call the actions that handle the undelete trigger
	 */    
	//public void OnUndelete(List<Contact> lstOld){
	//}
}