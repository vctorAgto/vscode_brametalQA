@isTest
private class GenericActionRestServiceTest {

    @isTest
    static void testHandleLeadActionSuccess() {
        // 1. Criar um Lead de teste
        Lead ld = new Lead(
            FirstName ='33',
            LastName = 'Teste Lead',
            Company = 'Empresa Teste',
            Status = 'Open - Not Contacted'
        );
        insert ld;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = '/services/apexrest/clickAction';
        request.httpMethod = 'GET';
        request.addParameter('id', ld.Id);
        request.addParameter('acao', 'sim');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        GenericActionRestService.handleAction();
        Test.stopTest();

       
        
    }

   

    @isTest
    static void testHandleActionError() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = '/services/apexrest/clickAction';
        request.httpMethod = 'GET';
        // ID fake que segue o formato de um ID de Lead (00Q...) para não dar erro de cast, 
        // mas falhar no update por não existir no banco.
        request.addParameter('id', '00Q1t00000XXXXX'); 
        request.addParameter('acao', 'sim');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        GenericActionRestService.handleAction();
        Test.stopTest();

       
    }
}