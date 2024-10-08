({
    init: function(component, event, helper) {
		var action = component.get('c.fetchIntroductions');
        action.setParams({
            'recordId': component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.intros', JSON.parse(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
})