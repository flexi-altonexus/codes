({
    init : function(component, event, helper) {

        helper.setColumns(component);

        console.log(component.get("v.introListJSON"));
        let action = component.get("c.getIntroductions");
        action.setParams({selected : JSON.stringify(component.get("v.introListJSON"))});

        action.setCallback(this,function(response){
            let state = response.getState();
            console.log(response.getReturnValue());
            if(state == 'SUCCESS'){
                component.set("v.data", helper.FormatDataTable(response.getReturnValue()));
            }
            else{
                console.log('Error has occured');
            }
        });
        $A.enqueueAction(action);
    },

    saveDraftValues : function(component, event, helper){

        let action = component.get("c.saveIntroductions");
        var draftValues = event.getParam('draftValues');
        
        action.setParams({newData : JSON.stringify(draftValues),
                        originalData : JSON.stringify(component.get("v.data"))});

        action.setCallback(this,function(response){
            let state = response.getState();
            console.log(response.getReturnValue());
            if(state == 'SUCCESS'){
                component.set("v.data", helper.FormatDataTable(response.getReturnValue()));
                component.set("v.draftValues",[]);
            }
            else{
                console.log('Error has occured');
            }
        });
        $A.enqueueAction(action);
    },

    sendEmails : function(component, event, helper){
        component.set("v.showSpinner",true);
        let action = component.get("c.sendEmailsApex");

        action.setParams({data : JSON.stringify(component.get("v.data"))});

        action.setCallback(this,function(response){
            let state = response.getState();
            console.log(response.getReturnValue());
            if(state == 'SUCCESS'){
                let res = response.getReturnValue();
                helper.setMessage(component, res.type, res.title, res.message);
                //Added handlers in VF Page to make this work
                var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                    "recordId": component.get("v.recordId")
                });
                urlEvent.fire();
            }
            else{
                console.log('Error has occured');
            }
        });
        $A.enqueueAction(action);
    },

    cancel : function(component, event, helper){

        console.log(component.get("v.recordId"));
        //Added handlers in VF Page to make this work
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        urlEvent.fire();
    }

})