/*
 * @name     : displayOnGoogleMap
 * @who      : David Sanchez <david.sanchez@empaua.com>
 * @when     : 2019-05-24
 * @what     : Provides action methods for displayOnGoogleMap LWC.
 * Modification Log
 * ============================================================================================================================
 * #       Who               When            What
 * ============================================================================================================================
 */
public with sharing class displayOnGoogleMap {
    /*
     * @Name : getLocations
     * @Who  : David Sanchez <david@empaua.com>
     * @When : 2019-05-24
     * @What : Returns a list of locations that will be displayed by the LWC
     * @Parameter: objectName - name of the object from which the locations will be selected.
     *             fields - a map of fields that are to selected by the query. The map breaks these
     *                      into the following types:
     *                          longitude - the name of the  address's longitude field (e.g. billingLongitude).
     *                          latitude  - the name for the latitude field (e.g. client__r.billingLatitude).
     *                          name - name of a descritive field (e.g. contact.name).
     *                          address - name of the address fields. These are comma separated
     *                                    (e.g. MailingStreet, MailingCity, MailingCountry).
     *             filters - string which will by added to WHERE clause to filter the records selected
     *                       (e.g OpportunyRef__c = '0061w0000193EasAAE' AND OpportunityRef__r.StageName = 'Negotiations')
     */
    @AuraEnabled
    public static List<Location> getLocations(String objectName, Map<String,String> fields, String filter){
         System.debug('---getLocations--- objectName: '+objectName);
         System.debug('---getLocations--- fields: '+fields);
         System.debug('---getLocations--- filter: '+filter);

        String fieldsStr = fields.get('longitude') + ', ' + fields.get('latitude') + ', ' + fields.get('name') + ', ' + fields.get('address');

        if(fields.containskey('parentname')){
            fieldsStr += ', ' + fields.get('parentname');
        }
        
        String query = 'SELECT ' + fieldsStr + '  FROM ' + objectName +
                       ' WHERE ' + filter + ' AND ' + fields.get('longitude') + ' != null ' + ' AND ' + fields.get('latitude') + ' != null ';

        System.debug('---getLocations--- query: '+query);
        
        List<sObject> queryResult = Database.query(query);

        System.debug('---getLocations--- queryResult: '+queryResult);

        List<Location> locationList = new List<Location>();
        for (sObject record : queryResult) {
            locationList.add(new Location(record,fields));
        }

        System.debug('---getLocations--- locationList: '+locationList);
        
        return locationList;
    }

    /*
     * @Name : getValue
     * @Who  : David Sanchez <david@empaua.com>
     * @When : 2019-05-24
     * @What : Extract a value of an sObject field. It follows relationships if required.
     * @Parameter: record - the sObject record from which the value will be extracted.
     *             fieldName - the name which value will be extracted.
     */

    private static Object getValue(sObject record, String fieldName) {
        List<String> splittedField = fieldName.split('\\.');

        sObject relSobj = record;
        for (Integer fldNo = 0; fldNo < splittedField.size() - 1; fldNo++) {
            relSobj = relSobj.getSObject(splittedField[fldNo].trim());
        }

        return relSobj.get(splittedField[splittedField.size() - 1].trim());
    }

    /*
     * @Name : Location
     * @Who  : David Sanchez <david@empaua.com>
     * @When : 2019-05-24
     * @What : Wrapper class with location values needed to display the map
     */
    
    public class Location {
        @AuraEnabled public String longitude { get; set; }
        @AuraEnabled public String latitude { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String parentname { get; set; }
        @AuraEnabled public String address { get; set; }   // A concatenation of the address fields values.

        Location(sObject record, Map<String,String> fields) {
            longitude = String.valueOf((Decimal) getValue(record,fields.get('longitude')));
            latitude = String.valueOf((Decimal) getValue(record,fields.get('latitude')));
            name = (String) getValue(record,fields.get('name'));

            try{
                if((String) getValue(record,fields.get('parentname')) != null){
                    parentname = (String) getValue(record,fields.get('parentname'));
                }else{
                    parentname = '';
                }
            }catch(Exception e){
                parentname = '';
            }

            List<String> addrFlds = fields.get('address').split(',');

            address = '';
            for (String fldName : addrFlds) {
                String addrVal = (String) getValue(record,fldName);
                address += (addrVal == null ? '' : addrVal) + ' ';
            }
        }
    }
}