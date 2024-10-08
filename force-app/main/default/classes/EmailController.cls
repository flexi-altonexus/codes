/*
 *   @Class          :   EmailController
 *
 *   @Author         :   James Boutel <james.boutel@empaua.com>
 *   @Created        :   20 July 2019
 *   @Description    :   Class used for VisualForce Email Template
 *
 *   Modification Log
 *   --------------------------------------------------------------------------------------
 *   #       Developer                           Date                    Description
 *   --------------------------------------------------------------------------------------
 *   1       James Boutel    				20 July 2019				Creation
 *
 */
public class EmailController {
    public Id leadId { get; set; }
    public Id oppId { get; set; }
    public Id viewingScheduleId { get; set; }
    public Lead theLeadRecord { get; set; }
    public Opportunity theOppRecord { get; set; }
    public Id amberJonesId { get; set; }
    public Id viewingId { get; set; }
    public boolean isAmberJones { get; set; }

    // public List<ViewingWrapper> viewingWrappers { get; set; }

    public ViewingSchedule__c getViewingSchedule() {
        return [
            SELECT Id, GoogleMapUrl__c, Email_comments__c
            FROM ViewingSchedule__c
            WHERE Id = :viewingScheduleId
            LIMIT 1
        ];
    }

    public EmailController() {
    }

    public Double offset {
        get {
            TimeZone tz = UserInfo.getTimeZone();
            isAmberJones = false;
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }
    }

