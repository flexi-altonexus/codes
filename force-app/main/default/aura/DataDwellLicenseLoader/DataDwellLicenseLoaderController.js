({
    init : function(component, event, helper) {
        if(window.location.href.indexOf('appBuilder') === -1 && window.location.href.indexOf('flexipageEditor') === -1) {
            var action = component.get('c.checkUserLicense');
            var namespace = 'datadwell';
            action.setParam('namespacePrefix', namespace);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    if(response.getReturnValue() === true) {
                        if(component.get('v.client') == 'Gmail/Outlook') {
                            component.set('v.peopleInitial', component.get('v.people'));
                            component.set('v.sourceInitial', component.get('v.source'));
                            $A.createComponent(namespace + ':DDEmailPane', {
                                'aura:id': 'emailComponent',
                                people: component.get('v.people'),
                                source: component.get('v.source')
                            }, function(newComponent) {
                                component.set('v.nullComponent', newComponent === null);
                                if(newComponent !== null) {
                                    var content = component.find('content');
                                    content.set('v.body', newComponent);
                                }
                            });
                        } else {
                            $A.createComponent(namespace + ':SalesAthlete', {
                                recordId: component.get('v.recordId'),
                                sObjectName: component.get('v.sObjectName'),
                                componentDisplayMode: component.get('v.componentDisplayMode'),
                                displayPanel: component.get('v.displayPanel'),
                                pageSize: component.get('v.pageSize'),
                            }, function(newComponent) {
                                component.set('v.nullComponent', newComponent === null);
                                if(newComponent !== null) {
                                    var content = component.find('content');
                                    content.set('v.body', newComponent);
                                }
                            });
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set('v.nullComponent', true);
        }
    },
    updatePeople: function(component, event, helper) {
        if(JSON.stringify(component.get('v.people')) != JSON.stringify(component.get('v.peopleInitial'))){
            var namespace = 'datadwell';
            $A.createComponent(namespace + ':DDEmailPane', {
                'aura:id': 'emailComponent',
                people: component.get('v.people'),
                source: component.get('v.source')
            }, function(newComponent) {
                component.set('v.nullComponent', newComponent === null);
                if(newComponent !== null) {
                    var content = component.find('content');
                    content.set('v.body', newComponent);
                }
            });
        }
    }
})