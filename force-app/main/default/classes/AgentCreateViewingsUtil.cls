global with sharing class AgentCreateViewingsUtil {
    //ViewingSchedule__c

    @AuraEnabled
    public static List<String> initBusinessCentresList(String recordsIdsJSON) {
        system.debug('Dentro initBusinessCentresList' + recordsIdsJSON);
        set<String> UniqueRecords = new Set<String>();

        List<String> IntroRecords = (List<String>) JSON.deserialize(
            recordsIdsJSON,
            List<String>.class
        );

        for (Introduction__c inRec : [
            SELECT BusinessCentre__c
            FROM Introduction__c
            WHERE Id IN :IntroRecords
        ]) {
            UniqueRecords.add(inRec.BusinessCentre__c);
        }

        system.debug('BCRecords' + UniqueRecords);

        return new List<String>(UniqueRecords);
    }

    @AuraEnabled
    public static String initReferencesIds(String recordsIdsJSON) {
        system.debug('Dentro initBusinessCentresList' + recordsIdsJSON);
        List<String> returnReference = new List<String>();

        List<String> IntroRecords = (List<String>) JSON.deserialize(
            recordsIdsJSON,
            List<String>.class
        );

        for (Introduction__c inRec : [
            SELECT BusinessCentre__c, Client__c, RelatedToDeal__c, Lead__c
            FROM Introduction__c
            WHERE Id IN :IntroRecords
            LIMIT 1
        ]) {
            returnReference.add(inRec.Client__c);
            returnReference.add(inRec.RelatedToDeal__c);
            returnReference.add(inRec.Lead__c);
        }

        system.debug('returnReference' + returnReference);

        return JSON.serialize(returnReference);
    }

    @AuraEnabled
    public static String createMapLink(String viewSchId, String dataJSON) {
        String origin = 'https://www.google.com/maps/dir/?api=1&origin=';
        String destination = '&destination=';
        String travelmode = '&travelmode=walking';
        String points = '&waypoints=';
        Integer size;

        if (String.isBlank(viewSchId)) {
            set<Id> bcSet = new Set<Id>();
            map<Id, Account> bcmap = new Map<Id, Account>();

            List<ViwwingModel> viewData = (List<ViwwingModel>) JSON.deserialize(
                dataJSON,
                List<ViwwingModel>.class
            );
            viewData.sort();

            //Create viewings Viewing__c
            for (ViwwingModel vm : viewData) {
                bcSet.add(vm.bcId);
            }

            for (Account acc : [
                SELECT Id, BillingLatitude, BillingLongitude
                FROM Account
                WHERE
                    Id IN :bcSet
                    AND BillingLatitude != NULL
                    AND BillingLongitude != NULL
            ]) {
                bcmap.put(acc.Id, acc);
            }

            for (Integer i = 0; i < viewData.size(); i++) {
                if (!bcmap.containskey(viewData[i].bcId)) {
                    viewData.remove(i);
                }
            }

            viewData.sort();

            size = viewData.size();

            if (size > 1) {
                origin =
                    origin +
                    String.valueof(
                        bcmap.get(viewData[0].bcId).BillingLatitude
                    ) +
                    ',' +
                    String.valueof(
                        bcmap.get(viewData[0].bcId).BillingLongitude
                    );
                destination =
                    destination +
                    String.valueof(
                        bcmap.get(viewData[size - 1].bcId).BillingLatitude
                    ) +
                    ',' +
                    String.valueof(
                        bcmap.get(viewData[size - 1].bcId).BillingLongitude
                    );
                if (size > 2) {
                    for (Integer i = 1; i < (size - 1); i++) {
                        points =
                            points +
                            String.valueof(
                                bcmap.get(viewData[i].bcId).BillingLatitude
                            ) +
                            ',' +
                            String.valueof(
                                bcmap.get(viewData[i].bcId).BillingLongitude
                            ) +
                            '%7C';
                    }
                }
            }
        } else {
            List<Viewing__c> viewingList = new List<Viewing__c>(
                [
                    SELECT
                        Id,
                        BusinessCentre__c,
                        BusinessCentre__r.BillingLatitude,
                        BusinessCentre__r.BillingLongitude
                    FROM Viewing__c
                    WHERE
                        ViewingSchedule__c = :viewSchId
                        AND BusinessCentre__c != NULL
                        AND BusinessCentre__r.BillingLatitude != NULL
                        AND BusinessCentre__r.BillingLongitude != NULL
                    ORDER BY SortOrder__c
                ]
            );

            size = viewingList.size();

            if (size > 1) {
                origin =
                    origin +
                    String.valueof(
                        viewingList[0].BusinessCentre__r.BillingLatitude
                    ) +
                    ',' +
                    String.valueof(
                        viewingList[0].BusinessCentre__r.BillingLongitude
                    );
                destination =
                    destination +
                    String.valueof(
                        viewingList[size - 1].BusinessCentre__r.BillingLatitude
                    ) +
                    ',' +
                    String.valueof(
                        viewingList[size - 1].BusinessCentre__r.BillingLongitude
                    );
                if (size > 2) {
                    for (Integer i = 1; i < (size - 1); i++) {
                        points =
                            points +
                            String.valueof(
                                viewingList[i].BusinessCentre__r.BillingLatitude
                            ) +
                            ',' +
                            String.valueof(
                                viewingList[i]
                                    .BusinessCentre__r.BillingLongitude
                            ) +
                            '%7C';
                    }
                }
            }
        }

        system.debug(origin + destination + travelmode + points);
        return origin + destination + travelmode + points;
    }

    @AuraEnabled
    public static String sendEmailViewingSchedule(String viewSchId) {
        //Create viewing Schedule
        ViewingSchedule__c newVSchedule;
        if (String.isNotBlank(viewSchId)) {
            newVSchedule = [
                SELECT
                    Id,
                    Send_to_customer__c,
                    ClientEmail__c,
                    Viewing_Email_Recipient__c
                FROM ViewingSchedule__c
                WHERE Id = :viewSchId
            ][0];
            system.debug('Email To send' + newVSchedule.ClientEmail__c);
            if (String.isNotBlank(newVSchedule.ClientEmail__c)) {
                newVSchedule.Viewing_Email_Recipient__c = newVSchedule.ClientEmail__c;
                newVSchedule.Send_to_customer__c = true;
                update newVSchedule;
            }
        } else {
            return 'KO';
        }

        return 'OK';
    }

    @AuraEnabled
    public static String saveViewingSCH(
        String clientId,
        String oppId,
        String leadId,
        String dataJSON,
        String dateValue,
        String emailText,
        String viewSchId
    ) {
        list<Viewing__c> viewLst = new List<Viewing__c>();
        Datetime dt = Datetime.valueof(dateValue + ' 12:00:00');

        List<ViwwingModel> viewData = (List<ViwwingModel>) JSON.deserialize(
            dataJSON,
            List<ViwwingModel>.class
        );

        //Create viewing Schedule
        ViewingSchedule__c newVSchedule;
        if (String.isNotBlank(viewSchId)) {
            newVSchedule = [
                SELECT
                    RelatedToDeal__c,
                    Lead__c,
                    Client__c,
                    Email_comments__c,
                    GoogleMapUrl__c,
                    Date__c,
                    Send_to_customer__c,
                    ClientEmail__c,
                    Viewing_Email_Recipient__c
                FROM ViewingSchedule__c
                WHERE Id = :viewSchId
            ][0];
            delete [
                SELECT Id
                FROM Viewing__c
                WHERE ViewingSchedule__c = :viewSchId
            ];
        } else {
            newVSchedule = new ViewingSchedule__c();
        }

        newVSchedule.RelatedToDeal__c = oppId;
        newVSchedule.Lead__c = leadId;

        newVSchedule.Client__c = clientId;
        
        newVSchedule.Email_comments__c = emailText;
        newVSchedule.GoogleMapUrl__c = AgentCreateViewingsUtil.createMapLink(
            null,
            dataJSON
        );
        newVSchedule.Date__c = Date.valueof(dateValue);
        newVSchedule.Viewing_Email_Recipient__c = newVSchedule.ClientEmail__c;

        /*if(String.isNotBlank(newVSchedule.ClientEmail__c)){
	    	
	    	newVSchedule.Send_to_customer__c = true;
	    }*/

        upsert newVSchedule;

        viewData.sort();

        //Create viewings Viewing__c
        for (ViwwingModel vm : viewData) {
            Viewing__c newView = new Viewing__c();

            newView.ViewingSchedule__c = newVSchedule.Id;

            newView.BusinessCentre__c = vm.bcId;
            newView.Contact__c = vm.managerId;

            newView.SortOrder__c = vm.order;
            newView.Status__c = 'Arranged';
            newView.AdditionalNotes__c = vm.notes;
            newView.ViewingDateTime__c = Datetime.valueof(
                dateValue +
                ' ' +
                vm.stime +
                ':00'
            );
            newView.Secondary_Contact__c = vm.secondaryContactId;
            viewLst.add(newView);
        }

        insert viewLst;

        system.debug('newVSchedule.Id' + newVSchedule.Id);

        return newVSchedule.Id;
    }

    @AuraEnabled
    public static list<String> getHeaderInfo(String viewSchId) {
        ViewingSchedule__c vs = [
            SELECT Email_comments__c, Date__c
            FROM ViewingSchedule__c
            WHERE Id = :viewSchId
        ][0];
        list<String> lstReturn = new List<String>();

        lstReturn.add(String.valueof(vs.Date__c));

        if (String.isNotBlank(vs.Email_comments__c)) {
            lstReturn.add(vs.Email_comments__c);
        } else {
            lstReturn.add('null');
        }

        return lstReturn;
    }

    @AuraEnabled
    public static list<ViwwingModel> getviewingLines(
        String accountIds,
        String orderJSON,
        String viewSchId
    ) {
        system.debug('Dentro getviewingLines' + accountIds);
        system.debug('Dentro orderJSON' + orderJSON);
        system.debug('viewSchId' + viewSchId);

        List<ViwwingModel> viewLst = new List<ViwwingModel>();
        List<String> accRecords = (List<String>) JSON.deserialize(
            accountIds,
            List<String>.class
        );

        system.debug('accRecords' + accRecords.size());

        if (accRecords.size() == 0 && String.isNotBlank(viewSchId)) {
            for (Viewing__c view : [
                SELECT
                    Id,
                    BusinessCentre__c,
                    BusinessCentre__r.Name,
                    BusinessCentre__r.BillingState,
                    BusinessCentre__r.BillingStreet,
                    BusinessCentre__r.BillingPostalCode,
                    BusinessCentre__r.CentreManager__c,
                    BusinessCentre__r.CentreManager__r.FirstName,
                    BusinessCentre__r.CentreManager__r.LastName,
                    BusinessCentre__r.CentreManager__r.Phone,
                    BusinessCentre__r.CentreManager__r.Email,
                    ViewingDateTime__c,
                    AdditionalNotes__c,
                    BusinessCentre__r.Secondary_Contact__r.FirstName,
                    BusinessCentre__r.Secondary_Contact__r.LastName,
                    BusinessCentre__r.Secondary_Contact__r.Phone,
                    BusinessCentre__r.Secondary_Contact__r.Email,
                    BusinessCentre__r.Secondary_Contact__c,
                    Secondary_Contact_Email__c,
                    SortOrder__c
                FROM Viewing__c
                WHERE ViewingSchedule__c = :viewSchId
                ORDER BY SortOrder__c
            ]) {
                ViwwingModel newRec = new ViwwingModel();
                newRec.order = Integer.valueOf(view.SortOrder__c);
                newRec.bcId = view.BusinessCentre__c;
                newRec.bcName = view.BusinessCentre__r.Name;
                newRec.managerId = view.BusinessCentre__r.CentreManager__c;
                newRec.manager = (view.BusinessCentre__r.CentreManager__c !=
                    null)
                    ? (view.BusinessCentre__r.CentreManager__r.FirstName !=
                          null)
                          ? view.BusinessCentre__r.CentreManager__r.FirstName
                          : '' +
                            ' ' +
                            view.BusinessCentre__r.CentreManager__r.LastName
                    : '';
                newRec.managerphone = view.BusinessCentre__r.CentreManager__r.Phone;
                newRec.vtime = view.ViewingDateTime__c;
                newRec.secondaryContact = view.BusinessCentre__r.Secondary_Contact__c;
                newRec.secondaryContactId = view.BusinessCentre__r.Secondary_Contact__c;
                newrec.secondaryContactEmail = view.BusinessCentre__r.Secondary_Contact__r.Email;
                newRec.stime = '05:00';
                newRec.manageremail = view.BusinessCentre__r.CentreManager__r.Email;
                newRec.address =
                    view.BusinessCentre__r.BillingStreet +
                    '-' +
                    view.BusinessCentre__r.BillingPostalCode;
                newRec.location = view.BusinessCentre__r.BillingState;
                newRec.notes = view.AdditionalNotes__c;
                newRec.viewingId = view.Id;

                viewLst.add(newRec);
            }
        } else {
            set<String> setAcc = new Set<String>(accRecords);

            map<String, ViwwingModel> ordermap = new Map<String, ViwwingModel>();

            if (String.isNotBlank(orderJSON)) {
                List<ViwwingModel> viewOrder = (List<ViwwingModel>) JSON.deserialize(
                    orderJSON,
                    List<ViwwingModel>.class
                );
                for (ViwwingModel vm : viewOrder) {
                    ordermap.put(vm.bcId, vm);
                }
            }

            list<Account> centresList = new List<Account>(
                [
                    SELECT
                        Id,
                        Name,
                        BillingCity,
                        BillingPostalCode,
                        BillingStreet,
                        BillingState,
                        CentreManager__c,
                        CentreManager__r.FirstName,
                        CentreManager__r.LastName,
                        CentreManager__r.Email,
                        CentreManager__r.Phone,
                        Secondary_Contact__c,
                        Secondary_Contact__r.FirstName,
                        Secondary_Contact__r.LastName,
                        Secondary_Contact__r.Email,
                        Secondary_Contact__r.Phone
                    FROM Account
                    WHERE Id IN :accRecords
                ]
            );

            Integer order = 1;
            Integer interval = 0;

            for (Account bcRec : centresList) {
                Datetime vtime = system.now().addMinutes(interval);
                ViwwingModel newRec = new ViwwingModel();
                newRec.order = ordermap.containskey(bcRec.Id)
                    ? ordermap.get(bcRec.Id).order
                    : order;
                newRec.bcId = bcRec.Id;
                newRec.bcName = (bcRec.Name != null) ? bcRec.Name : '';
                newRec.managerId = bcRec.CentreManager__c;
                newRec.manager = (bcRec.CentreManager__c != null)
                    ? (bcRec.CentreManager__r.FirstName != null)
                          ? bcRec.CentreManager__r.FirstName
                          : '' + ' ' + bcRec.CentreManager__r.LastName
                    : '';
                newRec.managerphone = bcRec.CentreManager__r.Phone;
                newRec.secondaryContact =
                    bcRec.Secondary_Contact__r.FirstName +
                    ' ' +
                    bcRec.Secondary_Contact__r.LastName;
                newRec.secondaryContactId = bcRec.Secondary_Contact__c;
                newRec.secondaryContactEmail = bcRec.Secondary_Contact__r.Email;
                newRec.vtime = vtime;
                newRec.stime = ordermap.containskey(bcRec.Id)
                    ? ordermap.get(bcRec.Id).stime
                    : vtime.format('HH:mm');
                newRec.manageremail = bcRec.CentreManager__r.Email;
                newRec.address =
                    bcRec.BillingStreet +
                    '-' +
                    bcRec.BillingPostalCode;
                newRec.location = bcRec.BillingState;
                newRec.notes = ordermap.containskey(bcRec.Id)
                    ? ordermap.get(bcRec.Id).notes
                    : '';
                newRec.viewingId = 'test';

                order++;
                interval = interval + 15;

                viewLst.add(newRec);
            }

            viewLst.sort();

            order = 0;
            if (centresList.size() != ordermap.size() && ordermap.size() > 0) {
                for (ViwwingModel vm : viewLst) {
                    if (ordermap.containskey(vm.bcId)) {
                        vm.order = order;
                        order++;
                    }
                }
            }
        }

        system.debug('viewLst' + viewLst);
        return viewLst;
    }

    // @AuraEnabled
    // public static void updateContactRow (String contactId, String centerId) {

    // 		Account centerToUpdate = [SELECT CentreManager__c, Secondary_Contact__c, Id FROM account WHERE Id = :centerId][0];

    // 		centerToUpdate.Secondary_Contact__c = contactId;

    // 		update centerToUpdate;

    // }

    @AuraEnabled
    public static void updateContactRow(String contactId, String viewingId) {
        Viewing__c viewingToUpdate = [
            SELECT Secondary_Contact__c, Id
            FROM Viewing__c
            WHERE Id = :viewingId
        ];
        viewingToUpdate.Secondary_Contact__c = contactId;
        update viewingToUpdate;
    }

    @AuraEnabled
    public static string getContactName(String contactId) {
        Contact con = [SELECT Name FROM Contact WHERE Id = :contactId];
        return con.Name;
    }

    public class ViwwingModel implements Comparable {
        @AuraEnabled
        public Integer order { get; set; }

        @AuraEnabled
        public String sid { get; set; }

        @AuraEnabled
        public String bcId { get; set; }

        @AuraEnabled
        public String bcName { get; set; }

        @AuraEnabled
        public DateTime vtime { get; set; }

        @AuraEnabled
        public String stime { get; set; }

        @AuraEnabled
        public String managerId { get; set; }

        @AuraEnabled
        public String manager { get; set; }

        @AuraEnabled
        public String managerphone { get; set; }

        @AuraEnabled
        public String manageremail { get; set; }

        @AuraEnabled
        public string secondaryContact { get; set; }

        @AuraEnabled
        public string secondaryContactId { get; set; }

        @AuraEnabled
        public string secondaryContactEmail { get; set; }

        @AuraEnabled
        public String address { get; set; }

        @AuraEnabled
        public String location { get; set; }

        @AuraEnabled
        public String notes { get; set; }

        @AuraEnabled
        public String viewingId { get; set; }

        public ViwwingModel() {
            this.order = null;
            this.sid = null;
            this.bcId = null;
            this.bcName = null;
            this.vtime = null;
            this.stime = null;
            this.managerId = null;
            this.manager = null;
            this.managerphone = null;
            this.manageremail = null;
            this.secondaryContactEmail = null;
            this.secondaryContact = null;
            this.address = null;
            this.location = null;
            this.notes = null;
            this.viewingId = null;
        }

        public Integer compareTo(Object compareTo) {
            ViwwingModel compareToEmp = (ViwwingModel) compareTo;
            if (order == compareToEmp.order)
                return 0;
            if (order > compareToEmp.order)
                return 1;
            return -1;
        }
    }
}