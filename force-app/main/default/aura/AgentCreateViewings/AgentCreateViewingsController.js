({
    init: function (component, event, helper) {
        let schViewRef = component.get("v.viewingScheduleId");

        if (typeof schViewRef !== "undefined") {
            component.set("v.hasViewingSchedule", true);
            component.set("v.hasFlow", false);
            //Load Date and Comments
            helper.fetchHeader(component, event, helper);
            //Load Data
            helper.fetchData(component, event, helper);
        } else {
            //Get clientId, OppId and LeadId
            helper.initReference(component, event, helper);
            //Get Intros selected on previus Step
            let setRecords = component.get("v.introListJSON");
            //Initiazlize Date
            helper.initdate(component, event, helper);
            //Init Business Centres to work with
            helper.initBusinessCentres(component, event, helper);
        }

        //Define Datatable
        helper.setDatatable(component, event, helper);
    },
    return: function (component, event, helper) {
        //window.location.href = '/lightning/o/Contact/list?filterName=Recent';
        window.history.back();
    },
    previewEmail: function (component, event, helper) {
        helper.callpreviewEmail(component, event, helper);
    },
    updateDTSelectedRows: function (component, event, helper) {
        helper.updateSelectedRows(component, event, helper);
    },
    saveViewingSchedule: function (component, event, helper) {
        helper.saveViewingScheduleRec(component, event, helper, false);
    },
    removeDTItems: function (component, event, helper) {
        helper.removeItems(component, event, helper);
    },
    confirmAttendance: function (component, event, helper) {
        helper.confirmAttendanceRec(component, event, helper, false);       
    },  

    statusChange : function (component, event) {
        if (event.getParam('status') === "FINISHED_SCREEN") 
        {
            component.set('v.hasFlow',false);
            $A.get("e.force:refreshView").fire();
        }
    },           
    updateColumnSorting: function (component, event, helper) {
        helper.updateColumnSorting(component, event, helper);
    },
    handleSendEmail: function (component, event, helper) {
        helper.sendEmailToCustomer(component, event, helper);
    },
    isRefreshed: function (component, event, helper) {
        helper.fetchData(component);
    },
    goback: function (component, event, helper) {
        helper.returnBack(component, event, helper);
    },
    goOrderView: function (component, event, helper) {
        component.set("v.showOrder", true);
        helper.initDatatable(component, event, helper);
    },
    saveOrder: function (component, event, helper) {
        helper.saveOrderLines(component, event, helper);
        component.set("v.showOrder", false);
    },
    updateTime: function (component, event, helper) {
        helper.updateTimeLines(component, event, helper, true);
    },
    updateorder: function (component, event, helper) {
        helper.updateTimeLines(component, event, helper, false);
    },
    handleRowAction: function (component, event, helper) {
        console.log("Dentro handleRowAction");
        helper.handleDTRowAction(component, event, helper);
    },
    closeModel: function (component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.isModalTimeOpen", false);
        component.set("v.isModalNotesOpen", false);
    },
    updateManagerDetails: function (component, event, helper) {
        helper.updateManager(component, event, helper);
    },
    saveNewManager: function (component, event, helper) {
        helper.saveManager(component, event, helper);
    },
    handleSuccess: function (component, event, helper) {
        console.log("Dentro de success");
        var recordId = event.getParams().response;
        console.log("recordId " + recordId.id);
        //TODO send Id to controler and update line
        helper.UpdateContactRow(
            component,
            event,
            helper,
            recordId.id,
            component.get("v.AccountId")
        );

        component.set("v.isModalOpen", false);
    },
    scriptsLoaded: function (component, event, helper) {
        console.log("Script Loaded");
    },
    saveTime: function (component, event, helper) {
        helper.saveTimeRecord(component, event, helper);
    },
    saveNotes: function (component, event, helper) {
        helper.saveNotesRecord(component, event, helper);
    },
    viewOnMap: function (component, event, helper) {
        helper.viewOnMapRedirection(component, event, helper);
    },
    handleError: function (component, event, helper) {
        console.log("Inside Error handling");

        // THIS WORKS JUST FINE
        console.log("ERROR: " + JSON.stringify(event.getParams().error));
        console.log("ERROR: " + JSON.stringify(event.getParams().error.data));

        var output = event.getParams().error.data.output;

        var full_error_messages = "";

        //todo - no idea how its parsed right now
        var errors = output.errors;
        if (errors && errors.length > 0) {
            full_error_messages += JSON.stringify(errors) + "\n";
        }

        var fieldErrors = output.fieldErrors;

        for (var key in fieldErrors) {
            var errorMessages = fieldErrors[key];

            for (var x = 0; x < errorMessages.length; x++) {
                full_error_messages += errorMessages[x].message + "\n";
            }
        }

        component.set("v.formErrors", full_error_messages);
        component.set("v.showSpinner", false);
    },
    updateManagerSelected: function (component, event, helper) {
        helper.UpdateContactRow(component, event, helper);
    },
    handleSave: function (component, event, helper) {
        //Save shedule viewing
        //Load VF
        //https://flexioffices--empauadev--c.cs105.visual.force.com/apex/ViewingSchedulePreview?viewingScheduleId=a071w000000t8HGAAY
    }
});