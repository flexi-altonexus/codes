/*
 *   @Class          :   IntroductionHelper
 *
 *   @Author         :   James Boutel <james.boutel@empaua.com>
 *   @Created        :   29 August 2019
 *   @Description    :   Class to set Automatic Intros based on Business Hours and match new Introductions to Contacts or Leads
 *
 *   Modification Log
 *   --------------------------------------------------------------------------------------
 *   #       Developer                           Date                    Description
 *   --------------------------------------------------------------------------------------
 *   1       James Boutel                    29 August 2019              Creation
 *
 */
public class IntroductionHelper {
    public static DateTime now {
        get {
            return now == null ? DateTime.now() : now;
        }
        set;
    }
    public static Boolean doNotRunAmberJones = false;
    private final static String AMBERJONESRRGROUPNAME = label.Amber_Jones_Group_Name;
    private final static String KATEJONESRRGROUPNAME = label.Kate_Jones_Group_Name;

    private final static integer SECONDSBACKTOFINDEXISTINGINTROS = integer.valueOf(
        label.Time_in_seconds_to_look_for_Duplicate_intros
    );
    /*
     * @method      : setAutomaticIntros()
     * @description : Method to set intros to Automatic or Manual based on Business Hours
     * @return      : void
     * @params      : List of Introductions
     */
    public static void setAutomaticIntros(List<Introduction__c> newlist) {
        for (Introduction__c i : newlist) {
            if (i.IntroductionType__c == null || i.IntroductionType__c == '') {
                i.IntroductionType__c = 'Automatic';
            }
        }
        /*
        map<String,BusinessHours> countryBHMap = new  map<String,BusinessHours>();

        for(Introduction__c i : newlist){
            if(i.CountryID__c != null){
                countryBHMap.put(String.valueof(i.CountryID__c),null);
            }
        }

        for(BusinessHours bh : [SELECT Id,Name FROM BusinessHours WHERE Name IN:countryBHMap.keyset() OR IsDefault=TRUE]){
            countryBHMap.put(bh.Name,bh);
        }
        //BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name IN:countryBHMap.keyset() OR IsDefault=TRUE];
        BusinessHours handleBusinessHours;
       
        for(Introduction__c i : newlist){

            if(i.CountryID__c != null 
                && countryBHMap.containskey(String.valueOf(i.CountryID__c)) 
                && countryBHMap.get(String.valueOf(i.CountryID__c)) != null){
                    handleBusinessHours = countryBHMap.get(String.valueOf(i.CountryID__c));
                   
            }else{
                handleBusinessHours = countryBHMap.get('Default');
                
            }

            if(BusinessHours.isWithin(handleBusinessHours.id, now) && i.IntroductionType__c == NULL){
                i.IntroductionType__c = 'Manual';
                
            } 
            else if(!BusinessHours.isWithin(handleBusinessHours.id,now) && i.IntroductionType__c == NULL){
                i.IntroductionType__c = 'Automatic';
               
            }
        } 
        */
    }

    /*
     * @method      : setCountryId()
     * @description : Method to set the CountryId based on metadata type Mapping & Master Key to avoid duplicates
     * @return      : void
     * @params      : List of Introductions
     */
    public static void setInformationBefore(List<Introduction__c> newlist) {
        //Get Metedata
        map<Integer, String> countryIdMap = WebAPIUtils.getCountryIdMap();
        Integer CountryIDRef;
        for (Introduction__c i : newlist) {
            CountryIDRef = Integer.valueof(i.CountryID__c);

            if (
                i.CountryID__c != null &&
                countryIdMap.containskey(CountryIDRef) &&
                countryIdMap.get(CountryIDRef) != null
            ) {
                i.Country__c = countryIdMap.get(CountryIDRef);
            }

            //TODO Txesco ON PRO run script to inform Master_Key__c
            if (String.isnotblank(i.Email__c) && String.isnotblank(i.BusinessCentre__c)) {
                i.Master_Key__c = i.Email__c + '-' + i.BusinessCentre__c;
            }
        }
    }

