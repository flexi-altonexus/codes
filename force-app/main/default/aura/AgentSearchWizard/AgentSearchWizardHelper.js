({
    searchRecords: function (component, searchString) {
        console.log("searchRecords");
        console.log(component.get("v.selectedValue"));
        var action = component.get("c.getLocations");
        action.setParams({
            searchString: searchString,
            strCountry: component.get("v.selectedValue")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var locationmap = response.getReturnValue();
                component.set("v.locationMap", locationmap);
                var options = [];
                //value: locationmap[key].url
                for (var key in locationmap) {
                    options.push({
                        label: key,
                        value: key
                    });
                }
                
                console.log(options);
                //component.set("v.locationOptions", options);
                component.set("v.results", options);
                
                //component.set("v.results", options);
                if (options.length > 0) {
                    component.set("v.openDropDown", true);
                }
                component.set("v.showSpinner", false);
                
                /*
                const serverResult = response.getReturnValue();
                const results = [];
                serverResult.forEach(element => {
                    const result = {id : element[component.get("v.idFieldApiName")], value : element[component.get("v.valueFieldApiName")]};
                    results.push(result);
                });
                component.set("v.results", results);
                if(serverResult.length>0){
                    component.set("v.openDropDown", true);
                }

                */
            } else {
                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        title: "ERROR",
                        type: "error",
                        message: "Something went wrong!! Check server logs!!"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    addListener: function (component, event, helper) {
        console.log("Before add Listener");
        console.log("addListiner OK");
        window.sessionStorage.setItem("SFListener", "true");
        window.addEventListener(
            "message",
            function (event) {
                //Add Item
                if (event.data.key === "EMP" && event.data.action === "add") {
                    console.log("Dentro de Add" + event.data.value);
                    
                    var existingRecords = component.get("v.objectList");
                    var resultRecords = component.get("v.resultList");
                    console.log(typeof existingRecords);
                    console.log(existingRecords);
                    console.log(resultRecords);
                    console.log("Before Error JC");
                    
                    if (
                        resultRecords !== undefined &&
                        resultRecords !== undefined &&
                        resultRecords.length !== undefined &&
                        resultRecords.length !== "undefined"
                    ) {
                        for (var i = 0; i < resultRecords.length; i++) {
                            var found = existingRecords.find(
                                (o) => o.BusinessCentreId === resultRecords[i].BusinessCentreId
                            );
                            if (
                                found === undefined &&
                                event.data.value === resultRecords[i].BusinessCentreId
                            ) {
                                existingRecords.push(resultRecords[i]);
                            }
                        }
                        
                        component.set("v.objectListSize", existingRecords.length.toString());
                    }
                    component.set("v.objectList", existingRecords);
                    console.log("Out add");
                }
                //Remove Item
                if (event.data.key === "EMP" && event.data.action === "remove") {
                    var rows = component.get("v.objectList");
                    
                    console.log("Dentro remove" + event.data.value);
                    if (rows !== undefined && rows !== "undefined") {
                        for (var i = 0; i < rows.length; i++) {
                            if (rows[i].BusinessCentreId === event.data.value) {
                                rows.splice(rows.indexOf(i), 1);
                            }
                        }
                        
                        component.set("v.objectList", rows);
                        component.set("v.objectListSize", rows.length.toString());
                    }
                }
            },
            false
        );
    },
    setupDatatable: function (component, event, helper) {
        //Define Columns
        component.set("v.objectColumns", [
            {
                label: "Centre",
                fieldName: "SFLink",
                type: "url",
                cellAttributes: { class: { fieldName: "showClass" } },
                typeAttributes: { target: "_blank", label: { fieldName: "name" } },
                sortable: true
            },
            //{
            //    label: "Street",
            //    fieldName: "street",
            //    type: "text",
            //    cellAttributes: { class: { fieldName: "showClass" } },
            //    sortable: true
            //},
            // {
            //     label: "Distance",
            //     fieldName: "distance",
            //     type: "text",
            //     cellAttributes: { class: { fieldName: "showClass" } },
            //     sortable: true
            // },
            // {label: 'Lower', fieldName: 'lower', type: 'text', "cellAttributes" : { "class": {"fieldName": "showClass"}},sortable: true},
            {
                label: "Phone",
                fieldName: "phone",
                type: "text",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            {
                label: "BC Company",
                fieldName: "bccompany",
                type: "text",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            {
                label: "Subscription",
                fieldName: "subscription",
                type: "boolean",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            {
                label: "Last Intro",
                fieldName: "lastIntroDate",
                type: "text",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            {
                label: "Increased fees",
                fieldName: "isEnhanced",
                type: "boolean",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            //            {
            //                label: "Payment in Advance",
            //                fieldName: "paymentAd",
            //                type: "text",
            //                cellAttributes: { class: { fieldName: "showClass" } },
            //                sortable: true
            //            },
            {
                label: "Payment Frequency",
                fieldName: "paymentFrequency",
                type: "text",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            {
                label: "Enhanced Fee",
                fieldName: "enhancedFee",
                type: "text",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            }
        ]);
        
        component.set("v.objectColumnsBasket", [
            {
                label: "Centre",
                fieldName: "SFLink",
                type: "url",
                cellAttributes: { class: { fieldName: "showClass" } },
                typeAttributes: { target: "_blank", label: { fieldName: "name" } },
                sortable: true
            },
            //{
            //    label: "Street",
            //    fieldName: "street",
            //    type: "text",
            //    cellAttributes: { class: { fieldName: "showClass" } },
            //    sortable: true
            //},
            // {
            //     label: "Distance",
            //     fieldName: "distance",
            //     type: "text",
            //     cellAttributes: { class: { fieldName: "showClass" } },
            //     sortable: true
            // },
            // {label: 'Lower', fieldName: 'lower', type: 'text', "cellAttributes" : { "class": {"fieldName": "showClass"}},sortable: true},
            {
                label: "Phone",
                fieldName: "phone",
                type: "text",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            {
                label: "BC Company",
                fieldName: "bccompany",
                type: "text",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            {
                label: "Subscription",
                fieldName: "subscription",
                type: "boolean",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            //            {
            //                label: "Payment in Advance",
            //                fieldName: "paymentAd",
            //                type: "text",
            //                cellAttributes: { class: { fieldName: "showClass" } },
            //                sortable: true
            //            },
            {
                label: "Payment Frequency",
                fieldName: "paymentFrequency",
                type: "text",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true
            },
            {
                label: "Enhanced Fee",
                fieldName: "enhancedFee",
                cellAttributes: { class: { fieldName: "showClass" } },
                sortable: true,
                type: 'button',
                typeAttributes: {
                    label: { fieldName: "enhancedFee" },
                    name: 'name',
                    title: { fieldName: "enhancedFee" },
                    value: { fieldName: "enhancedFee" },
                    variant: 'base',
                    class: 'text-button'
                }
            },
     //     {
      //          label: "Available length of term",
       //         type: "button",
       //         typeAttributes: {
        //            label: { fieldName: "termLength" },
         //           name: "edit_term_length",
         //           iconName: "utility:edit",
          //          title: { fieldName: "termLength" }
          //      }
          //  },
          //  {
           //     label: "Earliest availability date",
           //     type: "button",
            //    typeAttributes: {
             //       label: { fieldName: "abrAvailableFrom" },
              //      name: "edit_available_from",
               //     iconName: "utility:edit",
                //    title: { fieldName: "availableFrom" }
              //  }
          //  },
  //          {
  //              label: "Office size",
   //             type: "button",
   //             typeAttributes: {
    //                label: { fieldName: "abrOptionSize" },
    //                name: "edit_option_size",
     //               iconName: "utility:edit",
      //              title: { fieldName: "optionSize" }
        //        }
         //   },
        //    {
          //      label: "Monthly rent",
            //    type: "button",
              //  typeAttributes: {
                //    label: { fieldName: "abrMonthlyQuotingRate" },
                  //  name: "edit_monthly_quoting_rate",
                    //iconName: "utility:edit",
                   // title: { fieldName: "monthlyQuotingRate" }
               // }
           // }
           
            {
                label: "Additional information",
                type: "button",
                typeAttributes: {
                    label: { fieldName: "abrMonthlyCostOccupation" },
                    name: "edit_monthly_cost_occupation",
                    iconName: "utility:edit",
                    title: { fieldName: "monthlyCostOccupation" }
                }
            }
        ]);
    },
    FormatDataTable: function (rows) {
        console.log("format Table");
        //Format relation and URL values of the Table, adding class to control background color
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            
            //Link creation
            if (row.BusinessCentreId) {
                row.SFLink = "/" + row.BusinessCentreId;
            }
            
            //Enhanced BackgroundColor // EMPAUA: IS KEY PROVIDER CASE 15/11/2022
            //     row.showClass = row.isEnhanced === true || row.isKeyProviderBC === true? row.isKeyProviderBC === true? "keyprovider":"enhanced" : "normal";
            row.showClass = row.isEnhanced === true || row.isKeyProviderBC === true? row.isEnhanced === true? "enhanced":"keyprovider" : "normal";
            
            //Other Enhanced
            if (row.otherEnhanced && row.showClass != "enhanced") {
                row.showClass = "otherenhanced";
            }
            
            //Already introduced BackgroundColor
            if (
                row.lastIntroDate != "" &&
                row.lastIntroDate != null &&
                row.lastIntroDate != "null"
            ) {
                row.showClass = "introduced";
            }
            
            if (row.fromIntro && row.showClass != "enhanced") {
                row.showClass = "fromIntro";
            }
            
            if (row.enhancedFee && row.showClass != "enhanced") {
                row.showClass = "enhancedFee";
            }
            
            //is subscribed
            row.showClassSendToB = row.showClass;
            if (row.subscription && row.showClass != "enhanced") {
                row.showClass = "subscribed";
                row.showClassSendToB = "subscribedDisabled";
            }
            
            if (row.termLength) {
                if (row.termLength.length > 15) {
                    row.abrtermLength = row.termLength.substring(0, 5) + "...";
                } else {
                    row.abrtermLength = row.termLength;
                }
            }
            
            if (row.availableFrom) {
                if (row.availableFrom.length > 15) {
                    row.abrAvailableFrom = row.availableFrom.substring(0, 5) + "...";
                } else {
                    row.abrAvailableFrom = row.availableFrom;
                }
            }
            
            if (row.optionSize) {
                if (row.optionSize.length > 15) {
                    row.abrOptionSize = row.optionSize.substring(0, 5) + "...";
                } else {
                    row.abrOptionSize = row.optionSize;
                }
            }
            
            if (row.monthlyQuotingRate) {
                if (row.monthlyQuotingRate.length > 15) {
                    row.abrMonthlyQuotingRate = row.monthlyQuotingRate.substring(0, 5) + "...";
                } else {
                    row.abrMonthlyQuotingRate = row.monthlyQuotingRate;
                }
            }
            
            if (row.monthlyCostOccupation) {
                if (row.monthlyCostOccupation.length > 15) {
                    row.abrMonthlyCostOccupation =
                        row.monthlyCostOccupation.substring(0, 5) + "...";
                } else {
                    row.abrMonthlyCostOccupation = row.monthlyCostOccupation;
                }
            }
        }
        
        return rows;
    },
    setupSentIntros: function (component, event, helper) {
        var action = component.get("c.getBusinessCentresById");
        action.setParam("recordId", component.get("v.recordId"));
        console.log(component.get("v.recordId"));
        
        action.setCallback(this, function (data) {
            var state = data.getState();
            var mergeResult = [];
            if (state === "SUCCESS") {
                component.set("v.objectList", helper.FormatDataTable(data.getReturnValue()));
            } else if (state === "ERROR") {
                var errors = data.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.showError", true);
                        component.set("v.errorMessage", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
            component.set("v.objectListSize", component.get("v.objectList").length.toString());
            component.set("v.showSpinner", false);
            return mergeResult;
        });
        $A.enqueueAction(action);
    },
    handleClickAdd: function (component, event, helper) {
        console.log("Before add New");
        component.set("v.showSpinner", true);
        
        var existingRecords = component.get("v.objectList");
        var rowsSelected = component.get("v.rowsSelected");
        
        console.log(rowsSelected);
        console.log(rowsSelected.length);
        
        if (rowsSelected.length !== undefined && rowsSelected.length !== "undefined") {
            for (var i = 0; i < rowsSelected.length; i++) {
                var found = existingRecords.find(
                    (o) => o.BusinessCentreId === rowsSelected[i].BusinessCentreId
                );
                if (found === undefined) {
                    existingRecords.push(rowsSelected[i]);
                }
            }
            
            component.set("v.objectListSize", existingRecords.length.toString());
        }
        
        component.set("v.objectList", existingRecords);
        component.set("v.showSpinner", false);
    },
    /*searchLocations: function (component, event, helper) {
        console.log('Searching Locations');
        component.set("v.showSpinner",true);

        var action = component.get("c.getLocations");
        action.setParam("searchText" , component.find("enter-search").get("v.value"));

        action.setCallback(this, function(data) {
            
            var state = data.getState();
            var result = [];
            if (state === "SUCCESS") {
                var locationmap = data.getReturnValue();
                //console.log(locMaps['London']);
                component.set("v.locationMap", locationmap);
                var options = [];
                //value: locationmap[key].url
                for(var key in locationmap){
                     options.push({
                        label: key,
                        value: key
                    });
                }
               
                console.log(options);
                component.set("v.locationOptions", options);
                component.find("selectItem").focus();
                component.set("v.showSpinner",false);

            }else if (state === "ERROR") {
                var errors = data.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }

            return result;
       
        });
        $A.enqueueAction(action); 
        
    },*/
    handleClickRemove: function (component, event, helper) {
        console.log("Click Remove");
        var existingRecords = component.get("v.objectList");
        
        console.log(JSON.stringify(existingRecords));
        const sIdsToDelete = component.get("v.basketSelected").map((iItem) => {
            if(!iItem.subscription) {
            return iItem.BusinessCentreId;
        }
                                                                   });
        
        const rowsSelected = existingRecords.filter((iRecord) => {
            // return only ids that do not belong to sIdsToDelete
            return !sIdsToDelete.includes(iRecord.BusinessCentreId);
        });
        
        /*
        var rowsSelected = component.get("v.basketSelected");
        console.log(JSON.stringify(rowsSelected));
        var i = rowsSelected.length;
        while (i--) {
            var found = existingRecords.find(o => o.sid === rowsSelected[i].sid)
            if (found != undefined){
               existingRecords.splice(i,1);
            }
        }
        */
        component.set("v.objectList", rowsSelected);
        component.set("v.objectListSize", rowsSelected.length.toString());
    },
    initmap: function (component, event, helper) {
        component.set("v.mapMarkers", []);
        /*component.set('v.center', {
            location: {
                City: 'London'
            }
        });*/
        
        component.set("v.zoomLevel", 15);
        component.set("v.markersTitle", "Records from the search: ");
        component.set("v.showFooter", true);
    },
    loadBusinessCentres: function (component, event, helper, locationkey) {
        console.log("loadBusinessCentres");
        
        component.set("v.showError", false);
        component.set("v.showSpinner", true);
        var locMaps = component.get("v.locationMap");
        //console.log('Dentro loadBusinessCentres');
        //console.log(locMaps[locationkey]);
        //console.log(JSON.stringify(locMaps[locationkey]));
        
        var action = component.get("c.getBusinessCentres");
        action.setParam("locationJSON", JSON.stringify(locMaps[locationkey]));
        action.setParam("pagesize", "100");
        action.setParam("radius", "5");
        action.setParam("recordId", component.get("v.recordId"));
        //action.setParam("option" ,"Geo");
        
        action.setCallback(this, function (data) {
            var state = data.getState();
            var mergeResult = [];
            if (state === "SUCCESS") {
                //$A.get('e.force:refreshView').fire();
                //console.log(data.getReturnValue());
                mergeResult.push.apply(mergeResult, data.getReturnValue());
                //component.set('v.objectList',helper.FormatDataTable(data.getReturnValue()));
                //component.set('v.objectListSize',data.getReturnValue().length.toString());
                
                //console.log('Number of Records:' + mergeResult.length);
                console.log("Merge data is:" + JSON.stringify(mergeResult));
                var markers = [];
                var enhancedRecords = [];
                
                var vfOrigin = "https://" + window.location.hostname;
                
                //TODO.. we think the map only can show 100 markers.. we need to test it. If yes.. should control the for to 100
                for (var i = 0; i < mergeResult.length; i++) {
                    //var BC = mergeResult[i];
                    markers.push({
                        location: {
                            Latitude: mergeResult[i].latitude,
                            Longitude: mergeResult[i].longitude,
                            Street: mergeResult[i].street,
                            City: mergeResult[i].city,
                            PostalCode: mergeResult[i].postalCode,
                            State: mergeResult[i].state,
                            Country: mergeResult[i].country
                        },
                        icon:
                        mergeResult[i].enhanced == true
                        ? "standard:contract_line_item"
                        : "standard:account",
                        title: mergeResult[i].name + " (" + mergeResult[i].bccompany + ")",
                        // description: helper.getDescription(
                        //     mergeResult[i].name,
                        //     vfOrigin,
                        //     mergeResult[i].BusinessCentreId,
                        //     mergeResult[i].distance,
                        //     mergeResult[i].phone,
                        //     mergeResult[i].stype,
                        //     mergeResult[i].primaryImage,
                        //     mergeResult[i].url,
                        //     mergeResult[i].paymentAd
                        // ),
                        details: {
                            title: mergeResult[i].name + " (" + mergeResult[i].bccompany + ")",
                            bcCompany: mergeResult[i].name,
                            bcId: mergeResult[i].BusinessCentreId,
                            // distance: mergeResult[i].distance,
                            phone: mergeResult[i].phone,
                            imageUrl: mergeResult[i].primaryImage,
                            webUrl: mergeResult[i].url,
                            subscription: mergeResult[i].subscription
                            // ,
                            // paymentAd: mergeResult[i].paymentAd
                        },
                        value: mergeResult[i].BusinessCentreId
                    });
                    // EMPAUA: IS KEY PROVIDER CASE 15/11/2022
                    // EMPAUA: IS KEY subscription CASE 14/12/2022
                    if (mergeResult[i].isEnhanced || mergeResult[i].isKeyProviderBC || mergeResult[i].subscription) {
                        enhancedRecords.push(mergeResult[i]);
                    }
                }
                //Set enhanced Records in the Basket
                var existingRecords = component.get("v.objectList");
                
                for (var i = 0; i < enhancedRecords.length; i++) {
                    var found = existingRecords.find(
                        (o) => o.BusinessCentreId === enhancedRecords[i].BusinessCentreId
                    );
                    if (found === undefined) {
                        existingRecords.push(enhancedRecords[i]);
                    }
                }
                
                //component.set('v.objectList',existingRecords);
                component.set("v.objectList", helper.FormatDataTable(existingRecords));
                //component.set('v.objectList',helper.FormatDataTable(enhancedRecords));
                //Set Markers
                component.set("v.mapMarkers", markers);
                //Set result List
                component.set("v.resultList", helper.FormatDataTable(mergeResult));
            } else if (state === "ERROR") {
                var errors = data.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.showError", true);
                        component.set("v.errorMessage", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
            //Update Center Point
            console.log("Center point for the locationD");
            console.log(locMaps[locationkey].longitude);
            console.log(locMaps[locationkey].latitude);
            
            /* component.set('v.center', {
            location: {
               latitude: locMaps[locationkey].latitude,
               longitude: locMaps[locationkey].longitude
            }
            });*/
            
            component.set(
                "v.centerString",
                "{location: {Latitude: '" +
                locMaps[locationkey].latitude +
                "', Longitude: '" +
                locMaps[locationkey].longitude +
                "',},}"
            );
            
            component.set("v.zoomLevel", 6);
            
            component.set("v.showSpinner", false);
            
            return mergeResult;
        });
        $A.enqueueAction(action);
    },
    getDescription: function (
        BCName,
        vfOrigin,
        BCId,
        // distance,
        Phone,
        type,
        imageUrl,
        url
        // ,
        // paymentad
    ) {
        /*
        var strreturn = '<div align="left" style="with=150px">';
        strreturn += '<div><a title="Add" href="javascript:void(0)" onclick="parent.postMessage({\'key\':\'EMP\',\'action\':\'add\',\'value\':\''+ BCId +'\'},\''+ vfOrigin +'\');">';
        strreturn += '<img src="https://flexioffices--c.eu30.visual.force.com/resource/1580197515000/AgentSearchAdd" style="height: 15px; padding: 5px;float: left;" /></a></div>';

        strreturn += '<div><a title="Remove" href="javascript:void(0)" onclick="parent.postMessage({\'key\':\'EMP\',\'action\':\'remove\',\'value\':\''+ BCId +'\'},\''+ vfOrigin +'\');">';
        strreturn += '<img src="https://flexioffices--c.eu30.visual.force.com/resource/1580197611000/AgentSearchRemove" style="height: 15px; padding: 5px;float: left;" /></a></div>';

        strreturn += '<div><a title="Web" target="_blank" href="'+ url +'" onClick="">';
        strreturn += '<img src="https://flexioffices--c.eu30.visual.force.com/resource/1580197664000/AgentSearchWeb" style="height: 15px; padding: 5px;float: left;" /></a></div>';

        strreturn += '<div><a title="CRM" target="_blank" href='+ vfOrigin + '/' + BCId +' onClick="">';
        strreturn += '<img src="https://flexioffices--c.eu30.visual.force.com/resource/1580197700000/AgentSearchCRM" style="height: 15px; padding: 5px;float: left;" /></a></div>';
        strreturn += '</div></br>';

        strreturn += '<div align="left" style="with=150px">'; 
            strreturn += '<div><b>Distance:</b> '+ distance + '</br><b>Type:</b> ' + type;
            strreturn += '</br><b>Lower:</b> ' + lower + '</br><b>BC Company:</b> '+BCName+'</br><b>Payment Ad: </b>' + paymentad+ '</div>';
        strreturn += '</div></br>';

        

        strreturn += '<div style="with=150px"><div><img src="'+ imageUrl +'" width="150px" /></div></div>';
        */
        
        var strreturn = "<table><tr>";
        strreturn +=
            "<td><a title=\"Add\" href=\"javascript:void(0)\" onclick=\"parent.postMessage({'key':'EMP','action':'add','value':'" +
            BCId +
            "'},'" +
            vfOrigin +
            "');\">";
        strreturn +=
            '<img src="https://flexioffices--c.eu30.visual.force.com/resource/1580197515000/AgentSearchAdd" style="height: 15px; padding: 5px;float: left;" /></a></td>';
        
        strreturn +=
            "<td><a title=\"Remove\" href=\"javascript:void(0)\" onclick=\"parent.postMessage({'key':'EMP','action':'remove','value':'" +
            BCId +
            "'},'" +
            vfOrigin +
            "');\">";
        strreturn +=
            '<img src="https://flexioffices--c.eu30.visual.force.com/resource/1580197611000/AgentSearchRemove" style="height: 15px; padding: 5px;float: left;" /></a></td>';
        
        strreturn += '<td><a title="Web" target="_blank" href="' + url + '" onClick="">';
        strreturn +=
            '<img src="https://flexioffices--c.eu30.visual.force.com/resource/1580197664000/AgentSearchWeb" style="height: 15px; padding: 5px;float: left;" /></a></td>';
        
        strreturn +=
            '<td><a title="CRM" target="_blank" href=' + vfOrigin + "/" + BCId + ' onClick="">';
        strreturn +=
            '<img src="https://flexioffices--c.eu30.visual.force.com/resource/1580197700000/AgentSearchCRM" style="height: 15px; padding: 5px;float: left;" /></a></td>';
        strreturn += "</td></tr></table>";
        
        strreturn += "<table>";
        // strreturn += "<tr><td><b>Distance:</b> " + distance + "</td></tr>";
        strreturn += "<tr><td><b>Type:</b> " + type + "</td></tr>";
        strreturn += "<tr><td><b>Phone:</b> " + Phone + "</td></tr>";
        strreturn += "<tr><td><b>BC Company:</b> " + BCName + "</td></tr>";
        // strreturn += "<tr><td><b>Payment Ad: </b>" + paymentad + "</td></tr>";
        strreturn += "</table>";
        
        strreturn += '<div><img src="' + imageUrl + '" width="150px" /></div>';
        
        return strreturn;
    },
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.resultList");
        var reverse = sortDirection !== "asc";
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.resultList", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
        ? function (x) {
            return primer(x[field]);
        }
        : function (x) {
            return x[field];
        };
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return (a = key(a)), (b = key(b)), reverse * ((a > b) - (b > a));
        };
    },
    UpdateOptionsRows: function (component, event, helper) {
        console.log("UpdateOptionsRows");
        var selectedRows = event.getParam("selectedRows");
        var setRows = [];
        for (var i = 0; i < selectedRows.length; i++) {
            setRows.push(selectedRows[i]);
        }
        //console.log(setRows);
        component.set("v.rowsSelected", setRows);
    },
    UpdateSelectionRows: function (component, event, helper) {
        console.log("UpdateSelectionRows");
        var selectedRows = event.getParam("selectedRows");
        var setRows = [];
        for (var i = 0; i < selectedRows.length; i++) {
            setRows.push(selectedRows[i]);
        }
        component.set("v.basketSelected", setRows);
    },
    saveDataTableEdits: function (component, event, helper) {
        component.set("v.showError", false);
        var action = component.get("c.finishNoEmails");
        
        var existingRecords = component.get("v.objectList");
        
        existingRecords.forEach(item => {
            existingRecords.sendToB = false;
            existingRecords.sendToC = false;
        })
            
            //var lstAccoounts = component.get("v.objectList");
            var lstAccoounts = existingRecords;
            action.setParam("recordId", component.get("v.recordId"));
            action.setParam("recordsList", JSON.stringify(lstAccoounts));
            
            action.setCallback(this, function (data) {
            var state = data.getState();
            if (state === "SUCCESS" && data.getReturnValue) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
            type: "success",
            title: "Edit complete",
            message: "Records saved successfully"
        });
        resultsToast.fire();
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: component.get("v.recordId"),
            slideDevName: "detail"
        });
        navEvt.fire();
    } else if (state === "ERROR") {
    var errors = data.getError();
    
    if (errors) {
    if (errors[0] && (errors[0].message || errors[0].pageErrors[0].message)) {
    console.log(
    "Error Saving : " + errors[0].message + errors[0].pageErrors[0].message
    );
    var strerror = "Error Saving : ";
    if (errors[0].message !== undefined && errors[0].message !== "undefined") {
    strerror = errors[0].message;
}
 if (
 errors[0].pageErrors[0].message !== undefined &&
 errors[0].pageErrors[0].message !== "undefined"
) {
    strerror += errors[0].pageErrors[0].message;
}
component.set("v.showError", true);
component.set("v.errorMessage", strerror);
}
} else {
    console.log("Unknown error");
}
} else if (data.getReturnValue === false) {
    console.log("Error en Apex");
}
});
$A.enqueueAction(action);
},
    saveDataTable: function (component, event, helper) {
        console.log("saveDataTable");
        //Not use because we are hidding the buttons and merging draftvalues before saving.
        //merge draftvalues with existing records using row index
        var draftValues = event.getParam("draftValues");
        var existingRecords = component.get("v.objectList");
        for (var i = 0; i < draftValues.length; i++) {
            let strnumber = draftValues[i].id;
            let result = strnumber.replace("row-", "");
            if (draftValues[i].sendToB !== "undefined" && draftValues[i].sendToB !== undefined) {
                console.log("dentro sendToB:" + result);
                existingRecords[Number(result)].sendToB = draftValues[i].sendToB;
            }
            if (draftValues[i].sendToC !== "undefined" && draftValues[i].sendToC !== undefined) {
                console.log("dentro sendToC:" + result);
                existingRecords[Number(result)].sendToC = draftValues[i].sendToC;
            }
        }
        component.set("v.objectList", existingRecords);
        //Hide cancel and save buttons
        component.find("basketTable").set("v.draftValues", null);
    },
        saveIntroductions: function (component, event, helper) {
            
            component.set("v.showError", false);
            console.log("Save intros");
            var action = component.get("c.finish");
            
            var clickedButton = event.getSource();
            var buttonAuraId = clickedButton.getLocalId(); // This gets the aura:id
            var selectedRows = component.get("v.basketSelected");
            
            console.log('selectedRows>>>'+JSON.stringify(selectedRows));
            
            let sendToB = false;
            let sendToC = false;
            
            if(buttonAuraId == 'sendToClientButton'){
                sendToC = true;
            }else if(buttonAuraId == 'sendToBButton'){
                sendToB = true;
            }else if(buttonAuraId == 'sendToBothButton'){
                sendToC = true;
                sendToB = true;
            }
            
            //Review draft values
            //var draftValues = component.find("basketTable").get("v.draftValues");
            
            //var existingRecords = component.get("v.objectList");
            
            /*for (var i = 0; i < draftValues.length; i++) {
            let strnumber = draftValues[i].id;
            let result = strnumber.replace("row-", "");

            if(existingRecords[Number(result)] != null) {
                console.log("draftValues[i].sendToB" + draftValues[i].sendToB);
                console.log("draftValues[i].sendToC" + draftValues[i].sendToC);
                if (draftValues[i].sendToB !== "undefined" && draftValues[i].sendToB !== undefined) {
                    console.log("dentro sendToB:" + result);
                    existingRecords[Number(result)].sendToB = draftValues[i].sendToB;
                }
                if (draftValues[i].sendToC !== "undefined" && draftValues[i].sendToC !== undefined) {
                    console.log("dentro sendToC:" + result);
                    existingRecords[Number(result)].sendToC = draftValues[i].sendToC;
                }
            }
        }*/
        for (var i = 0; i < selectedRows.length; i++) {
            // Append sendToB and sendToC properties with values 
            selectedRows[i].sendToB = sendToB;  // Or true based on some logic
            selectedRows[i].sendToC = sendToC;   // Or false based on some logic
        }
        
        
        //var lstAccoounts = component.get("v.objectList");
        var lstAccoounts = selectedRows;
        console.table(JSON.stringify(lstAccoounts));
        action.setParam("recordId", component.get("v.recordId"));
        action.setParam("recordsList", JSON.stringify(lstAccoounts));
        
        action.setCallback(this, function (data) {
            var state = data.getState();
            console.log("state");
            console.log(state);
            if (state === "SUCCESS" && data.getReturnValue) {
                console.log("Saved");
                console.log("data.getReturnValue" + JSON.stringify(data.getReturnValue));
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    type: "success",
                    title: "Creating new introductions",
                    message: "Records saved successfully"
                });
                resultsToast.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    recordId: component.get("v.recordId"),
                    slideDevName: "detail"
                });
                navEvt.fire();
            } else if (state === "ERROR") {
                console.log("Error");
                var errors = data.getError();
                
                if (errors) {
                    if (errors[0] && (errors[0].message || errors[0].pageErrors[0].message)) {
                        console.log(
                            "Error Saving : " + errors[0].message + errors[0].pageErrors[0].message
                        );
                        var strerror = "Error Saving : ";
                        if (errors[0].message !== undefined && errors[0].message !== "undefined") {
                            strerror = errors[0].message;
                        }
                        if (
                            errors[0].pageErrors[0].message !== undefined &&
                            errors[0].pageErrors[0].message !== "undefined"
                        ) {
                            strerror += errors[0].pageErrors[0].message;
                        }
                        component.set("v.showError", true);
                        component.set("v.errorMessage", strerror);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else if (data.getReturnValue === false) {
                console.log("Error en Apex");
            }
        });
        $A.enqueueAction(action);
    },
        getAutomaticIntros: function (component, event, helper) {
            var action = component.get("c.getAutomaticIntros");
            action.setParam("recordId", component.get("v.recordId"));
            
            action.setCallback(this, function (data) {
                var state = data.getState();
                if (state === "SUCCESS") {
                    //component.set('v.objectList',existingRecords);
                    component.set("v.objectList", helper.FormatDataTable(data.getReturnValue()));
                } else if (state === "ERROR") {
                    var errors = data.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        },
            loadRecord: function (component, event, helper) {
                console.log("Dentro de load Record");
                console.log(component.get("v.recordId"));
                
                var action = component.get("c.getRecordInfo");
                action.setParam("recordId", component.get("v.recordId"));
                
                action.setCallback(this, function (data) {
                    var state = data.getState();
                    if (state === "SUCCESS") {
                        component.set("v.recordName", data.getReturnValue());
                    } else if (state === "ERROR") {
                        var errors = data.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            },
                saveModalRecord: function (component, event, helper) {
                    // TODO
                    var selectedTermLength = component.get("v.row.termLength");
                    var selectedAvailableFrom = component.get("v.row.availableFrom");
                    var selectedOptionSize = component.get("v.row.optionSize");
                    var selectedMonthlyQuotingRate = component.get("v.row.monthlyQuotingRate");
                    var selectedMonthlyCostOccupation = component.get("v.row.monthlyCostOccupation");
                    console.log("Dentro de saveModalRecord");
                    var row = component.get("v.row");
                    var data = component.get("v.objectList");
                    console.log(row);
                    
                    var index = data.indexOf(row);
                    if (index != -1) {
                        data[index].termLength = selectedTermLength;
                        data[index].abrTermLength = selectedTermLength
                        ? selectedTermLength.substring(0, 5) + "..."
                        : "";
                        data[index].availableFrom = selectedAvailableFrom;
                        data[index].abrAvailableFrom = selectedAvailableFrom
                        ? selectedAvailableFrom.substring(0, 5) + "..."
                        : "";
                        data[index].optionSize = selectedOptionSize;
                        data[index].abrOptionSize = selectedOptionSize
                        ? selectedOptionSize.substring(0, 5) + "..."
                        : "";
                        data[index].monthlyQuotingRate = selectedMonthlyQuotingRate;
                        data[index].abrMonthlyQuotingRate = selectedMonthlyQuotingRate
                        ? selectedMonthlyQuotingRate.substring(0, 5) + "..."
                        : "";
                        data[index].monthlyCostOccupation = selectedMonthlyCostOccupation;
                        data[index].abrMonthlyCostOccupation = selectedMonthlyCostOccupation
                        ? selectedMonthlyCostOccupation.substring(0, 5) + "..."
                        : "";
                    }
                    
                    console.log(data);
                    
                    component.set("v.objectList", data);
                    
                    helper.returnBack(component, event, helper);
                },
                    returnBack: function (component, event, helper) {
                        component.set("v.termLengthRender", false);
                        component.set("v.availableFromRender", false);
                        component.set("v.optionSizeRender", false);
                        component.set("v.monthlyQuotingRateRender", false);
                        component.set("v.monthlyCostOccupationRender", false);
                        component.set("v.isModalOpen", false);
                        component.set("v.row", "");
                    },
                        showEditModal: function (component, event, row) {
                            //Set Row
                            component.set("v.row", row);
                            console.log('Row>>> ' + JSON.stringify(row));
                            
                            let actionName = event.getParam("action").name;
                            //Set Field Render
                            switch (actionName) {
                                case "edit_term_length":
                                    component.set("v.termLengthRender", true);
                                    component.set("v.isModalOpen", true);
                                    break;
                                case "edit_available_from":
                                    component.set("v.availableFromRender", true);
                                    component.set("v.isModalOpen", true);
                                    break;
                                case "edit_option_size":
                                    component.set("v.optionSizeRender", true);
                                    component.set("v.isModalOpen", true);
                                    break;
                                case "edit_monthly_quoting_rate":
                                    component.set("v.monthlyQuotingRateRender", true);
                                    component.set("v.isModalOpen", true);
                                    break;
                                case "edit_monthly_cost_occupation":
                                    component.set("v.monthlyCostOccupationRender", true);
                                    component.set("v.isModalOpen", true);
                                    break;
                            }
                        },
                            getCountryPicklist: function (component, event, helper) {
                                var action = component.get("c.getPickListMap");
                                
                                action.setCallback(this, function (data) {
                                    var state = data.getState();
                                    if (state === "SUCCESS") {
                                        //component.set("v.countryPicklist",data.getReturnValue());
                                        var arrayOfMapKeys = [];
                                        var StoreResponse = data.getReturnValue();
                                        
                                        component.set("v.countrymap", StoreResponse);
                                        console.log(JSON.stringify(data.getReturnValue()));
                                        for (var singlekey in StoreResponse) {
                                            arrayOfMapKeys.push(singlekey);
                                        }
                                        // Set the all list of keys on component attribute, which name is lstKey and type is list.
                                        component.set("v.countryPicklist", arrayOfMapKeys);
                                    } else if (state === "ERROR") {
                                        var errors = data.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                console.log("Error message: " + errors[0].message);
                                            }
                                        } else {
                                            console.log("Unknown error");
                                        }
                                    }
                                });
                                $A.enqueueAction(action);
                                
                                helper.getCountry(component, event, helper);
                            },
                                getCountry: function (component, event, helper) {
                                    var action = component.get("c.getCountry");
                                    
                                    action.setCallback(this, function (data) {
                                        var state = data.getState();
                                        if (state === "SUCCESS") {
                                            console.log(data.getReturnValue());
                                            component.set("v.selectedValue", data.getReturnValue());
                                        } else if (state === "ERROR") {
                                            var errors = data.getError();
                                            if (errors) {
                                                if (errors[0] && errors[0].message) {
                                                    console.log("Error message: " + errors[0].message);
                                                }
                                            } else {
                                                console.log("Unknown error");
                                            }
                                        }
                                    });
                                    $A.enqueueAction(action);
                                }
/*loadData : function (component, event, helper) {
        
        console.log('LoadData');
        var mergeResult = [];
        console.log('EnhanceListingLoad');
        var actionEL = component.get("c.getBusinessCentres");
        actionEL.setParam("locationId" ,component.get("v.locationId"));

        actionEL.setCallback(this, function(data) {
            
            var state = data.getState();
            var result = [];
            if (state === "SUCCESS") {
                mergeResult.push.apply(mergeResult,data.getReturnValue());
                component.set('v.objectList',helper.FormatDataTable(data.getReturnValue()));
                component.set('v.objectListSize',data.getReturnValue().length.toString());

            }else if (state === "ERROR") {
                var errors = data.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }

            return result;
       
        });
        $A.enqueueAction(actionEL);

        console.log('BC query');
        var action = component.get("c.getBCList");
        action.setParam("recordId" ,component.get("v.recordId"));
        
        var vfOrigin =  "https://" + window.location.hostname; 
       
        action.setCallback(this, function(data) {
           
           var state = data.getState();
           if (state === "SUCCESS") {
                console.log('BC Data is:' + JSON.stringify(data.getReturnValue()));
                var rowsSelected = data.getReturnValue();
                for (var i = 0; i < rowsSelected.length; i++){
                    var found = mergeResult.find(o => o.BusinessCentreId === rowsSelected[i].BusinessCentreId)
                    if (found === undefined){
                        mergeResult.push(rowsSelected[i]);
                    }
                }  
                //mergeResult.push.apply(mergeResult,data.getReturnValue());
           }else if (state === "ERROR") {
             var errors = data.getError();
             if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
             } else {
                console.log("Unknown error");
             }
           }
          
           console.log('Number of Records:' + mergeResult.length);
           console.log('Merge data is:' + JSON.stringify(mergeResult));
           var markers = [];
           for (var i = 0; i < mergeResult.length; i++) {
                
                //var BC = mergeResult[i];
                markers.push({
                    'location': {
                         'Latitude'  : mergeResult[i].latitude,
                         'Longitude' : mergeResult[i].longitude,
                         'Street'    : mergeResult[i].street,
                         'City'      : mergeResult[i].city,
                         'PostalCode': mergeResult[i].postalCode,
                         'State'     : mergeResult[i].state,
                         'Country'   : mergeResult[i].country,
                    },
                    'icon': (mergeResult[i].enhanced == true)?'standard:contract_line_item':'standard:account',
                    'title' : mergeResult[i].name,
                    'description' : helper.getDescription(mergeResult[i].name,vfOrigin,mergeResult[i].sid, mergeResult[i].distance, mergeResult[i].lower, mergeResult[i].stype,mergeResult[i].primaryImage)
               });
               
           }
          
           component.set('v.mapMarkers', markers);
           component.set('v.resultList',helper.FormatDataTable(mergeResult));
        });
        $A.enqueueAction(action);
       
    }*/
});