public  class OpportunityHelper {
	private final static string CLOSEWON_STAGE = 'Closed Won';
    private final static string CLOSELOST_STAGE = 'Closed Lost';
    private final static string FIRSTVIEWINGCOMPLETE_STAGE = '1st Viewing Completed';
    public static final String STATUS_ACTIVE = 'Active';

    /*
    * @Method          :   OpportunityStageUpdated_SendToGA
    * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
    * @Created         :   30 Jul 2020
    * @Description     :   send all new Opps, or stage updated OPPs to GA, if closed Won, send to GA with different parameters
    */  
    public static void OpportunityStageUpdated_SendToGA(Map<Id,Opportunity> mapNews, Map<Id, Opportunity> mapOlds) {
        List<id> lst_OppsIds = new List<id>();
        List<id> lst_EccommerceIds = new List<id>();

        if (mapOlds == null) {
        
            lst_Oppsids.addAll(mapNews.keyset());
        
        }else {

            for (id lNewOppId : mapNews.keyset()) {

                if (mapOlds == null 
                    ||mapNews.get(lNewOppId).StageName != mapOlds.get(lNewOppId).StageName) {

                    if(mapNews.get(lNewOppId).StageName == CLOSEWON_STAGE ) {
                        lst_EccommerceIds.add(lNewOppId);
                    }else {
                        lst_OppsIds.add(lNewOppId);
                    }

                }

            }
        }

        if (!lst_OppsIds.isEmpty()) {
            System.enqueueJob(new SendToGoogleAnalyticsQueueable(lst_Oppsids,false,true,false));
        }
        if (!lst_EccommerceIds.isEmpty()) {
            System.enqueueJob(new SendToGoogleAnalyticsQueueable(lst_Eccommerceids,false,false,true));
        }
    }
 /*
    * @Method          :   OpportunityStageUpdated_SendToDC
    * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
    * @Created         :   30 Jul 2020
    * @Description     :   send all 1st Viewing Completed,Closed Won or Closed Lost Opp to DC
    */  
    public static void OpportunityStageUpdated_SendToDC(Map<Id,Opportunity> mapNews, Map<Id, Opportunity> mapOlds) {
        
        List<id> lst_OppsIds = new List<id>();
        List<id> lst_EccommerceIds = new List<id>();

        /*
        if (mapOlds == null
            && ) {
        
            lst_Oppsids.addAll(mapNews.keyset());
        
        }else {
*/
            for (id lNewOppId : mapNews.keyset()) {

                if (
                    (mapOlds == null 
                    ||  mapNews.get(lNewOppId).StageName != mapOlds.get(lNewOppId).StageName
                    )
                    && (mapNews.get(lNewOppId).StageName == CLOSEWON_STAGE 
                        || mapNews.get(lNewOppId).StageName == CLOSELOST_STAGE 
                        || mapNews.get(lNewOppId).StageName == FIRSTVIEWINGCOMPLETE_STAGE 
                        ) 
                    ){
                    
                    lst_OppsIds.add(lNewOppId); 
                    
                }

            }

        //}

        if (!lst_OppsIds.isEmpty()) {
            System.enqueueJob(new SendToDoubleClickQueueable(lst_Oppsids,false,true));
        }
       
    }
 /*
    * @Method          :   call_OpportunityStatusTracking
    * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
    * @Created         :   30 Jul 2020
    * @Description     :   Generates a GA code (GUID) for the manually created Opps, also set the GA type 
    */  
    public static void checkIfGoogleAnalyticsCode(list<Opportunity> listNews) {

        for(Opportunity lOpp: listNews ) {

            if(lOpp.GA_Client_ID__c == null ) {
                lOpp.GA_Client_ID__c = GuidUtil.NewGuid();
                lOpp.GA_Type__c = 'non-web'; 
                
            }else {
                lOpp.GA_Type__c = 'web'; 
            }
        } 

    }