    /*
     * @method      : identifyIncommingDuplicates()
     * @description : Identofy if an introduction is duplicated or not
     * @return      : void
     * @params      : List of Introductions
     */
    public static void identifyIncommingDuplicates(List<Introduction__c> newlist) {
        set<String> set_uniqueKeyIntros = new Set<String>();
        List<Introduction__c> list_introsToPrevProcess = new List<Introduction__c>();
        map<String, String> existingIntrosMap = new Map<String, String>();

        //Mark duplicates based on records coming into the same request

        String masterkey;
        for (Introduction__c iIntro : newlist) {
            if (String.isNotBlank(iIntro.Email__c) && String.isNotBlank(iIntro.BusinessCentre__c)) {
                masterkey = iIntro.Email__c + '-' + iIntro.BusinessCentre__c;

                if (!set_uniqueKeyIntros.contains(masterkey)) {
                    set_uniqueKeyIntros.add(masterkey);
                    list_introsToPrevProcess.add(iIntro);
                } else {
                    iIntro.IsDuplicate__c = true;
                    iIntro.Duplicate_Issue__c =
                        'Duplicate into the same request on this key:' + masterkey;
                }
            }
        }

        //Query Existing Intro

        DateTime CreatedOn = datetime.now().addseconds(-SECONDSBACKTOFINDEXISTINGINTROS);
        system.debug(SECONDSBACKTOFINDEXISTINGINTROS);
        system.debug(CreatedOn);
        // FOR TESTING PURPOSE
        //  CreatedOn = datetime.now().addseconds(-1);

        for (Introduction__c iIntro : [
            SELECT Id, Master_Key__c, CreatedDate
            FROM Introduction__c
            WHERE Master_Key__c IN :set_uniqueKeyIntros AND CreatedDate > :CreatedOn
        ]) {
            existingIntrosMap.put(iIntro.Master_Key__c, iIntro.Id);
        }

        //Create set of Emails from incoming Introductions and mark duplicates based on existing records

        for (Introduction__c iIntro : list_introsToPrevProcess) {
            masterkey = iIntro.Email__c + '-' + iIntro.BusinessCentre__c;

            if (existingIntrosMap.containskey(masterkey)) {
                iIntro.IsDuplicate__c = true;
                iIntro.Duplicate_Issue__c =
                    'Duplicate with existing Record:' + existingIntrosMap.get(masterkey);
            }
        }

        ////////////////////////////////////
        //END     DUPLICATION PROCESS
        ///////////////////////////////////
    }

    /*
     * @method      : assingIntroductionsToLeadOrOpp()
     * @description : Method to find matching Leads or Contacts of an Intro, based on the email. Creates new Lead if none found.
     * @return      : void
     * @params      : List of Introductions
     */
    public static void assingIntroductionsToLeadOrOpp(List<Introduction__c> newlist) {
        Set<String> emailsSet = new Set<String>();
        Set<Id> contactsSet = new Set<Id>();

        list<Lead> leadsToUpdate = new List<Lead>();
        map<String, Lead> map_emailToLead = new Map<String, Lead>();
        map<String, Contact> map_email_ExistingContact = new Map<String, Contact>();
        map<Id, Id> map_contactToOpp = new Map<Id, Id>();
        map<Id, Opportunity> map_ContactId_NewOpportunity = new Map<Id, Opportunity>();
        map<String, Lead> map_Email_NewLead = new Map<String, Lead>();
        Map<Id, Id> map_Contact2Account = new Map<Id, Id>();
        Map<Id, Id> map_Account2Opportunity = new Map<Id, Id>();

        List<Introduction__c> list_introsToProcess = new List<Introduction__c>();

        map<string, RR_Postal_Code_Range_Assigment__c> map_AmberJonesPostalcodes_RRPCRA = new Map<string, RR_Postal_Code_Range_Assigment__c>();
        set<string> setPostalCodes = new Set<string>();

        //Set to control we only send 1 email to the customer, also if they have more than 1 intro.
        set<String> uniqueSetEmailAlerts = new Set<String>();

        //Get Amber Jones ID
        Id amberJonesId = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = 'Amber_Jones' AND Type = 'Queue'
        ]
        .Id;

