({
    initReference: function (component, event, helper) {
        var action = component.get("c.initReferencesIds");
  console.log('***JSON.stringify(component.get("v.introListJSON")) ' + JSON.stringify(component.get("v.introListJSON")));
        action.setParam(
            "recordsIdsJSON",
            JSON.stringify(component.get("v.introListJSON"))
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log("state" + state);
            if (state == "SUCCESS") {
                var referenceIds = [];
                referenceIds = JSON.parse(response.getReturnValue());
                console.log("Load references");
                console.log(referenceIds);

                component.set("v.clientId", referenceIds[0]);
                component.set("v.oppId", referenceIds[1]);
                component.set("v.leadId", referenceIds[2]);
            } else {
                console.log("Error aqui");
                var error = new String();
                var errArr = response.getError();

                if (errArr) {
                    for (var i in errArr)
                        error += "\u2022 " + errArr[i].message + "\r\n";
                } else {
                    error = "An Unknown Error Occurred.";
                }

                //self.setMessage(component, 'error', 'An Error Occurred', error);
                console.log(error);
            }
        });

        $A.enqueueAction(action);
    },
    initBusinessCentres: function (component, event, helper) {
        var action = component.get("c.initBusinessCentresList");
        action.setParam(
            "recordsIdsJSON",
            JSON.stringify(component.get("v.introListJSON"))
        );

        action.setCallback(this, function (response) {
            console.log("vuelta");
            var state = response.getState();
            console.log("state" + state);
            if (state == "SUCCESS") {
                console.log("Sucess Set BC");
                console.log(response.getReturnValue());
                component.set("v.BCList", response.getReturnValue());
                //Load Data
                helper.fetchData(component, event, helper);
            } else {
                console.log("Error aqui");
                var error = new String();
                var errArr = response.getError();

                if (errArr) {
                    for (var i in errArr)
                        error += "\u2022 " + errArr[i].message + "\r\n";
                } else {
                    error = "An Unknown Error Occurred.";
                }

                //self.setMessage(component, 'error', 'An Error Occurred', error);
                console.log(error);
            }
        });

        $A.enqueueAction(action);
    },
    fetchHeader: function (component, event, helper) {
        var action = component.get("c.getHeaderInfo");
        action.setParam("viewSchId", component.get("v.viewingScheduleId"));
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                var resultArray = [];
                resultArray = response.getReturnValue();
                console.log("getHeaderInfo");
                var today;

                if (resultArray[0] !== "null") {
                    today = $A.localizationService.formatDate(
                        new Date(resultArray[0]),
                        "YYYY-MM-DD"
                    );
                } else {
                    today = $A.localizationService.formatDate(
                        new Date(),
                        "YYYY-MM-DD"
                    );
                }

                console.log(resultArray[0]);
                console.log(today);

                component.set("v.today", today);

                if (resultArray[1] !== "null") {
                    component.set("v.emailText", resultArray[1]);
                }
                //2019-06-27
            } else {
                var error = new String();
                var errArr = response.getError();

                if (errArr) {
                    for (var i in errArr)
                        error += "\u2022 " + errArr[i].message + "\r\n";
                } else {
                    error = "An Unknown Error Occurred.";
                }

                //self.setMessage(component, 'error', 'An Error Occurred', error);
                console.log(error);
            }
        });

        $A.enqueueAction(action);
    },
    fetchData: function (component, event, helper) {
        console.log("Dentro Fetch");
        //var self = this;
        console.log(component.get("v.BCList"));
        var action = component.get("c.getviewingLines");

        console.log("Before fetch data");
        console.log(JSON.stringify(component.get("v.OrderJSON")));

        action.setParam(
            "accountIds",
            JSON.stringify(component.get("v.BCList"))
        );
        action.setParam(
            "orderJSON",
            JSON.stringify(component.get("v.OrderJSON"))
        );
        action.setParam("viewSchId", component.get("v.viewingScheduleId"));

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                console.log("Sucess Fetch");
                console.log("Sucess BCList" + component.get("v.BCList"));

                //Set BCList first time
                var centresArray = [];
                var orderArray = [];

                centresArray = component.get("v.BCList");
                orderArray = component.get("v.OrderJSON");

                var createCentresArray = false;
                var createOrdersArray = false;

                console.log("delcaradas");
                console.log(orderArray);

                if (centresArray.length == 0) {
                    console.log("delcaradas2");
                    createCentresArray = true;
                }

                console.log("delcaradas3");

                if (typeof orderArray !== "undefined") {
                } else {
                    orderArray = [];
                    createOrdersArray = true;
                }

                console.log("createCentresArray" + createCentresArray);
                console.log("createOrdersArray" + createOrdersArray);

                if (createCentresArray || createOrdersArray) {
                    console.log("dentro del crear");

                    var resultArray = [];
                    resultArray = response.getReturnValue();

                    console.log(resultArray);

                    for (var i = 0; i < resultArray.length; i++) {
                        if (createOrdersArray) {
                            orderArray.push({
                                bcId: resultArray[i].bcId,
                                order: resultArray[i].order,
                                stime: resultArray[i].stime
                            });
                        }
                        if (createCentresArray) {
                            centresArray.push(resultArray[i].bcId);
                        }
                    }

                    console.log("orderArray" + JSON.stringify(orderArray));

                    if (createOrdersArray) {
                        component.set("v.OrderJSON", orderArray);
                    }
                    if (createCentresArray) {
                        component.set("v.BCList", centresArray);
                    }
                }
                component.set(
                    "v.data",
                    helper.FormatDataTable(response.getReturnValue())
                );
                helper.sortData(component, "order", "asc");
            } else {
                var error = new String();
                var errArr = response.getError();

                if (errArr) {
                    for (var i in errArr)
                        error += "\u2022 " + errArr[i].message + "\r\n";
                } else {
                    error = "An Unknown Error Occurred.";
                }

                //self.setMessage(component, 'error', 'An Error Occurred', error);
                console.log(error);
            }
        });

        $A.enqueueAction(action);
    },
    initDatatable: function (component, event, helper) {
        setTimeout(function () {
            var table = $("#tableId").DataTable({
                columnDefs: [
                    {
                        targets: [1],
                        visible: false,
                        searchable: false
                    }
                ],
                rowReorder: true,
                paging: false,
                searching: false,
                info: false
            });
            // add lightning class to search filter field with some bottom margin..
            $("div.dataTables_filter input").addClass("slds-input");
            $("div.dataTables_filter input").css("marginBottom", "10px");
            console.log("dentro del time out");
        }, 50);
    },
    setDatatable: function (component, event, helper) {
        //{label: 'Time', initialWidth:100, fieldName: 'vtime',type: "date",typeAttributes:{hour: "2-digit", minute: "2-digit"}, sortable:false, editable: false },

        //Define Columns
        component.set("v.columns", [
            {
                label: "N",
                initialWidth: 70,
                cellAttributes: { alignment: "center" },
                fieldName: "order",
                type: "number",
                editable: false,
                sortable: true
            },
            {
                label: "Center",
                initialWidth: 250,
                fieldName: "CenterLink",
                editable: false,
                type: "url",
                sortable: true,
                typeAttributes: {
                    label: { fieldName: "bcName" },
                    target: "_blank"
                }
            },
            {
                label: "Time",
                type: "button",
                initialWidth: 135,
                typeAttributes: {
                    label: { fieldName: "stime" },
                    name: "edit_time",
                    iconName: "utility:edit",
                    title: "Edit time"
                }
            },
            {
                label: "Centre Manager",
                initialWidth: 250,
                fieldName: "ManagerLink",
                editable: false,
                type: "url",
                sortable: true,
                typeAttributes: {
                    label: { fieldName: "manager" },
                    target: "_blank"
                }
            },
            {
                label: "",
                type: "button",
                initialWidth: 80,
                typeAttributes: {
                    label: "",
                    name: "edit_contact",
                    iconName: "utility:edit",
                    title: "Edit Contact"
                }
            },
            {
                label: "Secondary Contact",
                initialWidth: 250,
                fieldName: "ContactLink",
                editable: false,
                type: "url",
                sortable: true,
                typeAttributes: {
                    label: { fieldName: "secondaryContact" },
                    target: "_blank"
                }
            },
            {
                label: "Phone",
                initialWidth: 100,
                fieldName: "managerphone",
                type: "text",
                sortable: true,
                editable: false
            },
            {
                label: "Email",
                initialWidth: 175,
                fieldName: "manageremail",
                type: "text",
                sortable: true,
                editable: false
            },
            {
                label: "Address",
                initialWidth: 250,
                fieldName: "address",
                type: "text",
                sortable: true,
                editable: false
            },
            {
                label: "Location",
                initialWidth: 125,
                fieldName: "location",
                type: "text",
                sortable: true,
                editable: false
            },
            {
                label: "Notes",
                type: "button",
                typeAttributes: {
                    label: { fieldName: "abrNotes" },
                    name: "edit_notes",
                    iconName: "utility:edit",
                    title: { fieldName: "notes" }
                }
            }
        ]);
    },
    FormatDataTable: function (rows) {
        //Format relation and URL values of the Table, adding class to control background color
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            if (row.bcId) {
                row.CenterLink = "/" + row.bcId;
            }

            if (row.managerId) {
                row.ManagerLink = "/" + row.managerId;
            }

            if (row.secondaryContactId) {
                row.ContactLink = "/" + row.secondaryContactId;
            }

            if (row.notes) {
                if (row.notes.length > 15) {
                    row.abrNotes = row.notes.substring(0, 15) + "...";
                } else {
                    row.abrNotes = row.notes;
                }
            }
        }

        return rows;
    },
    updateSelectedRows: function (component, event, helper) {
        var selectedRows = event.getParam("selectedRows");
        var setRows = [];
        for (var i = 0; i < selectedRows.length; i++) {
            setRows.push(selectedRows[i].bcId);
        }
        console.log(setRows);
        component.set("v.rowsSelected", setRows);
        console.log("Dentro de update selections" + setRows);
    },
    removeItems: function (component, event, helper) {
        if (confirm("Do you want to delete selected Viewings?")) {
            var rowsSelected = component.get("v.rowsSelected");

            console.log("rowsSelected" + rowsSelected);

            //Delete from JSON

            var currentRecords = component.get("v.BCList");

            console.log("BCList" + currentRecords);

            for (let i = 0; i < rowsSelected.length; i++) {
                console.log(rowsSelected[i]);
                //delete currentRecords[rowsSelected[i]];
            }

            var diff = currentRecords
                .concat(rowsSelected)
                .filter(function (e, i, array) {
                    // Check if the element is appearing only once
                    return array.indexOf(e) === array.lastIndexOf(e);
                });

            console.log("Result" + diff);
            component.set("v.BCList", diff);
            helper.fetchData(component, event, helper);
        }
    },
    updateColumnSorting: function (component, event, helper) {
        component.set("v.isLoading", true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout(function () {
            var fieldName = event.getParam("fieldName");
            var sortDirection = event.getParam("sortDirection");
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set("v.isLoading", false);
        }, 0);
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== "asc";

        data = Object.assign(
            [],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
    sendEmailToCustomer: function (component, event, helper) {
        var action = component.get("c.sendEmailViewingSchedule");
        action.setParam("viewSchId", component.get("v.viewingScheduleId"));
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                console.log("Email Send by Workflow");
                /* var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type" : "success",
                    "title": "Email Sent",
                    "message": "Email sent successfully"
                });
                resultsToast.fire();*/
                component.set("v.PageMessage", "Email sent successfully");
            } else {
                var error = new String();
                var errArr = response.getError();

                if (errArr) {
                    for (var i in errArr)
                        error += "\u2022 " + errArr[i].message + "\r\n";
                } else {
                    error = "An Unknown Error Occurred.";
                }

                console.error(error);
            }
        });

        $A.enqueueAction(action);
    },
    
    confirmAttendanceRec: function (component, event, helper, openPreview) {
        var flow = component.find("flowData");
        var inputVariables = [
        {
            name : "recordId",
            type : "String",
            value : component.get("v.viewingScheduleId")
        } 
       ];
        //alert(component.get("v.viewingScheduleId"));
        flow.startFlow("Create_Viewing_Event_Flow",inputVariables);
        component.set("v.PageMessage", "");
        component.set("v.PageMessage", "Viewing has been arranged successfully");
 
    }, 
    
    
    saveViewingScheduleRec: function (component, event, helper, openPreview) {

        component.set("v.showSpinner", true);

        var data = component.get("v.data");
        var action = component.get("c.saveViewingSCH");

        var dateSelected = component.find("vdate").get("v.value");

        action.setParam("clientId", component.get("v.clientId"));
        action.setParam("oppId", component.get("v.oppId"));
        action.setParam("leadId", component.get("v.leadId"));
        action.setParam("dataJSON", JSON.stringify(data));
        action.setParam("dateValue", dateSelected);
        action.setParam("emailText", component.get("v.emailText"));
        action.setParam("viewSchId", component.get("v.viewingScheduleId"));
        component.set("v.PageMessage", "");

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                component.set("v.showSpinner", false);
                component.set("v.viewingScheduleId", response.getReturnValue());
                console.log("ID:" + response.getReturnValue());
                component.set("v.hasViewingSchedule", true);
                component.set("v.PageMessage", "Record saved successfully");
                /*var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type" : "success",
                    "title": "Saved",
                    "message": "Record saved successfully"
                });
                resultsToast.fire();*/

                if (openPreview) {
                    window.open(
                        "/apex/ViewingSchedulePreview?viewingScheduleId=" +
                            component.get("v.viewingScheduleId"),
                        "_blank"
                    );
                }
            } else {
                component.set("v.showSpinner", false);
                var error = new String();
                var errArr = response.getError();

                if (errArr) {
                    for (var i in errArr)
                        error += "\u2022 " + errArr[i].message + "\r\n";
                } else {
                    error = "An Unknown Error Occurred.";
                }

                console.error(error);
                alert(error);
            }
        });

        $A.enqueueAction(action);
    },
    callpreviewEmail: function (component, event, helper) {
        helper.saveViewingScheduleRec(component, event, helper, true);

        //https://flexioffices--empauadev--c.cs105.visual.force.com/apex/ViewingSchedulePreview?viewingScheduleId=a071w000000t8HGAAY
        //Not working in lng:out.. we are using an app because of the VF landing page.
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/ViewingSchedulePreview?viewingScheduleId=" + component.get("v.viewingScheduleId")
        });

        urlEvent.fire();*/

        //window.location = "/apex/ViewingSchedulePreview?viewingScheduleId=" + component.get("v.viewingScheduleId");
    },
    viewOnMapRedirection: function (component, event, helper) {
        var data = component.get("v.data");
        var action = component.get("c.createMapLink");
        action.setParam("viewSchId", component.get("v.viewingScheduleId"));
        action.setParam("dataJSON", JSON.stringify(data));

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                var strLink = response.getReturnValue();
                if (strLink !== "error") {
                    window.open(strLink, "_blank");
                }
            } else {
                var error = new String();
                var errArr = response.getError();

                if (errArr) {
                    for (var i in errArr)
                        error += "\u2022 " + errArr[i].message + "\r\n";
                } else {
                    error = "An Unknown Error Occurred.";
                }

                console.log(error);
            }
        });

        $A.enqueueAction(action);

        //window.open('https://www.google.com/maps/dir/?api=1&origin=40.464074,-3.6920694&destination=40.4642183,-3.6935416&travelmode=walking&waypoints=40.4644325,-3.6930844%7C40.464418,-3.6932079','_blank');
    },
    returnBack: function (component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.isModalTimeOpen", false);
        component.set("v.isModalNotesOpen", false);
        component.set("v.showOrder", false);
        helper.sortData(component, "order", "asc");
    },
    updateTimeLines: function (component, event, helper, blnupdateTime) {
        var jsonArr = [];

        var table = $("#tableId").DataTable();
        var data = table
            .rows()
            .data()
            .each(function (value, index) {
                jsonArr.push({
                    bcId: value[1],
                    order: value[0],
                    stime: value[4],
                    notes: value[5]
                });
                console.log("Data in index: " + index + " is: " + value);
            });

        console.log(blnupdateTime);

        //Set time Interval
        if (blnupdateTime) {
            let initialtime = component.find("vstartime").get("v.value");
            initialtime = initialtime.substring(0, 5);
            let intervaltime = parseInt(
                component.find("vinterval").get("v.value")
            );

            console.log("order");

            var dt = new Date("1980-03-31T" + initialtime);

            for (var i = 0; i < jsonArr.length; i++) {
                initialtime = dt.toLocaleTimeString();
                if (initialtime.length < 8) {
                    initialtime = "0" + initialtime;
                }

                initialtime = initialtime.substring(0, 5);
                jsonArr[i].stime = initialtime;

                dt.setMinutes(dt.getMinutes() + intervaltime);
            }
        }

        component.set("v.OrderJSON", jsonArr);

        helper.fetchData(component, event, helper);
        helper.returnBack(component, event, helper);
    },
    handleDTRowAction: function (component, event, helper) {
        var action = event.getParam("action");
        var row = event.getParam("row");
        console.log(row);
        switch (action.name) {
            case "edit_contact":
                // component.set("v.selectedContactId", "");
                // component.set("v.contactRecordId", row.secondaryContactId);
                // component.set("v.selectedViewingId", row.viewingId);
                helper.showEditManager(component, row);
                break;
            case "edit_time":
                helper.showEditTime(component, row);
                break;
            case "edit_notes":
                helper.showEditNotes(component, row);
                break;
            default:
                helper.showEditManager(component, row);
                break;
        }
    },
    saveTimeRecord: function (component, event, helper) {
        var selectedtime = component.get("v.selectTime");
        console.log(component.get("v.rowupdated"));
        /*var jsonArr = component.get('v.OrderJSON');
        console.log(jsonArr);*/

        var data = component.get("v.data");
        var order = component.get("v.OrderJSON");
        console.log(data);

        /* if(typeof jsonArr !== "undefined"){
            console.log('No es');
        }else{

        }*/

        for (var i = 0; i < data.length; i++) {
            var row = parseInt(component.get("v.rowupdated")) - 1;
            if (i == row) {
                data[i].stime = selectedtime.substring(0, 5);
                order[i].stime = selectedtime.substring(0, 5);
            }
        }

        component.set("v.data", data);
        component.set("v.OrderJSON", order);

        helper.returnBack(component, event, helper);
    },
    saveNotesRecord: function (component, event, helper) {
        var selectedNotes = component.get("v.selectNotes");
        console.log("Dentro de SaveNotesRecord");
        console.log(component.get("v.rowupdated"));

        var data = component.get("v.data");
        var order = component.get("v.OrderJSON");

        for (var i = 0; i < data.length; i++) {
            var row = parseInt(component.get("v.rowupdated")) - 1;
            if (i == row) {
                console.log(data[i].bcName);
                if (selectedNotes.length > 15) {
                    data[i].abrNotes = selectedNotes.substring(0, 15) + "...";
                    order[i].abrNotes = selectedNotes.substring(0, 15) + "...";
                } else {
                    data[i].abrNotes = selectedNotes;
                    order[i].abrNotes = selectedNotes;
                }

                data[i].notes = selectedNotes;
                order[i].notes = selectedNotes;
            }
        }

        component.set("v.data", data);
        component.set("v.OrderJSON", order);

        helper.returnBack(component, event, helper);
    },
    initdate: function (component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.today", today);
    },
    // showEditManager: function (component, row) {
    //     //Set Account
    //     component.set("v.AccountId", row.bcId);
    //     //Set Filter for Contact
    //     component.set("v.FilterContact", "AccountId ='" + row.bcId + "'");
    //     //Open Modal
    //     component.set("v.isModalOpen", true);
    // },
    showEditManager: function (component, row) {
        component.set("v.selectedContactId", null);
        // component.set("v.selectedContactId", row.secondaryContactId);
        component.set("v.rowupdated", row.order);
        component.set("v.isModalOpen", true);
    },
    showEditTime: function (component, row) {
        //Set Account
        component.set("v.selectTime", row.stime);
        component.set("v.rowupdated", row.order);
        component.set("v.BCName", row.bcName);
        component.set("v.isModalTimeOpen", true);
    },
    showEditNotes: function (component, row) {
        //Set Account
        component.set("v.selectNotes", row.notes);
        component.set("v.rowupdated", row.order);
        component.set("v.BCName", row.bcName);

        //Open Modal
        component.set("v.isModalNotesOpen", true);
    },
    updateManager: function (component, event, helper) {
        var xform = "contactForm";
        console.log("despues del form updateManager");
        var sform = component.find(xform);
        console.log("Antes del submit updateManager");
        var response = sform.submit();
    },
    saveManager: function (component, event, helper) {
        var xform = "contactFormNew";
        console.log("despues del form");
        var sform = component.find(xform);
        console.log("Antes del submit");
        var response = sform.submit();
    },
    // UpdateContactRow: function (
    //     component,
    //     event,
    //     helper,
    //     contactId
    // ) {
    //     var action = component.get("c.updateContactRow");
    //     action.setParam("contactId", contactId);
    //     action.setCallback(this, function (data) {
    //         var state = data.getState();
    //         if (state === "SUCCESS") {
    //             helper.fetchData(component, event, helper);
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    UpdateContactRow: function (component, event, helper) {
        var selectedContactId = component.get("v.selectedContactId");
        var data = component.get("v.data");
        var order = component.get("v.OrderJSON");
        const rowIndex = parseInt(component.get("v.rowupdated")) - 1;
        let result;
        let row = data[rowIndex];
        row.secondaryContactId = selectedContactId;
        var action = component.get("c.getContactName");
        if (selectedContactId) {
            action.setParam("contactId", selectedContactId);
            action.setCallback(this, function (result) {
                var state = result.getState();
                if (state === "SUCCESS") {
                    row.secondaryContact = result.getReturnValue();
                    row.ContactLink = "/" + selectedContactId;
                    component.set("v.data", data);
                    component.set("v.OrderJSON", order);
                }
            });
            $A.enqueueAction(action);
        } else {
            row.ContactLink = "";
            row.secondaryContact = "";
        }

        component.set("v.data", data);
        component.set("v.OrderJSON", order);
        helper.returnBack(component, event, helper);
    }
});