     /*
    * @Method          :   roundRobinOpportunitiesAssignment
	* @Author          :   Mike Chadwick <mike.chadwick@empaua.com>
	* @Created         :   28 February 2024
	* @Description     :   Method to do the round robin opportunity owner assigignment 
    */  
	public static void roundRobinOpportunitiesAssignment(List<Opportunity> opportunityList, Map<Id, Opportunity> mapMembersOpportunities){
        Map<Id, List<Opportunity>> mapIdGroup_OpportunityList = new Map<Id, List<Opportunity>>();

        Map<Id,List<RR_Member__c>> mapGroupId_MembersList = getMapGroupMembers();
        Map<String, List<RR_Postal_Code_Range_assigment__c>> mapPostalCode_RangeAssig= getPostalCodeRAssig(opportunityList);
        
        //Populate the map mapIdGroup_OpportunityList
        for(Opportunity opportunityInd: opportunityList){
            if(String.isNotBlank(opportunityInd.Location__c) && opportunityInd.NumberofDesks__c != NULL && mapPostalCode_RangeAssig.get(opportunityInd.Location__c)!= NULL){
               RR_Postal_Code_Range_assigment__c assignment = findRangAssig(opportunityInd,mapPostalCode_RangeAssig.get(opportunityInd.Location__c));
               List<Opportunity> opportunities;
               if(assignment != NULL){
                   if(mapIdGroup_OpportunityList.containsKey(assignment.RR_Group__c)){
                    opportunities = mapIdGroup_OpportunityList.get(assignment.RR_Group__c);
                   }else{
                    opportunities = new List<Opportunity>();
                   }
                   opportunities.add(opportunityInd);
                   mapIdGroup_OpportunityList.put(assignment.RR_Group__c, opportunities);
               }
           }
       }

       for(Id key: mapIdGroup_OpportunityList.keySet()){
           if (mapGroupId_MembersList.get(key) != null){
            assignOwners(mapIdGroup_OpportunityList.get(key), mapGroupId_MembersList.get(key), mapMembersOpportunities);
           }
           
       }
   }

   /*
	* @Method          :   getMapGroupMembers
	* @Author          :   Mike Chadwick <mike.chadwick@empaua.com>
	* @Created         :   28 February 2024
	* @Description     :   Auxiliar function to get the map with Id Group and GroupdMembers
	*/ 
	public static Map<Id,List<RR_Member__c>> getMapGroupMembers(){

		Map<Id,List<RR_Member__c>> mapIdGroup_Members = new Map<Id,List<RR_Member__c>>();
		List<RR_Member__c> members = [SELECT Id, 
                                            Last_Opportunity_Assignment__c,
								 			User__c,
								 			RR_Group__c
								 	FROM RR_Member__c
								 	WHERE Status__c =: STATUS_ACTIVE
								 	AND User__c IN: ([SELECT Id FROM User WHERE IsActive = True])
								 	ORDER BY Last_Opportunity_Assignment_Date__c ASC
								 	NULLS FIRST];

		for(RR_Member__c iMember: members){
			List<RR_Member__c> membersList;
			if(mapIdGroup_Members.containsKey(iMember.RR_Group__c)){
				membersList = mapIdGroup_Members.get(iMember.RR_Group__c);
			}else{
				membersList = new List<RR_Member__c>();
			}
			membersList.add(iMember);
			mapIdGroup_Members.put(iMember.RR_Group__c, membersList);
		}
		return mapIdGroup_Members;
	}

