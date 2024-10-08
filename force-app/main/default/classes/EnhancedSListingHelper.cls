/*
*   @Class          :   EnhancedSListingHelper
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
public class EnhancedSListingHelper {
	
	 /*
	 * @Method          :   webAPISync
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   16 April 2019
	 * @Description     :   Calculate Slots when lookup fields changes on the enhanced list
	 */
	 
	public static void calculateSlots(List<Enhanced_Listing__c> newList, Map<Id,Enhanced_Listing__c> oldMap){

		list<Enhanced_Slot__c> listToInsert = new list<Enhanced_Slot__c>();
		list<Enhanced_Slot__c> listToDelete = new list<Enhanced_Slot__c>();
		set<String> setToDelete = new set<String>();
		 
		for(Enhanced_Listing__c el:newList){

			//Slot 1
			if(el.First_Listing_Slot__c != oldMap.get(el.Id).First_Listing_Slot__c){

				//Create
				if(String.isNotBlank(el.First_Listing_Slot__c)){
					listToInsert.add(new Enhanced_Slot__c(Slot__c='1', Business_Center__c = el.First_Listing_Slot__c, Enhanced_Listing__c = el.Id,Unique_key__c = (String)el.Id + (String)el.First_Listing_Slot__c));
				}

				//Delete
				if(String.isNotBlank(oldMap.get(el.Id).First_Listing_Slot__c)){
					setToDelete.add((String)el.Id + (String)oldMap.get(el.Id).First_Listing_Slot__c);
				}
					
			}

			//Slot 2
			if(el.Second_Listing_Slot__c != oldMap.get(el.Id).Second_Listing_Slot__c){

				//Create
				if(String.isNotBlank(el.Second_Listing_Slot__c)){
					listToInsert.add(new Enhanced_Slot__c(Slot__c='2',Business_Center__c=el.Second_Listing_Slot__c,Enhanced_Listing__c=el.Id,Unique_key__c = (String)el.Id + (String)el.Second_Listing_Slot__c));
				}

				//Delete
				if(String.isNotBlank(oldMap.get(el.Id).Second_Listing_Slot__c)){
					setToDelete.add((String)el.Id + (String)oldMap.get(el.Id).Second_Listing_Slot__c);
				}
			}

			//Slot 3
			if(el.Third_Listing_Slot__c != oldMap.get(el.Id).Third_Listing_Slot__c){

				//Create
				if(String.isNotBlank(el.Third_Listing_Slot__c)){
					listToInsert.add(new Enhanced_Slot__c(Slot__c='3', Business_Center__c=el.Third_Listing_Slot__c,Enhanced_Listing__c=el.Id,Unique_key__c = (String)el.Id + (String)el.Third_Listing_Slot__c));
				}

				//Delete
				if(String.isNotBlank(oldMap.get(el.Id).Third_Listing_Slot__c)){
					setToDelete.add((String)el.Id + (String)oldMap.get(el.Id).Third_Listing_Slot__c);
				}
			}
		}

		insert listToInsert;
		delete [SELECT Id FROM Enhanced_Slot__c WHERE Unique_key__c IN:setToDelete];
	    
	}
    
    public static void calculateSlots(List<Enhanced_Listing__c> newList){

		list<Enhanced_Slot__c> listToInsert = new list<Enhanced_Slot__c>();
		list<Enhanced_Slot__c> listToDelete = new list<Enhanced_Slot__c>();
		set<String> setToDelete = new set<String>();
		 
		for(Enhanced_Listing__c el:newList){

			//Slot 1


				//Create
				if(String.isNotBlank(el.First_Listing_Slot__c)){
					listToInsert.add(new Enhanced_Slot__c(Slot__c='1', Business_Center__c = el.First_Listing_Slot__c, Enhanced_Listing__c = el.Id,Unique_key__c = (String)el.Id + (String)el.First_Listing_Slot__c));
				}


					


			//Slot 2


				//Create
				if(String.isNotBlank(el.Second_Listing_Slot__c)){
					listToInsert.add(new Enhanced_Slot__c(Slot__c='2',Business_Center__c=el.Second_Listing_Slot__c,Enhanced_Listing__c=el.Id,Unique_key__c = (String)el.Id + (String)el.Second_Listing_Slot__c));
				}




			//Slot 3


				//Create
				if(String.isNotBlank(el.Third_Listing_Slot__c)){
					listToInsert.add(new Enhanced_Slot__c(Slot__c='3', Business_Center__c=el.Third_Listing_Slot__c,Enhanced_Listing__c=el.Id,Unique_key__c = (String)el.Id + (String)el.Third_Listing_Slot__c));
				}


		}

        if(listToInsert.size() > 0){
            try{
                insert listToInsert;
            } catch(DmlException e){
                System.debug('An error occurred when inserting slots -- ' + e.getMessage());
            }
        }
            

	    
	}

}