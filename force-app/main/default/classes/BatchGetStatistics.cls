global class BatchGetStatistics implements Database.batchable<WebAPIDataModel.StatisticBC>,Database.AllowsCallouts { 
   
   global Iterable<WebAPIDataModel.StatisticBC> start(Database.batchableContext info){ 
       return WebAPIUtils.getWebAPIStatistics();
   }   

   global void execute(Database.batchableContext info, List<WebAPIDataModel.StatisticBC> scope){ 
      
      List<WebAPIDataModel.StatisticBC> lstToProcess = (List<WebAPIDataModel.StatisticBC>)scope;
     
      list<Enhanced_Slot__c> listToUpsert = new list<Enhanced_Slot__c>();

      system.debug('======exetcute method-scope--'+ lstToProcess);

      for(WebAPIDataModel.StatisticBC wrapperBC:lstToProcess){

      		Enhanced_Slot__c newRec = new Enhanced_Slot__c();

      		newRec.Views__c = String.isNotBlank(wrapperBC.v) ? Decimal.valueof(wrapperBC.v) : 0;
      		newRec.Impressions__c = String.isNotBlank(wrapperBC.i) ? Decimal.valueof(wrapperBC.i) : 0;
      		newRec.Number_of_Quotes__c = String.isNotBlank(wrapperBC.q) ? Decimal.valueof(wrapperBC.q) : 0;
      		newRec.Unique_key__c = wrapperBC.uniqueKey;
      		newRec.Business_Center__c = wrapperBC.Id;
			newRec.Enhanced_Listing__c = wrapperBC.uniqueKey.remove(wrapperBC.Id);
      		listToUpsert.add(newRec);
      }

      
	  System.debug(listToUpsert);
      Database.UpsertResult[] results = Database.upsert(listToUpsert, Enhanced_Slot__c.Unique_key__c, false);
	  System.debug(results);
      for(Integer index = 0, size = results.size(); index < size; index++) {
		  
	    if(results[index].isSuccess()) {
	        if(results[index].isCreated()) {
	            System.debug(listToUpsert[index].Unique_key__c +' was created');
	        } else {
	            System.debug(listToUpsert[index].Unique_key__c +' was updated');
	        }
	    }else{
	    	 System.debug(listToUpsert[index].Unique_key__c +' was not created');
	    }
	}

       
   }  

   global void finish(Database.batchableContext info){     
   } 


}