	/*
	* @Method          :   getPostalCodeRassig
	* @Author          :   Mike Chadwick <mike.chadwick@empaua.com>
	* @Created         :   28 February 2024
	* @Description     :   Get map with Postal Codes and list of RR_Postal_Code_Range_assigment__c for each one
	*/ 
	public static Map<String, List<RR_Postal_Code_Range_assigment__c>>  getPostalCodeRassig(List<Opportunity> opportunityList){
        Map<String, List<RR_Postal_Code_Range_assigment__c>> mapPostalCode_RangeAssig = new Map<String, List<RR_Postal_Code_Range_assigment__c>>();
        
        Set<String> postalCodesSet = new Set<String>();
        for(Opportunity iOpportunity: opportunityList){
            if(String.isNotBlank(iOpportunity.Location__c)){
                postalCodesSet.add(iOpportunity.Location__c);
            }
        }

        Map<Id, RR_Postal_Code__c> mapPostalCodes = new Map<Id, RR_Postal_Code__c>(
                        [SELECT Id, Postal_Code__c
                         FROM RR_Postal_Code__c
                         WHERE Postal_Code__c IN:postalCodesSet]);

        List<RR_Postal_Code_Range_assigment__c> listPostalCodeassigs = 
                        [SELECT Id,
                                RR_Group__c,
                                RR_Postal_Code__c,
                                Number_of_Desks_min__c,
                                Number_of_Desks_Max__c
                         FROM RR_Postal_Code_Range_assigment__c
                         WHERE RR_Postal_Code__c IN: mapPostalCodes.keySet()];
       
       //Populate mapPostalCode_RangeAssig
       for(RR_Postal_Code_Range_assigment__c iRangeassig: listPostalCodeassigs){
           String postalCode = mapPostalCodes.get(iRangeassig.RR_Postal_Code__c).Postal_Code__c;
           List<RR_Postal_Code_Range_assigment__c> listassig;
           if(mapPostalCode_RangeAssig.containsKey(postalCode)){
               listassig = mapPostalCode_RangeAssig.get(postalCode);
           }else{
               listassig = new List<RR_Postal_Code_Range_assigment__c>();
           }
           listassig.add(iRangeassig);
           mapPostalCode_RangeAssig.put(postalCode, listAssig);
       }
       return mapPostalCode_RangeAssig;
   }  

	/*
	* @Method          :   findRangeassig
	* @Author          :   Mike Chadwick <mike.chadwick@empaua.com>
	* @Created         :   28 February 2024
	* @Description     :   Auxiliar method to find the range assigignment for an Opportunity 
	*/ 
	public static RR_Postal_Code_Range_assigment__c findRangAssig(Opportunity iOpportunity, List<RR_Postal_Code_Range_assigment__c> rangAssigList ){
        RR_Postal_Code_Range_assigment__c retRangeAssig;
        Boolean found = false;
        Integer i = 0;
        while (i < rangAssigList.size() && !found){
            if(iOpportunity.NumberofDesks__c >= rangAssigList.get(i).Number_of_Desks_min__c 
                && iOpportunity.NumberofDesks__c <= rangAssigList.get(i).Number_of_Desks_Max__c){
                found = true;
                retRangeAssig = rangAssigList.get(i);
            }else{
                i++;
            }
        }
        return retRangeAssig;
   }

	/*
	* @Method          :   assignOwners
	* @Author          :   Mike Chadwick <mike.chadwick@empaua.com>
	* @Created         :   28 February 2024
	* @Description     :   Assign opportunity owner Id to the next round robin member
	*/ 
	public static void assignOwners(List<Opportunity> opportunities, List<RR_Member__c> members, Map<Id, Opportunity> mapMembersOpportunities){
	 	for(Integer i = 0; i < opportunities.size(); i++){
            opportunities.get(i).OwnerId = members.get(i).User__c;
            opportunities.get(i).RR_Group__c = members.get(i).RR_Group__c;

            mapMembersOpportunities.put(members.get(i).Id, opportunities.get(i));
	 		members.add(members.get(i)); // Put the current member at the end of the list to implement a circular list
	 	}
	}
 
	/*
	* @Method          :   updateMembers
	* @Author          :   Mike Chadwick <mike.chadwick@empaua.com>
	* @Created         :   28 February 2024
	* @Description     :   Updates the Last Opportunity Assignment and Datetime for the members
	*/ 
	public static void updateMembers(Map<Id, Opportunity> mapMembersOpportunities){
        List<RR_Member__c> membersToUpd = new  List<RR_Member__c>();
        for(RR_Member__c iMember: [SELECT Id FROM RR_Member__c WHERE Id IN: mapMembersOpportunities.KeySet()]){
            iMember.Last_Opportunity_Assignment__c = mapMembersOpportunities.get(iMember.Id).Id;
            iMember.Last_Opportunity_Assignment_Date__c = Datetime.now();
            membersToUpd.add(iMember);
        }
        if(!membersToUpd.isEmpty()){
            update membersToUpd;
        }
   }
  
}