global class WeeklyOutOfHoursRotation implements Schedulable {
    private static final List<String> outOfHours = new List<String>();
    static {
        for (OutOfHoursUsers__mdt record : [SELECT Username__c FROM OutOfHoursUsers__mdt ORDER BY Order__c ASC]) {
            outOfHours.add(record.Username__c);
        }

            }
            
        public void execute(SchedulableContext sc) {
        Lead_Assignment_Settings__c settings = Lead_Assignment_Settings__c.getOrgDefaults();
        Integer currentWeek = settings.Current_Week__c == null ? 0 : Integer.valueOf(settings.Current_Week__c);
        settings.Current_Week__c = currentWeek + 1 >= outofHours.size() ? 0 : currentWeek + 1;
        update settings;
    }
}

 //System.schedule('Weekly Out of Hours Rotation', '0 0 0 ? * MON', new WeeklyOutOfHoursRotation());