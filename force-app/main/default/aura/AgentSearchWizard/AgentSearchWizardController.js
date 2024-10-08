({
    closeModal: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: component.get("v.recordId"),
            slideDevName: "detail"
        });
        navEvt.fire();
        $A.get("e.force:refreshView").fire();
    },
    searchHandler: function (component, event, helper) {
        const searchString = event.target.value;
        if (searchString.length >= 3) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchFunction")) {
                clearTimeout(component.get("v.inputSearchFunction"));
            }

            var inputTimer = setTimeout(
                $A.getCallback(function () {
                    helper.searchRecords(component, searchString);
                }),
                1000
            );
            component.set("v.inputSearchFunction", inputTimer);
        } else {
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
    },
    optionClickHandler: function (component, event, helper) {
        const selectedId = event.target.closest("li").dataset.label;
        const selectedValue = event.target.closest("li").dataset.value;

        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);

        helper.loadBusinessCentres(component, event, helper, selectedValue);
        console.log("selectedValue");
        console.log(selectedValue);
        console.log("after Load Data");
    },
    clearOption: function (component, event, helper) {
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
    },
    //INIT
    init: function (component, event, helper) {
        console.log("Load record info");
        helper.loadRecord(component, event, helper);
        console.log("get Automatic Records");
        helper.getAutomaticIntros(component, event, helper);
        console.log("Call Init map");
        helper.initmap(component, event, helper);
        console.log("addListener");

        if (component.get("v.selectedValue") == null) {
            helper.getCountryPicklist(component, event, helper);
        }

        //if(Object.getOwnPropertyNames(ListenerActiveFlexi) === 'undefined'){
        helper.addListener(component, event, helper);
        //    const ListenerActiveFlexi = {a: 1};
        //}
        console.log("Setup DT");
        helper.setupDatatable(component, event, helper);
        /*console.log('Load Data');
        helper.loadData(component, event, helper);
        console.log('after Load Data');*/
        helper.setupSentIntros(component, event, helper);
    },
    //DATATABLE
    updateColumnSorting: function (component, event, helper) {
        helper.updateColumnSorting(component, event, helper);
    },
    handleDTListRowsSelection: function (component, event, helper) {
        helper.UpdateOptionsRows(component, event, helper);
    },
    handleDTSelectedRowsSelection: function (component, event, helper) {
        helper.UpdateSelectionRows(component, event, helper);
    },
    handleClickAdd: function (component, event, helper) {
        helper.handleClickAdd(component, event, helper);
    },
    handleClickRemove: function (component, event, helper) {
        helper.handleClickRemove(component, event, helper);
    },
    onSave: function (component, event, helper) {
        helper.saveDataTable(component, event, helper);
    },
    handleSaveEdits: function (component, event, helper) {
        helper.saveDataTableEdits(component, event, helper);
    },
    /*handleOptionSelected: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.locationId",selectedOptionValue);
        helper.loadBusinessCentres(component, event, helper,selectedOptionValue);
        console.log('after Load Data');
    },
    //SEARCH BAR
    handleClickSearch: function (component, event, helper) {
      console.log('Search controller');
      helper.searchLocations(component, event, helper);
    },*/
    //VISIBILITY
    openmap: function (component, event, helper) {
        component.set("v.isOpenList", false);
        component.set("v.isOpenMap", true);
        component.set("v.listClass", "display:none");
        component.set("v.mapClass", "display:block");
        console.log("center");
        console.log(component.get("v.center"));
    },
    closemap: function (component, event, helper) {
        component.set("v.isOpenMap", false);
        component.set("v.mapClass", "display:none");
    },
    openlist: function (component, event, helper) {
        component.set("v.isOpenList", true);
        component.set("v.isOpenMap", false);
        component.set("v.mapClass", "display:none");
        component.set("v.listClass", "height:400px;display:block");
    },
    closelist: function (component, event, helper) {
        component.set("v.isOpenList", false);
        component.set("v.listClass", "display:none");
    },
    //SAVE
    saveIntros: function (component, event, helper) {
        helper.saveIntroductions(component, event, helper);
    },
    /*saveIntrosToC: function (component, event, helper) {
        helper.saveIntroductions(component, event, helper);
    },
    saveIntrosToB: function (component, event, helper) {
        helper.saveIntroductions(component, event, helper);
    },*/
    saveIntrosOnlyNew: function (component, event, helper) {
        helper.saveIntroductionsNew(component, event, helper);
    },
    saveModal: function (component, event, helper) {
        helper.saveModalRecord(component, event, helper);
    },
    closeFieldModal: function (component, event, helper) {
        component.set("v.termLengthRender", false);
        component.set("v.availableFromRender", false);
        component.set("v.optionSizeRender", false);
        component.set("v.monthlyQuotingRateRender", false);
        component.set("v.monthlyCostOccupationRender", false);
        component.set("v.isModalOpen", false);
    },
    openModal: function (component, event, helper) {
        var row = event.getParam("row");

        // TODO
        console.log(event.getParam("action").name);

        helper.showEditModal(component, event, row);
    },
    countryChanged: function (component, event, helper) {
        component.set("v.selectedValue", component.find("optionCountry").get("v.value"));
    },

    mapMarkerClicked: function (component, event, helper) {
        const selectedMarker = event.getParam("selectedMarkerValue");
        const markers = component.get("v.mapMarkers");

        const selectedMarkerDetails = markers.find((marker) => {
            return marker.value === selectedMarker;
        });

        console.log(selectedMarkerDetails);
        component.set("v.selectedMarker", selectedMarkerDetails.details);
    },

    closeMapMarker: function (component) {
        component.set("v.selectedMarker", undefined);
    },

    addClicked: function (component, event) {
        const eventId = event.getParam("id");

        console.log("Dentro de Add" + eventId);

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
                if (found === undefined && eventId === resultRecords[i].BusinessCentreId) {
                    existingRecords.push(resultRecords[i]);
                }
            }

            component.set("v.objectListSize", existingRecords.length.toString());
        }
        component.set("v.objectList", existingRecords);
        console.log("Out add");
    },

    removeClicked: function (component, event) {
        var rows = component.get("v.objectList");
        const eventId = event.getParam("id");

        console.log("Dentro remove" + eventId);
        if (rows !== undefined && rows !== "undefined") {
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].BusinessCentreId === eventId) {
                    rows.splice(rows.indexOf(i), 1);
                }
            }

            component.set("v.objectList", rows);
            component.set("v.objectListSize", rows.length.toString());
        }
    }
});