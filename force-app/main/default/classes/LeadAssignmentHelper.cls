public class LeadAssignmentHelper {
    private static final List<String> outOfHours = new List<String>();
    private static final List<String> midWS = new List<String>();
    private static final List<String> highWS = new List<String>();
    private static final List<String> businessHours = new List<String>();

    static {
        for (OutOfHoursUsers__mdt record : [SELECT Order__c, Username__c FROM OutOfHoursUsers__mdt ORDER BY Order__c ASC]) {
            outOfHours.add(record.Username__c);
        }

        for (BusinessHoursMidWSUsers__mdt record : [SELECT Order__c, Username__c FROM BusinessHoursMidWSUsers__mdt ORDER BY Order__c ASC]) {
            midWS.add(record.Username__c);
        }

        for (BusinessHoursHighWSUsers__mdt record : [SELECT Order__c, Username__c FROM BusinessHoursHighWSUsers__mdt ORDER BY Order__c ASC]) {
            highWS.add(record.Username__c);
        }

        for (BusinessHoursUsers__mdt record : [SELECT Order__c, Username__c FROM BusinessHoursUsers__mdt ORDER BY Order__c ASC]) {
            businessHours.add(record.Username__c);
        }
    }

    @testVisible
    private static DateTime NowIsTheTime {
        get {
            if (NowIsTheTime == null) {
                NowIsTheTime = DateTime.now();
            }
            return NowIsTheTime;
        }
        private set;
    }

    public static void assignLead(List<Lead> leads) {
        String AJOwner = System.Label.AJ_Owner_Id;

        for (Lead lead : leads) {
            system.debug('createdTime--->' + lead.createdDate);
            if (lead.Country == 'UK') {
                system.debug('lead country is UK');
                Integer workstations = Integer.valueOf(lead.NumberofDesks__c);
                List<RR_Postal_Code__c> postcodes = 
                [SELECT Id, Name, Postal_Code__c, Country__c, City__c FROM RR_Postal_Code__c where Postal_Code__c = :lead.postal_Code__c limit 1];
                if (workstations < 5 && !postcodes.isEmpty() && postcodes[0].City__c != 'London') {
                    lead.OwnerId = AJOwner;
                    system.debug('Amber jones lead');
                    break;
                }
                Datetime nownow = NowIsTheTime;
                system.debug('currentTime' + nownow);
                if (isBusinessHours(nownow)) {
                    if (workstations <= 10) {
                        lead.OwnerId = getNextBusinessHoursUserId();
                        system.debug('lead owner for 5 to 10' + lead.OwnerId);
                    } else if (workstations > 10 && workstations <= 15) {
                        lead.OwnerId = getNextMidWSBusinessHoursUserId();
                        system.debug('lead owner for more than 10' + lead.OwnerId);
                    } else if (workstations >= 16) {
                        lead.OwnerId = getNextHighWSBusinessHoursUserId();
                        system.debug('lead owner for more than 15' + lead.OwnerId);
                    }
                } else {
                    if (workstations >= 5) {
                        lead.OwnerId = getCurrentOutOfHoursUserId();
                    } else if (workstations < 5 && !postcodes.isEmpty() && postcodes[0].City__c != 'London') {
                        lead.OwnerId = AJOwner;
                    }
                }
            }
        }
    }

    private static Boolean isBusinessHours(Datetime dt) {
        Time start = Time.newInstance(8, 0, 0, 0);
        Time endTime = Time.newInstance(18, 0, 0, 0);

        //bank holiday
        Date today = Date.today();
        if (today == Date.newInstance(2024, 8, 26) ) {
            return false;
        }

        if (dt.format('u') >= '1' && dt.format('u') <= '5' && dt.time() >= start && dt.time() <= endTime) {
            return true;
        }
        return false;
    }

    private static Boolean isUserExcluded(String alias) {
        Date today = Date.today();

        if (alias == 'esobe' && today >= Date.newInstance(2024, 8, 20) && today < Date.newInstance(2024, 8, 29)) {
            return true;
        }

        if (alias == 'hperr' && today >= Date.newInstance(2024, 8, 20) && today < Date.newInstance(2024, 9, 2)) {
            return true;
        }

        if (alias == 'nconn' && today >= Date.newInstance(2024, 8, 23) && today <= Date.newInstance(2024, 8, 27)) {
            return true;
        }

        return false;
    }

    private static Id getNextBusinessHoursUserId() {
        Lead_Assignment_Settings__c settings = [SELECT Id, Last_Business_Hours_Index__c FROM Lead_Assignment_Settings__c LIMIT 1];
        Integer currentIndex = Integer.valueOf(settings.Last_Business_Hours_Index__c) == null ? 0 : Integer.valueOf(settings.Last_Business_Hours_Index__c);

        String nextUserAlias;
        do {
            nextUserAlias = businessHours[currentIndex];
            currentIndex = currentIndex + 1 >= businessHours.size() ? 0 : currentIndex + 1;
        } while (isUserExcluded(nextUserAlias));

        User nextUser = [SELECT Id, Name FROM User WHERE Alias = :nextUserAlias LIMIT 1];
        settings.Last_Business_Hours_Index__c = currentIndex;
        update settings;
        return nextUser.Id;
    }

    private static Id getNextMidWSBusinessHoursUserId() {
        Lead_Assignment_Settings_High__c settings = [SELECT Id, Last_Business_Hours_Index__c FROM Lead_Assignment_Settings_High__c LIMIT 1];
        Integer currentIndex = Integer.valueOf(settings.Last_Business_Hours_Index__c) == null ? 0 : Integer.valueOf(settings.Last_Business_Hours_Index__c);

        String nextUserAlias;
        do {
            nextUserAlias = midWS[currentIndex];
            currentIndex = currentIndex + 1 >= midWS.size() ? 0 : currentIndex + 1;
            } while (isUserExcluded(nextUserAlias));

        User nextUser = [SELECT Id FROM User WHERE Alias = :nextUserAlias LIMIT 1];
        settings.Last_Business_Hours_Index__c = currentIndex;
        update settings;
        return nextUser.Id;
    }

    private static Id getNextHighWSBusinessHoursUserId() {
        Lead_Assignment_Settings_Tier3__c settings = [SELECT Id, Last_Business_Hours_Index__c FROM Lead_Assignment_Settings_Tier3__c LIMIT 1];
        Integer currentIndex = Integer.valueOf(settings.Last_Business_Hours_Index__c) == null ? 0 : Integer.valueOf(settings.Last_Business_Hours_Index__c);

        String nextUserAlias;
        do {
            nextUserAlias = highWS[currentIndex];
            currentIndex = currentIndex + 1 >= highWS.size() ? 0 : currentIndex + 1;
        } while (isUserExcluded(nextUserAlias));

        User nextUser = [SELECT Id FROM User WHERE Alias = :nextUserAlias LIMIT 1];
        settings.Last_Business_Hours_Index__c = currentIndex;
        update settings;
        return nextUser.Id;
    }

    private static Id getCurrentOutOfHoursUserId() {
        Lead_Assignment_Settings__c settings = Lead_Assignment_Settings__c.getOrgDefaults();
        Integer currentWeek = (settings.Current_Week__c == null) ? 0 : Integer.valueOf(settings.Current_Week__c);
        // Integer outHours = Math.mod(currentWeek, outOfHours.size());
        String currentWeekUserAlias = outOfHours[currentWeek];
        User currentWeekUser = [SELECT Id FROM User WHERE Alias = :currentWeekUserAlias LIMIT 1];
        return currentWeekUser.Id;
    }
}