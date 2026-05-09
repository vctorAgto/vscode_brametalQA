({
    doInit : function(component, helper) {
        let recordId = component.get('v.recordId');
        let sObjectName = component.get('v.sObjectName');
        var action;
        console.log('sObjectName ' + sObjectName);
        if(sObjectName == 'Ordem_de_fabricacao__c'){
            action = component.get("c.preparaDadosOF");
            action.setParams({ 'ofId' : recordId });
        }
        else if(sObjectName == 'Convocacao_de_inspecao__c'){
            action = component.get("c.preparaDadosConvocacao");
            action.setParams({ 'convocacaoId' : recordId });
        }
        
        action.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
            component.find('notify').showToast({
                "variant": "success",
                "title": "Success",
                "message": "Sync has started"
            });
        });
        
        $A.enqueueAction(action);
    }
})