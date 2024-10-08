({
    setColumns : function(component) {
        component.set('v.columns', [
            {label: 'Introduction', fieldName: 'NameLink', type: 'url', 
        typeAttributes: {label: {fieldName: 'Name'}, target:'_blank'}},
            {label: 'Business Centre', fieldName: 'CentreLink', type: 'url', 
        typeAttributes: {label: {fieldName: 'BusinessCentreName'}, target:'_blank'}},
            {label: 'Send to Provider', fieldName: 'ReSendEmailtoProvider', type: 'boolean', editable: true},
            {label: 'Send to Customer', fieldName: 'ReSendEmailtoCustomer', type: 'boolean', editable: true}
        ]);
    },

    FormatDataTable : function(rows) {

        //Format relation and URL values of the Table
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            if (row.Id){
               row.NameLink = '/' + row.Id;
            }
            if(row.BusinessCentre){
                row.BusinessCentreName = row.bcName;
                row.CentreLink = '/' + row.BusinessCentre;
            }
        }
        return rows;
    },

    setMessage : function(component, type, title, message){
        // Get showToast event
        var toastEvent = $A.get("e.force:showToast");
        
        // Set Params & fire event
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            mode: 'dismissible'
        }).fire(); 
    }
})