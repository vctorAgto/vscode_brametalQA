@RestResource(urlMapping='/clickAction/*')
global without sharing class GenericActionRestService {

    @HttpGet
    global static void handleAction() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String recordId = req.params.get('id');
        String acao = req.params.get('acao');
        
        try {
            if (String.isNotBlank(recordId)) {
                Id myId = (Id)recordId;
                String sObjectType = myId.getSObjectType().getDescribe().getName();
                
                SObject recordToUpdate = myId.getSObjectType().newSObject(myId);
                
                // Atribui os valores aos campos (garanta que o nome da API seja igual em ambos)
                recordToUpdate.put('NaoRecebeEmail__c', (acao == 'sim'));
                recordToUpdate.put('Data_Clique__c', System.now());
                
                update recordToUpdate;
                
                res.statusCode = 302; // Código HTTP para redirecionamento
                res.addHeader('Location', 'https://www.brametal.com.br/pagina-de-descadastro/');
            }
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Erro ao processar: ' + e.getMessage());
        }
    }
}