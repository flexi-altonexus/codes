/*
*   @Class          :   AccountHelper
*
*   @Author         :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
*   @Created        :   16 April 2019
*   @Description    :   Helper for Account  
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       Lisis Rodriguez 				16 Abril 2019				Creation            
*
*/
public class AccountHelper {
	
	public static final Id BUSINESS_CENTRE_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Centre').getRecordTypeId(); 
	public static final String APPROVED_STATUS = 'Approved';
	
	 /*
	 * @Method          :   webAPISync
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   16 April 2019
	 * @Description     :   Sync records on Elastic Search with accounts with Business Centre RecordType
	 */
	 
	public static void webAPISync(String strType, List<Account> accs,Map<Id, Account> mapOld){
		
		List<Account> busCenterAccsToInsert = new List<Account>();
		List<Account> busCenterAccsToUpdate = new List<Account>();
        List<Account> busCenterAccsToPublish = new List<Account>();
        List<Account> busCenterAccsToUnPublish = new List<Account>();

		List<BC_sync_Fields__mdt> syncFields = [SELECT Id, Field_API_Name__c
	 											FROM BC_sync_Fields__mdt];

	 	//Get all Account recordtype = BC && fields updated 										
		for(Account iAcc: accs){
		 	
			//Only for BC Recordtypes with Approved Status
			if(iAcc.RecordtypeId == BUSINESS_CENTRE_RT && iAcc.Status__c == APPROVED_STATUS) {
				
				//If the records has been approved
                if(iAcc.Status__c != mapOld.get(iAcc.Id).get('Status__c')){
                    if(iAcc.BillingLongitude!=null && iacc.BillingLatitude!=null){
	                    if(iAcc.APISync__c==null || iAcc.APISync__c==false){
	                    	busCenterAccsToInsert.add(iAcc);
	                    }else{
	                    	busCenterAccsToPublish.add(iAcc);
	                    }
	                   
	                }else{
	                	iacc.adderror('You can´t change status to Approved without a correct BillingAddress');
	                }
			 	//If is already approved and we have an update on key fields
				}else{
					for(BC_sync_Fields__mdt iSync: syncFields){
				 		if(iAcc.get(iSync.Field_API_Name__c) != mapOld.get(iAcc.Id).get(iSync.Field_API_Name__c)){
				 			busCenterAccsToUpdate.add(iAcc);
				 			break;
				 		}
			 		}
				}
            } else if(iAcc.RecordTypeId == BUSINESS_CENTRE_RT && mapOld.get(iAcc.Id).Status__c == APPROVED_STATUS){
                busCenterAccsToUnPublish.add(iAcc);
            }
		}

		if(!busCenterAccsToInsert.isEmpty()){
			WebAPIUtils.createMessage('I',busCenterAccsToInsert);
		}

		if(!busCenterAccsToUpdate.isEmpty()){
			WebAPIUtils.createMessage('U',busCenterAccsToUpdate);
		}
        
        if(!busCenterAccsToUnPublish.isEmpty()){
            WebAPIUtils.createMessage('UP',busCenterAccsToUnPublish);
        }
        
        if(!busCenterAccsToPublish.isEmpty()){
            WebAPIUtils.createMessage('P',busCenterAccsToPublish);
        }

	}	 	

	public static void webAPISync(String strType, List<Account> accs){
	 	
	 	list<Account> busCenterAccs = new list<Account>();

	 	for(Account iAcc: accs){
	 		if(iAcc.RecordtypeId == BUSINESS_CENTRE_RT){
	 			busCenterAccs.add(iAcc);
	 		}
	 	}

		if(!busCenterAccs.isEmpty()){
			WebAPIUtils.createMessage(strType,busCenterAccs);
		}
	 }

	
}