        //Get Kate Jones ID
        Id kateJonesId = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = 'Kate_Jones' AND Type = 'Queue'
        ]
        .Id;

        // TRACKING LOGS
        Introductions_Log__c introLog = new Introductions_Log__c();
        introLog.Body_Before__c = Json.serialize(newlist);

        for (Introduction__c lIntro : newlist) {
            if (
                lIntro.Email__c != null &&
                lIntro.NumberOfDesks__c != null &&
                lIntro.Contact__c == null &&
                lIntro.RelatedToDeal__c == null &&
                lIntro.Client__c == null &&
                lIntro.Lead__c == null &&
                !lIntro.IsDuplicate__c
            ) {
                list_introsToProcess.add(lIntro);
                emailsSet.add(lIntro.Email__c);
                setPostalCodes.add(lIntro.OutwardCode__c);
            }
        }
        if (!list_introsToProcess.isEmpty()) {
            ////////////////////////////////////
            //START PROCESS
            ///////////////////////////////////

            //1. Try to Find a Lead

            //Get leads from emails not converted
            for (Lead lRecord : [
                SELECT
                    Id,
                    OwnerId,
                    Callmeback__c,
                    AmberJones__c,
                    FirstName,
                    Phone,
                    MobilePhone,
                    QueueId__c,
                    LastName,
                    Email,
                    Location__c,
                    RR_Group__c
                FROM Lead
                WHERE Email IN :emailsSet AND IsConverted = FALSE
            ]) {
                map_emailToLead.put(lRecord.Email, lRecord);
            }

            //2. Review if we have emails without maching to look into Contacts - Try to find Contacts
            if (emailsSet.size() > map_emailToLead.size()) {
                //Get Contacts from Emails
                for (Contact cRecord : [
                    SELECT
                        Id,
                        FirstName,
                        LastName,
                        Email,
                        AccountId,
                        Account.OwnerId,
                        Account.Owner.QueueId__c,
                        Account.ShippingCountry,
                        Account.Name
                    FROM Contact
                    WHERE Email IN :emailsSet
                ]) {
                    contactsSet.add(cRecord.Id);
                    map_email_ExistingContact.put(cRecord.Email, cRecord);
                    map_Contact2Account.put(cRecord.Id, cRecord.AccountId);
                }
                //Get Opp for Contacts //StageName != 'Closed Won' - Closed Lost - Qualified
                if (!contactsSet.isEmpty()) {
                    for (Opportunity opp : [
                        SELECT Id, ContactId, AccountId
                        FROM Opportunity
                        WHERE
                            IsClosed = FALSE
                            AND (ContactId IN :contactsSet
                            OR AccountId IN :map_Contact2Account.values())
                        ORDER BY CreatedDate ASC
                    ]) {
                        map_contactToOpp.put(opp.ContactId, opp.Id);
                        map_Account2Opportunity.put(opp.AccountId, opp.Id);
                    }
                }
            }
            /* TODO FOR JC This SHOULD BE A SEPPARATE FUNCTION, an AmberJones Intro does not depend on the Lead/opp but on his OutwardCode__c*/

            // Get map for Amber Jones assignment
            map_AmberJonesPostalcodes_RRPCRA = getAmberJonesPostalCodes(setPostalCodes);
            System.debug(map_AmberJonesPostalcodes_RRPCRA);
            //3 Loop intros - Match with  Lead / Match with Contact and Opp/ Not Matching
            Set<String> set_EmailAddresAlreadyUsedForSendToCustomer = new Set<String>();
            for (Introduction__c iIntro : list_introsToProcess) {
                iIntro.Amber_Jones_Intro_Email__c = (map_AmberJonesPostalcodes_RRPCRA.containsKey(
                        iIntro.OutwardCode__c
                    ) &&
                    iIntro.NumberofDesks__c >=
                    map_AmberJonesPostalcodes_RRPCRA.get(iIntro.OutwardCode__c)
                        .Number_of_Desks_min__c &&
                    iIntro.NumberofDesks__c <=
                    map_AmberJonesPostalcodes_RRPCRA.get(iIntro.OutwardCode__c)
                        .Number_of_Desks_Max__c)
                    ? true
                    : false;
                /*SECTION 5 MOVED here To Set Email Fields, Based on iIntro.Amber_Jones_Intro_Email__c*/

                // ONLY SEND THE EMAIL TO THE COUSTOMER ONCE - M
                // Moved out of Automatic while testing with Jess
                if (!set_EmailAddresAlreadyUsedForSendToCustomer.contains(iIntro.Email__c)) {
                    iIntro.Send_to_Customer__c = true;
                    set_EmailAddresAlreadyUsedForSendToCustomer.add(iIntro.Email__c);
                } else if (!iIntro.Amber_Jones_Intro_Email__c) {
                    iIntro.Re_Send_Email_to_Customer__c = true;
                }
                if (iIntro.Amber_Jones_Intro_Email__c) {
                    iIntro.Send_to_Customer__c = false;
                }
                /* END TODO FOR JC This SHOULD BE A SEPPARATE FUNCTION*/

                /* FIX UNTIL PB IS FIXED*/
                if (!iIntro.Amber_Jones_Intro_Email__c && iIntro.IntroductionType__c == 'Manual') {
                    iIntro.Send_to_Customer__c = false;
                    iIntro.Send_to_BC__c = false;
                } else if (!iIntro.Amber_Jones_Intro_Email__c) {
                    iIntro.Send_to_BC__c = true;
                }
                /*END FIX*/

                //3.1 Matching Relation
                if (map_emailToLead.containskey(iIntro.Email__c)) {
                    //ASSIGN LEAD AND SET AMBER JONES CHECKBOX
                    iIntro.Lead__c = map_emailToLead.get(iIntro.Email__c).Id;
                    iIntro.IsExistingLead__c = true;

                    //Review Location on Lead - upadte on lead if we need.
                    if (
                        map_emailToLead.get(iIntro.Email__c).Location__c == null &&
                        iIntro.OutwardCode__c != null
                    ) {
                        map_emailToLead.get(iIntro.Email__c).Location__c = iIntro.OutwardCode__c;
                        leadsToUpdate.add(map_emailToLead.get(iIntro.Email__c));
                    }
                } else if (map_email_ExistingContact.containskey(iIntro.Email__c)) {
                    //Set Contact / Client / Opp
                    iIntro.Client__c = map_email_ExistingContact.get(iIntro.Email__c).AccountId;
                    iIntro.Contact__c = map_email_ExistingContact.get(iIntro.Email__c).Id;

                    if (map_contactToOpp.containsKey(iIntro.Contact__c)) {
                        iIntro.RelatedToDeal__c = map_contactToOpp.get(iIntro.Contact__c);
                        iIntro.With_Existing_Opp__c = true;
                    } else if (
                        map_Contact2Account.containsKey(iIntro.Contact__c) &&
                        map_Account2Opportunity.containsKey(
                            map_Contact2Account.get(iIntro.Contact__c)
                        )
                    ) {
                        iIntro.RelatedToDeal__c = map_Account2Opportunity.get(
                            map_Contact2Account.get(iIntro.Contact__c)
                        );
                        iIntro.With_Existing_Opp__c = true;
                    } else {
                        //Create New Opp
                        if (!map_ContactId_NewOpportunity.containsKey(iIntro.Contact__c)) {
                            Opportunity newOpp = new Opportunity();
                            newOpp.OwnerId = map_email_ExistingContact.get(iIntro.Email__c)
                                .Account.OwnerId;
                            newOpp.Name =
                                map_email_ExistingContact.get(iIntro.Email__c).Account.Name +
                                ' - New Deal';
                            newOpp.ClientName__c = map_email_ExistingContact.get(iIntro.Email__c)
                                .Id;
                            newOpp.AccountId = map_email_ExistingContact.get(iIntro.Email__c)
                                .AccountId;
                            newOpp.QueueIdText__c = map_email_ExistingContact.get(iIntro.Email__c)
                                .Account.Owner.QueueId__c;
                            newOpp.NumberOfDesks__c = iIntro.NumberOfDesks__c;
                            newOpp.StageName = 'Qualified';
                            newOpp.Location__c = iIntro.OutwardCode__c;
                            newOpp.CloseDate = Date.TODAY() + 30;
                            newOpp.AccountCountry__c = map_email_ExistingContact.get(
                                    iIntro.Email__c
                                )
                                .Account.ShippingCountry;
                            newOpp.ContactId = iIntro.Contact__c;

                            //Add to the map to avoid new opp creation
                            //map_contactToOpp.put(map_email_ExistingContact.get(iIntro.Email__c).Id, opp.Id));

                            //Add to the map to Insert
                            map_ContactId_NewOpportunity.put(iIntro.Contact__c, newOpp);
                        }
                    }
                } else {
                    //Create new Lead - if the lead is already on the map for creation don´t do anything.
                    if (!map_Email_NewLead.containsKey(iIntro.Email__c)) {
                        Lead leadRec = new Lead();
                        leadRec.FirstName = iIntro.FirstName__c;
                        leadRec.LastName = iIntro.LastName__c;
                        leadRec.Company = iIntro.Company__c;
                        leadRec.NumberofDesks__c = iIntro.NumberofDesks__c;
                        leadRec.Email = iIntro.Email__c;
                        leadRec.Phone = iIntro.Phone__c;
                        leadRec.Location__c = iIntro.OutwardCode__c;
                     //   leadRec.LeadSource = 'Web';
                        leadRec.Country = iIntro.Country__c;
                        leadRec.Callmeback__c = true;
                        // SET THIS TO GET THE ACTUAL VALUE ONCE THE RECORD IS INSERTED
                        if(iIntro.NumberofDesks__c == -1 || iIntro.NumberofDesks__c == -2) {
                            leadRec.ownerid = amberJonesId;
                            if(iIntro.Country__c == 'AU') {
                                leadRec.ownerid = kateJonesId;
                            }
                        } else {
                            leadRec.ownerid = UserInfo.getUserId();
                        }

                        //add to the map to insert later
                        map_Email_NewLead.put(iIntro.Email__c, leadRec);
                    }
                }
            }

            //3 INSERT OPP AND NEW LEADS
            if (map_ContactId_NewOpportunity.size() > 0) {
                insert map_ContactId_NewOpportunity.values();
            }
            if (map_Email_NewLead.size() > 0) {
                // TODO , CHECK IF THE OWNER IS UPDATED

                insert map_Email_NewLead.values();
            }
            if (leadsToUpdate.size() > 0) {
                update leadsToUpdate;
            }

            //Get Final Leads & Opps Merge.. existing and new records

            //4 Loop again to match Ids after insert

            for (Introduction__c iIntro : list_introsToProcess) {
                //Assigned inserted Opp
                if (
                    map_email_ExistingContact.containskey(iIntro.Email__c) &&
                    map_ContactId_NewOpportunity.containsKey(
                        map_email_ExistingContact.get(iIntro.Email__c).Id
                    )
                ) {
                    iIntro.RelatedToDeal__c = map_ContactId_NewOpportunity.get(
                            map_email_ExistingContact.get(iIntro.Email__c).Id
                        )
                        .Id;
                }

                //Assigned inserted Lead
                if (
                    !map_email_ExistingContact.containskey(iIntro.Email__c) &&
                    map_Email_NewLead.containskey(iIntro.Email__c)
                ) {
                    iIntro.Lead__c = map_Email_NewLead.get(iIntro.Email__c).Id;
                }
            }
        }

        introLog.Body_After__c = Json.serialize(newlist);

        if (
            [SELECT id, Track_intros__c FROM User WHERE id = :System.UserInfo.getUSerId()]
            .Track_intros__c
        ) {
            insert introLog;
        }

        //6 Send To MITEL
        //TODO el codigo actual solo lo hace en las insertadas - Owner del cliente - sera el owner de las Opp.. y por tanto quien tiene que recibir el callmeback
        //sendMitelCallback(oppToIntro);
    }
    /*
     * @method      : setEmailFieldsIfAJWithRelatedDeal
     * @description : if it's An AJ and it's assigned to an Opp, it must not eneter the AmberJonesIntrosByDistanceQueueable, so we must set the email fields here
     * @return      : void
     * @params      : List of Introductions
     */
    public static void setEmailFieldsIfAJWithRelatedDeal(List<Introduction__c> newlist) {
        set<Id> introIds = new Set<Id>();

        for (Introduction__c lIntro : newlist) {
            if (lIntro.RelatedToDeal__c != null && lIntro.Amber_Jones_Intro_Email__c == true) {
                lIntro.Send_to_Customer__c = true;
                lIntro.Send_to_BC__c = true;
            }
        }
    }

    /*
     * @method      : callAmberJonesIntrosByDistanceQueueable()
     * @description : check if the introduction must be send to the queable class AmberJonesIntrosByDistanceQueueable
     * @return      : void
     * @params      : List of Introductions
     */
    public static void callAmberJonesIntrosByDistanceQueueable(List<Introduction__c> newlist) {
        if (!doNotRunAmberJones) {
            set<Id> introIds = new Set<Id>();

            for (Introduction__c lIntro : newlist) {
                if (
                    lIntro.Lead__c != null &&
                    lIntro.RelatedToDeal__c == null &&
                    lIntro.Amber_Jones_Intro_Email__c == true
                ) {
                    introIds.add(lIntro.Id);
                }
            }

            if (!introIds.isEmpty()) {
                System.enqueueJob(new AmberJonesIntrosByDistanceQueueable(introIds));
            }
        }
    }

    /*
     * @method      : sendMitelCallback()
     * @description : Method to send Mitel Callback based on Info from Opportunity and Introduction
     * @return      : void
     * @params      : Map of Opportunity to Introduction
     */
    public static void sendMitelCallback(Map<Opportunity, Introduction__c> oppToIntro) {
        List<MitelAPIConnector.MitelCallBackClass> callbackList = new List<MitelAPIConnector.MitelCallBackClass>();

        for (Opportunity o : oppToIntro.keyset()) {
            if (
                oppToIntro.get(o).Phone__c != null &&
                o.QueueIdText__c != null &&
                o.AccountCountry__c != null
            ) {
                MitelAPIConnector.MitelCallBackClass newCallBack = new MitelAPIConnector.MitelCallBackClass();

                newCallBack.Name =
                    oppToIntro.get(o).FirstName__c +
                    ' ' +
                    oppToIntro.get(o).LastName__c +
                    ' [id=' +
                    o.Id +
                    ' type=Opportunity]'; //Needs to be user name.This isfor the popup.
                newCallBack.CountryName = o.AccountCountry__c;
                newCallBack.CallerPhoneNumber = oppToIntro.get(o).Phone__c;
                newCallBack.DestinationNumber = o.QueueIdText__c; //'0dcf0ba0-9503-49c8-b119-5aeea9262fa3'; //User Queue Id
                newCallBack.OutboundWorkflowId = 'F8C67FAC-31E8-4ACF-8D99-28129548BCD4'; //0465d5d1-a14f-4d83-8f2d-13afae4b63eb
                newCallBack.Type = '1';

                callbackList.add(newCallBack);
            }
        }

        //Send list to Queueable process
        WebAPIUtils.createMitelCallBack(callbackList);
    }

    /*
     * @Method          :   IsOpportunityAmberJones
     * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
     * @Created         :   3 April 2019
     * @Description     :   Method to do the round robin Lead assigignment
     */
    private static map<string, RR_Postal_Code_Range_Assigment__c> getAmberJonesPostalCodes(
        set<string> set_postalCodes
    ) {
        map<string, RR_Postal_Code_Range_Assigment__c> map_AmberJonesPostalCode_RRPostalCodeRangeAssigment = new Map<string, RR_Postal_Code_Range_Assigment__c>();

        for (RR_Postal_Code_Range_assigment__c lRRPCRA : [
            SELECT RR_Postal_Code__r.Postal_Code__c, Number_of_Desks_min__c, Number_of_Desks_Max__c
            FROM RR_Postal_Code_Range_assigment__c
            WHERE
                (RR_Group__r.name = :AMBERJONESRRGROUPNAME
                OR RR_Group__r.name = :KATEJONESRRGROUPNAME)
                AND RR_Postal_Code__r.Postal_Code__c IN :set_postalCodes
        ]) {
            map_AmberJonesPostalCode_RRPostalCodeRangeAssigment.put(
                lRRPCRA.RR_Postal_Code__r.Postal_Code__c,
                lRRPCRA
            );
        }
        return map_AmberJonesPostalCode_RRPostalCodeRangeAssigment;
    }
}