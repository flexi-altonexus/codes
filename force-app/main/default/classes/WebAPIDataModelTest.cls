@istest
public class WebAPIDataModelTest {
    @istest
    public static void WebAPIDataModelTest() {
        
        Account ac = TestFactory.createBC();
		insert ac;

        Test.StartTest();
        WebAPIDataModel.Enhanced_Listing testEnhancedListing = new WebAPIDataModel.Enhanced_Listing();
        WebAPIDataModel.Enhanced_Slot Enhanced_Slot = new WebAPIDataModel.Enhanced_Slot();
        WebAPIDataModel.Location_reponse Location_reponse = new WebAPIDataModel.Location_reponse();
        WebAPIDataModel.Location Location = new WebAPIDataModel.Location();
        Location.sId = '0';
        Location.id = 1;
        Location.locationTypeName = 'a';
        Location.showName = 'aa';
        Location.analyzedName = 'a';
        Location.latitude = 1;
        Location.longitude = 1;
        Location.priority = 1;
        Location.headerStatus = 1;
        Location.removedFromAnchors = true;
        Location.removedFromUrls = true;
        WebAPIDataModel.BusinessCentre_response BusinessCentre_response = new WebAPIDataModel.BusinessCentre_response();
        WebAPIDataModel.BusinessCentreAdd_response BusinessCentreAdd_response = new WebAPIDataModel.BusinessCentreAdd_response();
        BusinessCentreAdd_response.sId = 'a';
        BusinessCentreAdd_response.searchedTerm = 'a';
        BusinessCentreAdd_response.error = false;
        
        WebAPIDataModel.BusinessCentre BusinessCentre = new WebAPIDataModel.BusinessCentre(ac);
        BusinessCentre.townId = 1;
        BusinessCentre.locationId = 0;
        BusinessCentre.cityId = 0;
        BusinessCentre.countyId = 0;
        BusinessCentre.bcCompanyId = 0;
        BusinessCentre.buildingName = '0';
        BusinessCentre.globalCityId = 1;
        BusinessCentre.globalCountryId = 1;
        BusinessCentre.costCurrency = 1;
        BusinessCentre.officeCurrency ='0';
        BusinessCentre.costTypeID = 0;
        BusinessCentre.voiceMail = true;
        BusinessCentre.dda = '0';
        BusinessCentre.dateSubmitted = '0';
        BusinessCentre.approved= true;
        BusinessCentre.centreManagerDdi = '0';
        BusinessCentre.furtherComment =  '0';
        BusinessCentre.email = '0';
        BusinessCentre.archived = true;
        BusinessCentre.x = 0;
        BusinessCentre.y=0;
        BusinessCentre.enhancedListing= true;
        BusinessCentre.specialoffer= true;
        BusinessCentre.specialofferdetails = '0';
        BusinessCentre.specialterms= true;
        BusinessCentre.tradeIcon= true;
        BusinessCentre.loungeAreas= true;
        BusinessCentre.modernBuilding= true;
        BusinessCentre.periodBuilding= true;
        BusinessCentre.sharedSpace= true;
        BusinessCentre.bicycleParking= true;
        BusinessCentre.mannedReception= true;
        BusinessCentre.premium= true;
        BusinessCentre.display= true;
        BusinessCentre.disreputable= true;
        BusinessCentre.descriptionCos= '0';
        BusinessCentre.descriptionOstr= '0';
        BusinessCentre.descriptionSos= '0';
        BusinessCentre.chkCos= true;
        BusinessCentre.chkOstr= true;
        BusinessCentre.chkSos= true;
        BusinessCentre.enhancedcomm= true;
        BusinessCentre.isLondonPrime = true;
        BusinessCentre.metaDescription = 'a';
        BusinessCentre.pageTitle = '0';
      
        WebAPIDataModel.GeoWrap GeoWrap = new WebAPIDataModel.GeoWrap();
        string  convertExternalId = WebAPIDataModel.convertExternalId('$id');
        string convertInternalId = WebAPIDataModel.convertInternalId('sId');
        WebAPIDataModel.StatisticResponse StatisticResponse = new WebAPIDataModel.StatisticResponse();
        StatisticResponse.sId = '0';
        WebAPIDataModel.StatisticURL StatisticURL = new WebAPIDataModel.StatisticURL();
        StatisticURL.sId = '0';
        WebAPIDataModel.StatisticBC StatisticBC = new WebAPIDataModel.StatisticBC();
        StatisticBC.uniqueKey= '10';
        StatisticBC.i = '1';
        StatisticBC.id = '1';
        StatisticBC.q = '0';
        StatisticBC.sId = '0';
        StatisticBC.v = '0';

        test.stopTest();
    }

   
        
    
}