public class LeadHelper {
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_INACTIVE = 'Inactive';
    
    /*
* @Method          :   roundRobinLeadsassigigment
* @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
* @Created         :   3 April 2019
* @Description     :   Method to do the round robin Lead assigignment 
*/ 
    public static void roundRobinLeadsAssigment(List<Lead> leadList, Map<Id, Lead> mapMembersLeads){
        Map<Id, List<Lead>> mapIdGroup_LeadList = new Map<Id, List<Lead>>();
        
        Map<Id,List<RR_Member__c>> mapGroupId_MembersList = getMapGroupMembers();
        Map<String, List<RR_Postal_Code_Range_assigment__c>> mapPostalCode_RangeAssig= getPostalCodeRAssig(leadList);
        System.debug('****mapGroupId_MembersList ' + mapGroupId_MembersList);
        System.debug('****mapPostalCode_Rangeassig ' + mapPostalCode_RangeAssig);
        
        //Populate the map mapIdGroup_LeadList
        for(Lead leadInd: leadList){
            if(leadInd.Country!='UK'){
                if(String.isNotBlank(leadInd.Location__c) && leadInd.NumberofDesks__c != NULL && mapPostalCode_RangeAssig.get(leadInd.Location__c)!= NULL){
                    RR_Postal_Code_Range_assigment__c assignment = findRangAssig(leadInd,mapPostalCode_RangeAssig.get(leadInd.Location__c));
                    List<Lead> leads;
                    if(assignment != NULL){
                        if(mapIdGroup_LeadList.containsKey(assignment.RR_Group__c)){
                            leads = mapIdGroup_LeadList.get(assignment.RR_Group__c);
                        }else{
                            leads = new List<Lead>();
                        }
                        leads.add(leadInd);
                        mapIdGroup_LeadList.put(assignment.RR_Group__c, leads);
                    }
                }
            }
        }
        
        for(Id key: mapIdGroup_LeadList.keySet()){
            system.debug(key);
            system.debug(mapGroupId_MembersList.get(key));
            if (mapGroupId_MembersList.get(key) != null){
                assigignOwners(mapIdGroup_LeadList.get(key), mapGroupId_MembersList.get(key), mapMembersLeads);
            }
            
        }
    }
    