    public List<Introduction__c> getIntros() {
        isAmberJones = false;

        amberJonesId = [SELECT Id FROM Group WHERE DeveloperName = 'Amber_Jones' AND Type = 'Queue']
        .Id;

        String query = 'SELECT ';
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Features.getFields()) {
            query += 'BusinessCentre__r.' + f.getFieldPath() + ', ';
        }
        if (leadId != null) {
            theLeadRecord = [SELECT Id, Name, OwnerId FROM Lead WHERE Id = :leadId];
            if (theLeadRecord.OwnerId == amberJonesId) {
                isAmberJones = true;
            }

            query +=
                'Id, Name, Notes__c, BusinessCentre__c, IntroductionType__c, BusinessCentre__r.ShortName__c,' +
                'BusinessCentre__r.DisabilityAccess__c, BusinessCentre__r.SecondaryImage__c, BusinessCentre__r.TertiaryImage__c,' +
                'BusinessCentre__r.PrimaryImage__c, GuidePrice__c, BusinessCentre__r.Phone, BusinessCentre__r.Name, Lead__c, BusinessCentre__r.OfficeLocation__c,' +
                'BusinessCentre__r.PropertyDetails__c, BusinessCentre__r.FlexiWebsiteLink__c, BusinessCentre__r.ShippingStreet, BusinessCentre__r.BillingStreet,' +
                'Re_Send_Email_to_Customer__c, Re_Send_Email_to_Provider__c, ' +
                'BusinessCentre__r.ShippingCity, BusinessCentre__r.ShippingCountry, BusinessCentre__r.ShippingPostalCode, BusinessCentre__r.CentreManager__r.Name, BusinessCentre__r.CentreManager__r.Phone,' +
                'BusinessCentre__r.BillingCity, BusinessCentre__r.BillingCountry, BusinessCentre__r.BillingPostalCode, BusinessCentre__r.CentreManagerEmail__c,' +
                ' BusinessCentre__r.Introduction_Manager_Email__c, BusinessCentre__r.Introduction_Manager__r.Name FROM Introduction__c WHERE Lead__c =: leadId ' +
                'AND (Send_to_BC__c = TRUE OR Send_to_customer__c = TRUE OR Re_Send_Email_to_Customer__c = TRUE)';
                // 'AND (Send_to_customer__c = TRUE OR Re_Send_Email_to_Customer__c = TRUE)';

            return Database.query(query);
        } else {
            theOppRecord = [SELECT Id, Name, Amber_Jones__c FROM Opportunity WHERE Id = :oppId];
            if (theOppRecord.Amber_Jones__c) {
                isAmberJones = true;
            }

            query +=
                'Id, Name, Notes__c, BusinessCentre__c, IntroductionType__c, BusinessCentre__r.ShortName__c,BusinessCentre__r.DisabilityAccess__c,' +
                'BusinessCentre__r.SecondaryImage__c, BusinessCentre__r.TertiaryImage__c, BusinessCentre__r.PrimaryImage__c, GuidePrice__c,' +
                'BusinessCentre__r.Phone, BusinessCentre__r.Name, Lead__c, BusinessCentre__r.OfficeLocation__c,' +
                'BusinessCentre__r.PropertyDetails__c, BusinessCentre__r.FlexiWebsiteLink__c, BusinessCentre__r.ShippingStreet, Re_Send_Email_to_Provider__c, Re_Send_Email_to_Customer__c, ' +
                'BusinessCentre__r.ShippingCity,BusinessCentre__r.ShippingCountry,BusinessCentre__r.ShippingPostalCode, BusinessCentre__r.CentreManager__r.Name,BusinessCentre__r.CentreManager__r.Phone,' +
                'BusinessCentre__r.BillingCity,BusinessCentre__r.BillingCountry,BusinessCentre__r.BillingPostalCode,BusinessCentre__r.BillingStreet,' +
                'BusinessCentre__r.CentreManagerEmail__c, BusinessCentre__r.Introduction_Manager_Email__c, BusinessCentre__r.Introduction_Manager__r.Name ' +
                +'FROM Introduction__c WHERE RelatedToDeal__c =: oppId ' +
                'AND (Send_to_BC__c = TRUE OR Send_to_customer__c = TRUE OR Re_Send_Email_to_Customer__c = TRUE)';
                // 'AND (Send_to_customer__c = TRUE OR Re_Send_Email_to_Customer__c = TRUE)';

            return Database.query(query);
        }
    }

    public List<Viewing__c> getViewings() {
        if (viewingId != null) {
            return [
                SELECT
                    Id,
                    Name,
                    SortOrder__c,
                    ViewingDateTime__c,
                    BusinessCentre__r.Parent.Name,
                    BusinessCentre__r.Name,
                    ClientName__c,
                    CentreManager__c,
                    BusinessCentre__r.Phone,
                    BusinessCentre__r.CentreManager__r.Name,
                    BusinessCentre__r.CentreManagerEmail__c,
                    BusinessCentre__r.CentreManager__r.Phone,
                    BusinessCentre__r.ShippingStreet,
                    BusinessCentre__r.ShippingCity,
                    BusinessCentre__r.ShippingCountry,
                    BusinessCentre__r.PrimaryImage__c,
                    BusinessCentre__r.BillingStreet,
                    BusinessCentre__r.BillingCity,
                    BusinessCentre__r.BillingCountry,
                    BusinessCentre__r.SecondaryImage__c,
                    BusinessCentre__r.TertiaryImage__c,
                    BusinessCentre__r.ShippingPostalCode,
                    BusinessCentre__r.BillingPostalCode,
                    AdditionalNotes__c,
                    BusinessCentre__r.FlexiWebsiteLink__c,
                    ViewingSchedule__c,
                    Secondary_Contact__r.Phone,
                    Secondary_Contact__r.email,
                    Secondary_Contact__r.name,
                    Secondary_Contact__c,
                    LeadRef__r.Name,
                    LeadRef__r.Company
                FROM Viewing__c
                WHERE Id = :viewingId
            ];
        } else if (viewingScheduleId != null) {
            return [
                SELECT
                    Id,
                    Name,
                    SortOrder__c,
                    ViewingDateTime__c,
                    BusinessCentre__r.Parent.Name,
                    BusinessCentre__r.Name,
                    ClientName__c,
                    CentreManager__c,
                    BusinessCentre__r.CentreManager__r.Name,
                    BusinessCentre__r.CentreManager__r.Phone,
                    BusinessCentre__r.Phone,
                    BusinessCentre__r.CentreManagerEmail__c,
                    BusinessCentre__r.ShippingStreet,
                    BusinessCentre__r.ShippingCity,
                    BusinessCentre__r.ShippingCountry,
                    BusinessCentre__r.PrimaryImage__c,
                    BusinessCentre__r.SecondaryImage__c,
                    BusinessCentre__r.TertiaryImage__c,
                    BusinessCentre__r.BillingStreet,
                    BusinessCentre__r.BillingCity,
                    BusinessCentre__r.BillingCountry,
                    BusinessCentre__r.ShippingPostalCode,
                    BusinessCentre__r.BillingPostalCode,
                    AdditionalNotes__c,
                    BusinessCentre__r.FlexiWebsiteLink__c,
                    ViewingSchedule__c,
                    Secondary_Contact__r.Phone,
                    Secondary_Contact__r.email,
                    Secondary_Contact__r.name,
                    Secondary_Contact__c,
                    LeadRef__r.Name,
                    LeadRef__r.Company
                FROM Viewing__c
                WHERE ViewingSchedule__c = :viewingScheduleId
                ORDER BY SortOrder__c ASC
            ];
        } else {
            return null;
        }
    }

    public List<ViewingWrapper> getViewingWrappers() {
        List<ViewingWrapper> viewingWrappers = new List<ViewingWrapper>();
        List<Viewing__c> viewingsToWrap = getViewings();

        for (Viewing__c v : viewingsToWrap) {
            viewingWrappers.add(new ViewingWrapper(v));
        }

        return viewingWrappers;
    }

    public class ViewingWrapper {
        public String id { get; set; }
        public String name { get; set; }
        public Integer sortOrder { get; set; }
        public DateTime viewingDateTime { get; set; }
        public String businessCentreParentName { get; set; }
        public String businessCentreName { get; set; }
        public String clientName { get; set; }
        public String centreManager { get; set; }
        public String businessCentreCentreManagerName { get; set; }
        public String businessCentreCentreManagerPhone { get; set; }
        public String businessCentrePhone { get; set; }
        public String businessCentreCentreManagerEmail { get; set; }
        public String businessCentreShippingStreet { get; set; }
        public String businessCentreShippingCity { get; set; }
        public String businessCentreShippingCountry { get; set; }
        public String businessCentrePrimaryImage { get; set; }
        public String businessCentreSecondaryImage { get; set; }
        public String businessCentreTertiaryImage { get; set; }
        public String businessCentreBillingStreet { get; set; }
        public String businessCentreBillingCity { get; set; }
        public String businessCentreBillingCountry { get; set; }
        public String businessCentreShippingPostalCode { get; set; }
        public String businessCentreBillingPostalCode { get; set; }
        public String additionalNotes { get; set; }
        public String businessCentreFlexiWebsiteLink { get; set; }
        public Id viewingSchedule { get; set; }
        public String secondaryContactPhone { get; set; }
        public String secondaryContactEmail { get; set; }
        public String secondaryContactName { get; set; }
        public Id secondaryContact { get; set; }
        public String leadName { get; set; }
        public String leadCompany { get; set; }

        public ViewingWrapper(Viewing__c v) {
            this.id = v.Id;
            this.name = v.Name;
            this.sortOrder = (Integer) v.SortOrder__c;
            this.businessCentreParentName = v.BusinessCentre__r.Parent.Name;
            this.businessCentreName = v.BusinessCentre__r.Name;
            this.clientName = v.ClientName__c;
            this.centreManager = v.CentreManager__c;
            this.businessCentreCentreManagerName = v.BusinessCentre__r.CentreManager__r.Name;
            this.businessCentreCentreManagerPhone = v.BusinessCentre__r.CentreManager__r.Phone;
            this.businessCentrePhone = v.BusinessCentre__r.Phone;
            this.businessCentreCentreManagerEmail = v.BusinessCentre__r.CentreManagerEmail__c;
            this.businessCentreShippingStreet = v.BusinessCentre__r.ShippingStreet;
            this.businessCentreShippingCity = v.BusinessCentre__r.ShippingCity;
            this.businessCentreShippingCountry = v.BusinessCentre__r.ShippingCountry;
            this.businessCentrePrimaryImage = v.BusinessCentre__r.PrimaryImage__c;
            this.businessCentreSecondaryImage = v.BusinessCentre__r.SecondaryImage__c;
            this.businessCentreTertiaryImage = v.BusinessCentre__r.TertiaryImage__c;
            this.businessCentreBillingStreet = v.BusinessCentre__r.BillingStreet;
            this.businessCentreBillingCity = v.BusinessCentre__r.BillingCity;
            this.businessCentreBillingCountry = v.BusinessCentre__r.BillingCountry;
            this.businessCentreShippingPostalCode = v.BusinessCentre__r.ShippingPostalCode;
            this.businessCentreBillingPostalCode = v.BusinessCentre__r.BillingPostalCode;
            this.additionalNotes = v.AdditionalNotes__c;
            this.businessCentreFlexiWebsiteLink = v.BusinessCentre__r.FlexiWebsiteLink__c;
            this.viewingSchedule = v.ViewingSchedule__c;
            this.secondaryContactPhone = v.Secondary_Contact__r.Phone;
            this.secondaryContactEmail = v.Secondary_Contact__r.email;
            this.secondaryContactName = v.Secondary_Contact__r.name;
            this.secondaryContact = v.Secondary_Contact__c;

            Long viewDateTimeGMTMilli = v.ViewingDateTime__c.getTime();
            Long offsetMilli = UserInfo.getTimeZone().getOffset(v.ViewingDateTime__c);
            this.viewingDateTime = DateTime.newInstance(viewDateTimeGMTMilli + offsetMilli);
            this.leadName = v.LeadRef__c != null ? v.LeadRef__r.Name: null;
            this.leadCompany = v.LeadRef__c != null ? v.LeadRef__r.Company: null;
        }
    }
}