/*
 * @name     : displayOnGoogleMap
 * @who      : David Sanchez <david.sanchez@empaua.com>
 * @when     : 2019-05-24
 * @what     : Javascript for LWC
 * 
 * Modification Log
 * ============================================================================================================================
 * #       Who               When            What
 * ============================================================================================================================
 */
/* eslint-disable no-console */
import { LightningElement, api, track} from 'lwc';
import getLocations from '@salesforce/apex/displayOnGoogleMap.getLocations';

export default class DisplayOnGoogleMap extends LightningElement {
    // Parameter attributes
    @api filters;
    @api longitudeField;
    @api latitudeField;
    @api nameField;
    @api parentnameField;
    @api addressFields;
    @api objectName;
    @api markersTitle = 'Markers';

    // Default location -- displayed when no matching records are found
    @track mapMarkers = [{
                            location: {
                                'City': 'London',
                                'Country': 'UK',
                                'Latitude': '51.597282', 
                                'Longitude': '-0.107785'
                            },
                            title: 'London',
                            description: 'London'
                        }];
    
    @track center = [{location: {'City': 'London','Country': 'UK'}}];
    @track zoomLevel = 10;

    // On page load
    connectedCallback() {
        this.loadLocations();
    }

    // Loads the locations to be displayed on map
    loadLocations() {
        var fields = {longitude: this.longitudeField,
            latitude: this.latitudeField,
            name: this.nameField,
            parentname: this.parentnameField,
            address: this.addressFields
         };
        
        //console.log('-----connectedCallback-------'+this.objectName);

        getLocations({objectName: this.objectName, fields: fields, filter: this.filters})
        .then( result => {
            //console.log(JSON.stringify(result));
            let markersLst = [];
            let markerName;
            for (let i = 0; i < result.length; i++) {
                console.log('-------------'+i+'----------------');
                console.log('---longitude: '+result[i].longitude);
                console.log('---latitude: '+result[i].latitude);
                console.log('---name: '+result[i].name);
                console.log('---address: '+result[i].address);

                markerName = result[i].name;
                if(result[i].parentname !== ''){
                    markerName = result[i].name + ' ('+ result[i].parentname +')';
                }

                    let marker = {
                        location: {
                            'Street': result[i].address,
                            'Latitude': result[i].latitude, 
                            'Longitude': result[i].longitude
                        },
                        title: markerName,
                        description: result[i].address
                    }

                    markersLst.push(marker);
                }

                this.center = {location: {'Longitude': result[0].longitude, 'Latitude': result[0].latitude}};
                this.mapMarkers = markersLst;

                // console.log('-------------mapMarkers----------------');
                // console.log(JSON.stringify(this.mapMarkers));
        })
        .catch(error => {
            console.log(error);
        });
    }
}