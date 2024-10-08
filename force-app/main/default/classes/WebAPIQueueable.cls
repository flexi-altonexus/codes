/*
*   @Class          :   WebAPIQueueable
*
*   @Author         :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
*   @Created        :   16 Abril 2019
*   @Description    :   Queueable Class to do the ElasticSearch's callouts
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       Lisis Rodriguez 				16 Abril 2019				Creation            
*
*/
public class WebAPIQueueable implements Queueable, Database.AllowsCallouts {
	
	public static final String BUSINESS_CENTRE_SERVICE = '/api/businesscentre/';
    public static final String ENHANCED_LISTING_SERVICE = '/api/advertising/';
	
	private List<SObject> records;
	private String strType;

	public WebAPIQueueable(String strType, List<SObject> records){
		this.records = records;
		this.strType = strType;

	}
	public void execute(QueueableContext context) {
		
		String jsonToSend;
		String service;

		//Accounts Sync
		if(records.get(0).getsobjecttype() == Schema.Account.getSObjectType()){
			// callout for account records
			//list<WebAPIDataModel.BusinessCentre> recordsList = new list<WebAPIDataModel.BusinessCentre>();
			Account acc;

			service = BUSINESS_CENTRE_SERVICE;

			for(SObject s :records){
				//Create new integration record
				acc = (Account)s;
                if(acc.BillingLatitude!= null && acc.BillingLongitude != null){
    				
                    WebAPIDataModel.BusinessCentre newRec = new WebAPIDataModel.BusinessCentre(acc); 
    				newRec.centreName = acc.Name;
    				
                    //TODO ------- SEND BUSINESS CENTRE IMAGES AS A LIST OF ABSOLUTE URLS
                    
                    //Assign Service
                    if(strType == 'I'){
                        service += 'addbusinesscentre';
                    }else if(strType == 'U'){
                        service += 'updatebusinesscentre/' + acc.Id;
                    }else if(strType == 'D'){
                        service += 'deletebusinesscentre/' + acc.Id;
                    }else if(strType == 'P'){
                        service += 'setbusinesscentrestatus?id=' + acc.Id + '&published=true';
                    }else if(strType == 'UP'){
                        service += 'setbusinesscentrestatus?id=' + acc.Id + '&published=false';
                    }

    				//Create JSON
    				jsonToSend = JSON.serialize(newRec);

    				//Send message
                    system.debug('JSONJC'+WebAPIDataModel.convertInternalId(jsonToSend));
                	WebAPIUtils.sendPOSTMessage(service,WebAPIDataModel.convertInternalId(jsonToSend),acc.Id);

                }else{
                    system.debug('We need BillingLongitude and BillingLatitude to Sync:' + acc.Id);
                }
			}
	
		}

		//Enhanced Sync or Locations
        if(records.get(0).getSObjectType() == Schema.Search_Parameter__c.getSObjectType()){

            Search_Parameter__c sp;
            service = ENHANCED_LISTING_SERVICE;
            
            for(SObject s : records){
                // Create new Enhanced Listing record for integration
                sp = (Search_Parameter__c)s;
                WebAPIDataModel.Enhanced_Listing el = new WebAPIDataModel.Enhanced_Listing();
                el.CreatedDate = DateTime.NOW();
                el.Url = sp.Url__c;
                el.AgentId = 1;
                
                jsonToSend = JSON.serialize(el);
                
                // Assign Service
                if(strType == 'I'){
                    service+= 'addgroup';
                } else if(strType == 'U'){
                    service += 'editgroup?url='+sp.Url__c;
                } else if(strType == 'D'){
                    service += 'removegroup?url='+sp.Url__c;
                }
                
                //Send message
                WebAPIUtils.sendPOSTMessage(service,jsonToSend,sp.Id);
            }
            
        }
        
        //Enhanced Slots
        if(records.get(0).getSObjectType() == Schema.Enhanced_Slot__c.getSObjectType()){
            
            Enhanced_Slot__c slot;
            service = ENHANCED_LISTING_SERVICE;
            
            for(SObject s : records){
                
                slot = (Enhanced_Slot__c)s;
                WebAPIDataModel.Enhanced_Slot slotWrapper = new WebAPIDataModel.Enhanced_Slot();

                if(strType == 'I'){
                    
                    service += 'addbusinesscentretogroup?url=' + slot.Enhanced_Listing__r.Search_Parameter__r.Url__c;

                    slotWrapper.SlotId = slot.Unique_key__c;
                    slotWrapper.BusinessCentreId = slot.Business_Center__c;
                    slotWrapper.Month = slot.Enhanced_Listing__r.Month_Date__c.Month();
                    slotWrapper.Year = slot.Enhanced_Listing__r.Month_Date__c.Year();
                    slotWrapper.Impressions = (Integer)slot.Impressions__c;
                    slotWrapper.Quotes = (Integer)slot.Number_of_Quotes__c;
                    slotWrapper.Views = (Integer)slot.Views__c;
                
                } else if(strType == 'D'){
                    jsonToSend = ''; 
                    service += 'removebusinesscentrefromgroup?groupURL=' + slot.Enhanced_Listing__r.Search_Parameter__r.Url__c + '&businessCentreId=' + slot.Business_Center__c + '&month=' + slot.Enhanced_Listing__r.Month_Date__c.Month();
                }

                
                
                
                jsonToSend = JSON.serialize(slotWrapper);
                System.debug(jsonToSend);
                
               
                System.debug(service);
                
                //Send message
				WebAPIUtils.sendPOSTMessage(service,jsonToSend, slot.Id);
            }
        }
		
	}
}