    /*
* @Method          :   updateMembers
* @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
* @Created         :   3 April 2019
* @Description     :   Updates the Last Lead Assignment and Datetime for the members
*/ 
    public static void updateMembers(Map<Id, Lead> mapMembersLeads){
        System.debug('*****mapMembersLeads ' + mapMembersLeads);
        List<RR_Member__c> membersToUpd = new  List<RR_Member__c>();
        for(RR_Member__c iMember: [SELECT Id FROM RR_Member__c WHERE Id IN: mapMembersLeads.KeySet()]){
            iMember.Last_Lead_assignment__c = mapMembersLeads.get(iMember.Id).Id;
            iMember.Last_Assignment__c = Datetime.now();
            membersToUpd.add(iMember);
        }
        if(!membersToUpd.isEmpty()){
            update membersToUpd;
        }
    }
    
    
    /*
* @Method          :   getPostalCodeRassig
* @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
* @Created         :   3 April 2019
* @Description     :   Get map with Postal Codes and list of RR_Postal_Code_Range_assigment__c for each one
*/ 
    public static Map<String, List<RR_Postal_Code_Range_assigment__c>>  getPostalCodeRassig(List<Lead> leadList){
        Map<String, List<RR_Postal_Code_Range_assigment__c>> mapPostalCode_RangeAssig = new Map<String, List<RR_Postal_Code_Range_assigment__c>>();
        
        Set<String> postalCodesSet = new Set<String>();
        for(Lead iLead: leadList){
            if(String.isNotBlank(iLead.Location__c)){
                postalCodesSet.add(iLead.Location__c);
            }
        }
        System.debug('***postalCodesSet ' + postalCodesSet);
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
        
        System.debug('***mapPostalCodes ' + mapPostalCodes);
        System.debug('***listPostalCodeassigs ' + listPostalCodeassigs);
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
* @Method          :   getMapGroupMembers
* @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
* @Created         :   3 April 2019
* @Description     :   Auxiliar function to get the map with Id Group and GroupdMembers
*/ 
    public static Map<Id,List<RR_Member__c>> getMapGroupMembers(){
        
        Map<Id,List<RR_Member__c>> mapIdGroup_Members = new Map<Id,List<RR_Member__c>>();
        List<RR_Member__c> members = [SELECT Id, 
                                      Last_Lead_assignment__c,
                                      User__c,
                                      User__r.QueueId__c,
                                      RR_Group__c,
                                      SF_Queue_Id__c
                                      FROM RR_Member__c
                                      WHERE Status__c =: STATUS_ACTIVE
                                      AND User__c IN: ([SELECT Id FROM User WHERE IsActive = True])
                                      ORDER BY Last_assignment__c ASC
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
* @Method          :   findRangeassig
* @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
* @Created         :   3 April 2019
* @Description     :   Auxiliar method to find the range assigignment for a Lead 
*/ 
    public static RR_Postal_Code_Range_assigment__c findRangAssig(Lead iLead, List<RR_Postal_Code_Range_assigment__c> rangAssigList ){
        System.debug('***rangAssigList ' + rangAssigList);
        System.debug('***iLead ' + iLead);
        RR_Postal_Code_Range_assigment__c retRangeAssig;
        Boolean found = false;
        Integer i = 0;
        while (i < rangAssigList.size() && !found){
            if(iLead.NumberofDesks__c >= rangAssigList.get(i).Number_of_Desks_min__c 
               && iLead.NumberofDesks__c <= rangAssigList.get(i).Number_of_Desks_Max__c){
                   found = true;
                   retRangeAssig = rangAssigList.get(i);
               }else{
                   i++;
               }
        }
        System.debug('*****retRangeAssig ' + retRangeAssig);
        return retRangeAssig;
    }
    
    /*
* @Method          :   getMapGroupMembers
* @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
* @Created         :   3 April 2019
* @Description     :   Auxiliar function to get the map with Id Group and GroupdMembers
*/ 
    public static void assigignOwners(List<Lead> leads, List<RR_Member__c> members, Map<Id, Lead> mapMembersLeads){
        system.debug(leads);
        system.debug(members);
        
        system.debug(leads.size());
        system.debug(members.size());
        
        for(Integer i = 0; i < leads.size(); i++){
            
            system.debug(members.get(i));
            system.debug(members.get(i).SF_Queue_Id__c);
            system.debug(String.isNotBlank(members.get(i).SF_Queue_Id__c)); 
            
            if(String.isNotBlank(members.get(i).SF_Queue_Id__c)){
                leads.get(i).OwnerId = members.get(i).SF_Queue_Id__c;
            }else{
                leads.get(i).OwnerId = members.get(i).User__c;
            }
            System.debug('NEW OWNER '+ leads.get(i).OwnerId);
            leads.get(i).QueueId__c = (members.get(i).User__r.QueueId__c != null) ? members.get(i).User__r.QueueId__c : null;
            leads.get(i).RR_Group__c = members.get(i).RR_Group__c;
            mapMembersLeads.put(members.get(i).Id, leads.get(i));
            members.add(members.get(i)); // Put the current member at the end of the list to implement a circular list
        }
    }
    
    /*
* @Method          :   sendCallBack
* @Author          :   Juan Carlos Porras Blanco
* @Created         :   3 OCT 2019
* @Description     :   send callback request to Mitel with the right Queue and Agent.
*/ 
    public static void sendCallBack(List<Lead> leads){
        System.debug('Entered sendCallBack');
        List<MitelAPIConnector.MitelCallBackClass> callbackList = new List<MitelAPIConnector.MitelCallBackClass>();
        map<Id,String> userQueueIdMap = new map<Id,String>();
        
        //Process Leads list to serialize into callback wrapper list, then send to queueable process.     
        for(Lead recLead:leads){
            
            //We need the phone number, it is mandatory.
            if((recLead.Phone != null || recLead.MobilePhone != null) && recLead.Callmeback__c && recLead.QueueId__c != null){
                System.debug('Entered Mitel API Connector if statement');
                MitelAPIConnector.MitelCallBackClass newCallBack = new MitelAPIConnector.MitelCallBackClass();
                
                newCallBack.Name = recLead.FirstName + ' ' + recLead.LastName + ' [id=' + recLead.Id + ' type=Lead]';//Needs to be user name.This isfor the popup.
                newCallBack.CountryName = String.isNotBlank(recLead.Country)?recLead.Country:'';
                newCallBack.CallerPhoneNumber =  recLead.Phone != null ? recLead.Phone : recLead.MobilePhone;
                newCallBack.DestinationNumber = recLead.QueueId__c; //'0dcf0ba0-9503-49c8-b119-5aeea9262fa3'; //User Queue Id
                newCallBack.OutboundWorkflowId = 'F8C67FAC-31E8-4ACF-8D99-28129548BCD4'; //0465d5d1-a14f-4d83-8f2d-13afae4b63eb
                newCallBack.Type = '1';
                
                callbackList.add(newCallBack);
            }
        }
        
        //Send list to Queueable process
        WebAPIUtils.createMitelCallBack(callbackList);
        
        
    }
    /*
* @Method          :   GAAPiTracking
* @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
* @Created         :   30 Jul 2020
* @Description     :   AFTER INSERT ONLY - Call Google Analytics Queuable
*/ 
    public static void GAAPiTracking(Map<Id, Lead> mapNew,Map<Id, Lead> mapOld) {
        
        list<id> auxList = new list<id>();
        for (Lead lLead : mapNew.values()) {
            if (lLead.pi__conversion_object_name__c != null 
                && (mapOld == null ||lLead.pi__conversion_object_name__c != mapOld.get(lLead.id).pi__conversion_object_name__c
                   )) {
                       auxList.add(lLead.id);
                   }
        }
        
        if(!auxList.isEmpty()) {
            
            System.enqueueJob(new SendToGoogleAnalyticsQueueable(auxList,true,false,false));
            
        }
    }
    
    /*
* @Method          :   DCAPiTracking
* @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
* @Created         :   30 Jul 2020
* @Description     :   AFTER UPDATE - Call Google Analytics Queuable
*/ 
    public static void DCAPiTracking(Map<Id, Lead> mapNew,Map<Id, Lead> mapOld) {
        list<id> auxList = new list<id>();
        for (Lead lLead : mapNew.values()) {
            system.debug(lLead.Status);
            system.debug(mapOld.get(lLead.id).Status);
            if (lLead.Status == 'Qualified' && lLead.Status !=  mapOld.get(lLead.id).Status) {
                auxList.add(lLead.id);
            }
        }
        if (!auxList.isEmpty()) {
            System.enqueueJob(new SendToDoubleClickQueueable(auxList,true,false));
        }
    }
    /*
* @Method          :   checkIfGoogleAnalyticsCode
* @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
* @Created         :   30 Jul 2020
* @Description     :   Generates a GA code (GUID) for the manually created Lead, also set the GA type 
*/  
    public static void checkIfGoogleAnalyticsCode(list<Lead> listNews) {
        
        for(Lead lLead: listNews ) {
            
            if(lLead.GA_Client_ID__c == null ) {
                lLead.GA_Client_ID__c = GuidUtil.NewGuid();
                lLead.GA_Type__c = 'non-web'; 
                
            }else {
                lLead.GA_Type__c = 'web'; 
            }           
            
        } 
        
    }
    /*
* @Method          :   updateGATypeOnUpdate
* @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
* @Created         :   30 Jul 2020
* @Description     :   Generates a GA code (GUID) for the manually created Lead, also set the GA type 
*/  
    public static void updateGATypeOnUpdate(Map<Id, Lead> mapNew,Map<Id, Lead> mapOld) {
        
        for (Lead lLead : mapNew.values()) {
            if (lLead.pi__conversion_object_name__c != null 
                && lLead.pi__conversion_object_name__c != mapOld.get(lLead.id).pi__conversion_object_name__c ) {
                    lLead.GA_Type__c = 'web';       
                }
        }
        
    }
    
}