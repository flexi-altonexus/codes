public class AmberJonesIntrosByDistanceQueueable implements Queueable {
    
    private set<id> set_idIntros;
    private final Id AJ_QUEUE_ID = [SELECT Id FROM Group WHERE DeveloperName = 'Amber_Jones' AND Type ='Queue'].Id;
    private final integer RANGE_IN_MILES = integer.valueof(label.Introductions_Range_to_Search_In_Miles);
    private final integer INRANGEINTROS = integer.valueof(label.Introductions_number_of_Complementary_intros);

    public AmberJonesIntrosByDistanceQueueable(set<Id> introIds) {
        this.set_idIntros = introIds;
    }
    public void execute(QueueableContext context) {
        IntroductionHelper.doNotRunAmberJones = true;
        map<id,Introduction__c> map_id_Introductions = new map<id,Introduction__c> ();
        list<Introduction__c> lst_introsNoQueue = new List<Introduction__c>();
        list<Introduction__c> lst_introWithinRange = new List<Introduction__c>();
        for(Introduction__c qIntro :[SELECT Id, 
                                            Re_Send_Email_to_Customer__c, 
                                            Send_To_Customer__c, 
                                            Send_To_BC__c, 
                                            Lead__r.OwnerId, 
                                            Lead__c,
                                            LeadEmail__c,
                                            Lead__r.Email, 
                                            CountryID__c,
                                            Country__c,
                                            Amber_Jones_Intro_Email__c,
                                            IntroductionType__c,
                                            NumberofDesks__c,
                                            OutwardCode__c,
                                            Prime_Location__c,
                                            BusinessCentre__c, 
                                            BusinessCentre__r.BillingAddress,
                                            BusinessCentre__r.BillingLatitude, 
                                            BusinessCentre__r.BillingLongitude 
                                            FROM Introduction__c 
                                            WHERE Id IN: set_idIntros
                                            LIMIT :set_idIntros.size()]) {
            if (qIntro.Lead__r.OwnerId == AJ_QUEUE_ID) {
                map_id_Introductions.put(qIntro.id,qIntro);
            } else {
                set_idIntros.remove(qIntro.id);
                qIntro.Send_to_Customer__c = true;
                qIntro.Send_to_BC__c = true;
                lst_introsNoQueue.add(qIntro);
            }
        }
        
        if (!map_id_Introductions.isEmpty()){
            Introduction__c mainIntro;
            set<id> set_id_IntrosWithinRange = new set<id>();
            set<id> set_businessCenterId_IntrosWithinRange = new set<id>();

            for (id lIntroId : map_id_Introductions.keyset()) {
                if (mainIntro == null) {
                    // SET FIRST INTRO AS PRIMARY FOR EMAIL Send_to_Customer__c = true
                    mainIntro =  map_id_Introductions.get(lIntroId);
                    mainIntro.Send_to_Customer__c = true;
                    mainIntro.Send_to_BC__c = true;
                    set_idIntros.remove(mainIntro.id);
                } else {
                    if (mainIntro.Lead__c == map_id_Introductions.get(lIntroId).Lead__c
                        && Location.getDistance(mainIntro.BusinessCentre__r.BillingAddress, map_id_Introductions.get(lIntroId).BusinessCentre__r.BillingAddress,'mi') < RANGE_IN_MILES) {
                            set_id_IntrosWithinRange.add(lIntroId);                  
                            set_businessCenterId_IntrosWithinRange.add(map_id_Introductions.get(lIntroId).BusinessCentre__c);                  
                            map_id_Introductions.get(lIntroId).Re_Send_Email_to_Customer__c = true;
                            map_id_Introductions.get(lIntroId).Send_to_BC__c = true;
                            map_id_Introductions.get(lIntroId).Send_to_Customer__c = false;
                            lst_introWithinRange.add(map_id_Introductions.get(lIntroId));
                    }
                }
            }

            if(!set_id_IntrosWithinRange.isEmpty()) {
                set_idIntros.removeAll(set_id_IntrosWithinRange);
            }

            List<Introduction__c> lstIntrosToInsert = new list<Introduction__c>();
            if (lst_introWithinRange.size() < INRANGEINTROS) {
                integer queryLImit = INRANGEINTROS-lst_introWithinRange.size();
                list<Account> lst_AccInRange = new list<Account>([SELECT Id FROM Account 
                                                    WHERE RecordtypeId = :AccountHelper.BUSINESS_CENTRE_RT 
                                                    AND Status__c =:AccountHelper.APPROVED_STATUS 
                                                    AND DISTANCE(BillingAddress,:mainIntro.BusinessCentre__r.BillingAddress, 'mi') < :RANGE_IN_MILES 
                                                    AND Id NOT IN: set_businessCenterId_IntrosWithinRange
                                                    AND id != :mainIntro.BusinessCentre__c
                                                    AND Introduction_Manager_Email__c != null
                                                    ORDER BY DISTANCE(BillingAddress,:mainIntro.BusinessCentre__r.BillingAddress, 'mi')
                                                    LIMIT :queryLimit 
                                                    ]);
                if(lst_AccInRange != null) {
                    lstIntrosToInsert.addAll(createNewIntros(mainIntro,lst_AccInRange));
                  //  lst_introWithinRange.addAll(createNewIntros(mainIntro,lst_AccInRange));
                }
            }

            if(!lstIntrosToInsert.isEmpty()) {
                insert lstIntrosToInsert;
                for (Introduction__c intro : lstIntrosToInsert) {
                    intro.Re_Send_Email_to_Customer__c = true;
                    intro.Send_to_BC__c = true;
                    lst_introWithinRange.add(intro);
                }
            }
            lst_introWithinRange.add(mainIntro);             
        }

        if (!lst_introsNoQueue.isEmpty()) {
            lst_introWithinRange.addall(lst_introsNoQueue);
        }
        if (!lst_introWithinRange.isEmpty()) {
            update lst_introWithinRange;
        }
        if (!set_idIntros.isEmpty()) {
            System.enqueueJob(new AmberJonesIntrosByDistanceQueueable(set_idIntros));
        }
    }

    private static list<Introduction__c> createNewIntros(Introduction__c mainIntro,list<Account> accountList){
        list<Introduction__c> returnlist = new  list<Introduction__c>();
        
        for (Account acc:accountList) {
            if(acc.Id != mainIntro.BusinessCentre__c){
                Introduction__c newRec = new Introduction__c();
                newRec.BusinessCentre__c = acc.Id;
                newRec.Lead__c = mainIntro.Lead__c;
                newRec.CountryID__c =  mainIntro.CountryID__c;
                newRec.Country__c =  mainIntro.Country__c;
                newRec.Status__c = 'New';
                newRec.LeadEmail__c = mainIntro.LeadEmail__c;
                newRec.IntroductionType__c = mainIntro.IntroductionType__c;
                newRec.Send_to_BC__c = false;
                newRec.Send_to_customer__c = false;
                newRec.Re_Send_Email_to_Customer__c = false;
                newRec.IntroductionType__c = mainIntro.IntroductionType__c;
                newRec.Prime_Location__c = mainIntro.Prime_Location__c;
                newRec.NumberofDesks__c = mainIntro.NumberofDesks__c;
                newRec.OutwardCode__c = mainIntro.OutwardCode__c;
                newRec.Amber_Jones_Intro_Email__c = mainIntro.Amber_Jones_Intro_Email__c;
                newRec.Additional_Created__c = true;
                returnlist.add(newRec);
            }
        }

        return returnlist;
    }
}