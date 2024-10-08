({
	clickAddPortal : function(component, event, helper) {
		component.set('v.intro.shared', 1);
        component.set('v.loadCount', component.get('v.loadCount')+1);
		var action = component.get('c.addToPortal');
        action.setParams({
            'recordId': component.get('v.recordId'),
            'introId': component.get('v.intro.id'),
        });
        action.setCallback(this, function(response) {
            component.set('v.loadCount', component.get('v.loadCount')-1);
        });
        $A.enqueueAction(action);
	},
	clickRemovePortal : function(component, event, helper) {
		component.set('v.intro.shared', 0);
        component.set('v.loadCount', component.get('v.loadCount')+1);
		var action = component.get('c.removeFromPortal');
        action.setParams({
            'recordId': component.get('v.recordId'),
            'introId': component.get('v.intro.id'),
        });
        action.setCallback(this, function(response) {
            component.set('v.loadCount', component.get('v.loadCount')-1);
        });
        $A.enqueueAction(action);
	}
})