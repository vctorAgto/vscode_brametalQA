/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-09-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class JiraConnectController {
    final static JiraConnect__c apiJira = JiraConnect__c.getInstance();
    
    @AuraEnabled
    public static String preparaDadosOF(string ofId){
        //Consulta os dados da ordem de fabricação
        List<Ordem_de_fabricacao__c> lstOF = [Select Id, Name, Peso_total_da_OF_Kg__c, Engenharia__c, Data_de_entrega_contratual__c, Data_de_recebimento__c, APV__c, Tensao_Potencia_kV_mW__c, RecordType.Name, Contrato__c, Contrato__r.Contrato_SAP__c, Contrato__r.Setor_de_atividade__c, Contrato__r.Nome_da_obra__c, Contrato__r.Pricebook2Id, Contrato__r.Unidade_fabricante__c, Contrato__r.Unidade_de_medida_de_venda__c, Contrato__r.Tipo_de_embalagem__c, Contrato__r.Valor_Kg__c, Contrato__r.Description, Contrato__r.Owner.Name, Nome_da_conta__r.Name, Contrato__r.Unidade_de_neg_cio__c FROM Ordem_de_fabricacao__c where Id = :ofId];
        List<Pricebook2> priceBookId = [select id from Pricebook2 where isStandard = true limit 1];
        Ordem_de_fabricacao__c ordemFabricacao;
        System.debug('lstOF = ' + lstOF);
        if(lstOF.size()>0){
            ordemFabricacao = lstOF.get(0);
            
            Map<String, Object> dadosOF = new Map<String, Object>();
            
            //prepara dados para envio ao Jira
            dadosOF.put('contract', ordemFabricacao.Contrato__r.Contrato_SAP__c);
            dadosOF.put('contractId', ordemFabricacao.Contrato__c);
            dadosOF.put('id', ordemFabricacao.Id);
            dadosOF.put('contractPricebookId', ordemFabricacao.Contrato__r.Pricebook2Id);
            dadosOF.put('standardPricebookId', priceBookId.size() > 0 ? priceBookId[0].Id : null);
            dadosOF.put('manufacturerUnit', ordemFabricacao.Contrato__r.Unidade_fabricante__c);
            dadosOF.put('customer', ordemFabricacao.Nome_da_conta__r.Name);
            dadosOF.put('workSite', ordemFabricacao.Contrato__r.Nome_da_obra__c);
            dadosOF.put('salesOrg', ordemFabricacao.Contrato__r.Setor_de_atividade__c);
            dadosOF.put('electricalVoltage', ordemFabricacao.Tensao_Potencia_kV_mW__c);
            dadosOF.put('billingUnit', ordemFabricacao.Contrato__r.Unidade_de_medida_de_venda__c);
            dadosOF.put('manufacturingOrderNumber', ordemFabricacao.Name);
            dadosOF.put('manufacturingOrderType', ordemFabricacao.RecordType.Name);
            dadosOF.put('totalWeight', (ordemFabricacao.Peso_total_da_OF_Kg__c != null) ? String.valueOf(ordemFabricacao.Peso_total_da_OF_Kg__c).replace('.', ',') : '');
            //dadosOF.put('isEngineering', String.valueOf(ordemFabricacao.Engenharia__c));
            dadosOF.put('packagingType', ordemFabricacao.Contrato__r.Tipo_de_embalagem__c);
            dadosOF.put('valueKg', ordemFabricacao.Contrato__r.Valor_Kg__c);
            dadosOF.put('receiptDate', (ordemFabricacao.Data_de_recebimento__c != null) ? String.valueOf(DateTime.newInstance(ordemFabricacao.Data_de_recebimento__c.year(),ordemFabricacao.Data_de_recebimento__c.month(),ordemFabricacao.Data_de_recebimento__c.day()).format('dd/MM/YYYY')) : '');
            dadosOF.put('summary', ordemFabricacao.Contrato__r.Description != null? ordemFabricacao.Contrato__r.Description : ordemFabricacao.Contrato__r.Nome_da_obra__c + '/' + ordemFabricacao.RecordType.Name);
            dadosOF.put('contractualDeliveryDate', (ordemFabricacao.Data_de_entrega_contratual__c != null) ? String.valueOf(DateTime.newInstance(ordemFabricacao.Data_de_entrega_contratual__c.year(),ordemFabricacao.Data_de_entrega_contratual__c.month(),ordemFabricacao.Data_de_entrega_contratual__c.day()).format('dd/MM/YYYY')) : '');
            dadosOF.put('contractAdmin', ordemFabricacao.Contrato__r.Owner.Name);
            dadosOF.put('apv', ordemFabricacao.APV__c);
            dadosOF.put('businessUnit', ordemFabricacao.Contrato__r.Unidade_de_neg_cio__c);
            
            List<Produto_da_ordem_de_fabricacao__c> listProdutos = [Select Id, Name,Engenharia__c, Codigo_do_material__c, Classe_da_OF__c, Classe_da_OF__r.Name, Peso_total_Kg__c, Quantidade__c, Data_prevista_de_entrega__c, Peso_unitario_Kg__c, Tipo_de_circuito__c, Tipo_de_produto__c, Sigla__c, Observacoes__c from Produto_da_ordem_de_fabricacao__c where Ordem_de_fabricacao__c = :ofId];
            
            set<string> codigoProdutos = new set<string>();
            
            for(Produto_da_ordem_de_fabricacao__c produtoOF : listProdutos){
                codigoProdutos.add(produtoOF.Codigo_do_material__c);
            }
            
            List<Product2> lstProdutos = [Select ProductCode, Family from Product2 where ProductCode IN :codigoProdutos];
            
            Map<string,Product2> mapProduct = new Map<string,Product2>();
            for(Product2 prod : lstProdutos){
                mapProduct.put(prod.ProductCode, prod);
            }
            
            List<Map<String, String>> listProdutosOF = new List<Map<String, String>>();
            
            for(Produto_da_ordem_de_fabricacao__c produtoOF : listProdutos){
                Map<String, String> dadosProduto = new Map<String, String>();
                dadosProduto.put('materialCode', produtoOF.Codigo_do_material__c);
                dadosProduto.put('materialDesc', produtoOF.Name);
                dadosProduto.put('productId', produtoOF.Id);
                dadosProduto.put('isEngineering', String.valueOf(produtoOF.Engenharia__c));
                if(mapProduct.containsKey(produtoOF.Codigo_do_material__c)){
                    dadosProduto.put('productType', mapProduct.get(produtoOF.Codigo_do_material__c).Family);
                }
                else{
                    dadosProduto.put('productType', produtoOF.Tipo_de_produto__c);
                }
                
                dadosProduto.put('acronym', produtoOF.Sigla__c);
                dadosProduto.put('manufacturingOrderClass', produtoOF.Classe_da_OF__c);
                dadosProduto.put('contractualDeliveryDate', (ordemFabricacao.Data_de_entrega_contratual__c != null) ? String.valueOf(DateTime.newInstance(ordemFabricacao.Data_de_entrega_contratual__c.year(),ordemFabricacao.Data_de_entrega_contratual__c.month(),ordemFabricacao.Data_de_entrega_contratual__c.day()).format('dd/MM/YYYY')) : '');
                dadosProduto.put('expectedShippingDate', (produtoOF.Data_prevista_de_entrega__c != null) ? String.valueOf(DateTime.newInstance(produtoOF.Data_prevista_de_entrega__c.year(),produtoOF.Data_prevista_de_entrega__c.month(),produtoOF.Data_prevista_de_entrega__c.day()).format('dd/MM/YYYY')) : '');
                dadosProduto.put('unitWeight', (produtoOF.Peso_unitario_Kg__c != null) ? String.valueOf(produtoOF.Peso_unitario_Kg__c).replace('.', ',') : '');
                dadosProduto.put('weight', (produtoOF.Peso_total_Kg__c != null) ? String.valueOf(produtoOF.Peso_total_Kg__c).replace('.', ',') : '');
                dadosProduto.put('amount', (produtoOF.Quantidade__c != null) ? String.valueOf(produtoOF.Quantidade__c).replace('.', ',') : '');
                dadosProduto.put('electricalCircuit', produtoOF.Tipo_de_circuito__c);
                dadosProduto.put('description', produtoOF.Observacoes__c);
                
                listProdutosOF.add(dadosProduto);
            }
            
            dadosOF.put('manufacturingOrderItems', listProdutosOF);
            
            //pesquisar anexos na propria Ordem_de_fabricacao__c
            
            Set<String> idDocumentos = new Set<String>();
            for(ContentDocumentLink cdl : [Select Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :ordemFabricacao.Id]){
                idDocumentos.add(cdl.ContentDocumentId);
            } 
            
            List<Map<String, String>> listAnexos = new List<Map<String, String>>();
            for(ContentVersion cdl : [Select Id, VersionData FROM ContentVersion where IsLatest = true and ContentDocumentId in :idDocumentos]){
                Map<String, String> anexo = new Map<String, String>();
                anexo.put('attachment', cdl.Id);
                
                listAnexos.add(anexo);
            } 
                
            dadosOF.put('attachments', listAnexos);
            
            system.debug('dadosOF json ' + JSON.serialize(dadosOF));
            
            return enviarOrdemFabricacao(JSON.serialize(dadosOF), gerarToken());  
        }
        
        return null;
    }
    
    @AuraEnabled
    public static String preparaDadosConvocacao(string convocacaoId){
        List<Convocacao_de_inspecao__c> lstConvocacao = [Select Id, Name, PMO__c, Peso_convocado__c, Contrato__r.Contrato_SAP__c, Contrato__r.Peso_convocado_Kg__c, Contrato__r.Unidade_fabricante__c, Convocacao_dispensada__c FROM Convocacao_de_inspecao__c where Id = :convocacaoId];
        
        Convocacao_de_inspecao__c convocacao;
        
        if(lstConvocacao.size()>0){
            convocacao = lstConvocacao.get(0);
        }
        
        Map<String, Object> dadosConvocacao = new Map<String, Object>();
        
        dadosConvocacao.put('contract', convocacao.Contrato__r.Contrato_SAP__c);
        dadosConvocacao.put('convocationId', convocacao.Id);
        dadosConvocacao.put('convocationNumber', convocacao.Name);
        dadosConvocacao.put('weight', (convocacao.Peso_convocado__c != null) ? String.valueOf(convocacao.Peso_convocado__c).replace('.', ',') : '');
        dadosConvocacao.put('pmoCi', convocacao.PMO__c);
        dadosConvocacao.put('convDismissed', convocacao.Convocacao_dispensada__c);
        dadosConvocacao.put('manufacturerUnit', convocacao.Contrato__r.Unidade_fabricante__c);//adicionado
        
        List<OrderItem> listOrderItem = [Select Id, Description, Quantity, Ordem_de_venda_SAP__c, Peso_total_do_item_Kg__c, Data_prevista_de_expedicao__c, Convocacao_de_inspecao__c, Contrato__r.Unidade_de_neg_cio__c, Contrato__r.Setor_de_atividade__c, Contrato__r.Unidade_fabricante__c, Order.Motivo_da_OV__c, Order.Account.Name, Product2.ProductCode, Product2.Family, Ordem_de_fabricacao__r.Name, Ordem_de_fabricacao__r.Data_de_entrega_contratual__c, Produto_da_ordem_de_fabricacao__r.Tipo_de_produto__c  from OrderItem where Convocacao_de_inspecao__c = :convocacaoId];
        
        if(listOrderItem.size() > 0){
            List<Map<String, String>> listItemConvocacao = new List<Map<String, String>>();
            
            //pesquisar anexos - Confirmar se o anexo eh da convocação ou do order item
            /*Set<String> idDocumentos = new Set<String>();
            for(ContentDocumentLink cdl : [Select Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :convocacao.Id]){
                idDocumentos.add(cdl.ContentDocumentId);
            } 
            
            List<Map<String, String>> listAnexos = new List<Map<String, String>>();
            for(ContentVersion cdl : [Select Id, VersionData FROM ContentVersion where IsLatest = true and ContentDocumentId in :idDocumentos]){
                Map<String, String> anexo = new Map<String, String>();
                anexo.put('attachment', cdl.Id);
                
                listAnexos.add(anexo);
            } */
            
            for(OrderItem orderItemConvocacao : listOrderItem){
                Map<String, String> dadosOrderItem = new Map<String, String>();
                dadosOrderItem.put('id', orderItemConvocacao.Id);
                dadosOrderItem.put('convocationId', orderItemConvocacao.Convocacao_de_inspecao__c);
                dadosOrderItem.put('salesOrderSap', orderItemConvocacao.Ordem_de_venda_SAP__c);
                dadosOrderItem.put('customer', orderItemConvocacao.Order.Account.Name);
                dadosOrderItem.put('materialCode', orderItemConvocacao.Product2.ProductCode);
                dadosOrderItem.put('materialDesc', orderItemConvocacao.Description);
                dadosOrderItem.put('amount', (orderItemConvocacao.Quantity != null) ? String.valueOf(orderItemConvocacao.Quantity).replace('.', ',') : '');
                dadosOrderItem.put('totalWeight', (orderItemConvocacao.Peso_total_do_item_Kg__c != null) ? String.valueOf(orderItemConvocacao.Peso_total_do_item_Kg__c).replace('.', ',') : '');
                dadosOrderItem.put('manufacturingOrderNumber', orderItemConvocacao.Ordem_de_fabricacao__r.Name);
                dadosOrderItem.put('contractualDeliveryDate', (orderItemConvocacao.Ordem_de_fabricacao__r.Data_de_entrega_contratual__c != null) ? String.valueOf(DateTime.newInstance(orderItemConvocacao.Ordem_de_fabricacao__r.Data_de_entrega_contratual__c.year(),orderItemConvocacao.Ordem_de_fabricacao__r.Data_de_entrega_contratual__c.month(),orderItemConvocacao.Ordem_de_fabricacao__r.Data_de_entrega_contratual__c.day()).format('dd/MM/YYYY')) : '');
                dadosOrderItem.put('expectedShippingDate', (orderItemConvocacao.Data_prevista_de_expedicao__c != null) ? String.valueOf(DateTime.newInstance(orderItemConvocacao.Data_prevista_de_expedicao__c.year(),orderItemConvocacao.Data_prevista_de_expedicao__c.month(),orderItemConvocacao.Data_prevista_de_expedicao__c.day()).format('dd/MM/YYYY')) : '');
                dadosOrderItem.put('businessUnit', orderItemConvocacao.Contrato__r.Unidade_de_neg_cio__c);
                dadosOrderItem.put('salesOrg', orderItemConvocacao.Contrato__r.Setor_de_atividade__c);
                dadosOrderItem.put('productType', orderItemConvocacao.Produto_da_ordem_de_fabricacao__r.Tipo_de_produto__c);
                dadosOrderItem.put('reasonSalesOrder', orderItemConvocacao.Order.Motivo_da_OV__c);
                //dadosOrderItem.put('attachments', listAnexos); // arquivo para cada item
                dadosOrderItem.put('manufacturerUnit', orderItemConvocacao.Contrato__r.Unidade_fabricante__c);//adicionado
                
                listItemConvocacao.add(dadosOrderItem);
            }
            
            dadosConvocacao.put('orderItems', listItemConvocacao);
        }
        
        system.debug('dadosConvocacao json ' + JSON.serialize(dadosConvocacao));
        
        return enviarConvocacao(JSON.serialize(dadosConvocacao), gerarToken());    
    }
    
    private static String enviarOrdemFabricacao(String body, String accessToken){
        
        String endpoint = apiJira.Endpoint__c + apiJira.ordemFaturamentoURL__c;
        
        HttpRequest request = preparePostRequest(endpoint, body, accessToken);
        System.debug('request = ' + request);
        System.debug('request_ordemFaturamentoURL__c_accessToken = ' + accessToken);
        
        System.debug('request_ordemFaturamentoURL__c = ' + body);
        
        request.setHeader('apikey', apiJira.ordemFaturamentoApiKey__c);
        
        String responseBody = '';
        Integer statusCode = 0;
        
        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
            System.debug('body = ' + responseBody);
            
            statusCode = response.getStatusCode();
            System.debug('statusCode = ' + statusCode);
            
            Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            //recuperar retorno do json
            //resBody.containsKey('total')
            
            return null;
            
        } catch(Exception e) {
            //criar log em caso de erro?
            return null;
        }    
    }
    
    private static String enviarConvocacao(String body, String accessToken){
        
        String endpoint = apiJira.Endpoint__c + apiJira.convocacaoURL__c;
        
        HttpRequest request = preparePostRequest(endpoint, body, accessToken);
        request.setHeader('apikey', apiJira.convocacaoApiKey__c);
        
        String responseBody = '';
        Integer statusCode = 0;
        
        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
            System.debug('body = ' + responseBody);
            
            statusCode = response.getStatusCode();
            System.debug('statusCode = ' + statusCode);
            
            Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            //recuperar retorno do json
            //resBody.containsKey('access_token')
            
            return null;
            
        } catch(Exception e) {
            //criar log em caso de erro?
            return null;
        }    
    }
    
    private static String gerarToken(){
        
        String endpoint = apiJira.Endpoint__c + apiJira.tokenURL__c;
        
        Map<String, Object> dadosToken = new Map<String, Object>();
        
        dadosToken.put('client_id', apiJira.client_id__c);
        dadosToken.put('client_secret', apiJira.client_secret__c);
        dadosToken.put('grant_type', 'client_credentials');
        dadosToken.put('scopo', 'salesforce');
        
        String body = JSON.serialize(dadosToken);
                System.debug('body_request = ' + body);

        HttpRequest request = preparePostRequest(endpoint, body, null);
        
        request.setHeader('apikey', apiJira.apiKey__c);
        System.debug('body_request = ' + request);
        String responseBody = '';
        Integer statusCode = 0;
        
        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
            System.debug('body = ' + responseBody);
            
            statusCode = response.getStatusCode();
            System.debug('statusCode = ' + statusCode);
            
            Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            //recuperar retorno do json
            if(resBody.containsKey('access_token')){
                return (String)resBody.get('access_token');
            }
            
            return null;
        } catch(Exception e) {
            //criar log em caso de erro?
            return null;
        }    
    }
    
    private static HttpRequest preparePostRequest(String endpoint, String body, String accessToken) {
        HttpRequest httpRequest = new HttpRequest();
        
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        
        httpRequest.setHeader('Content-Type','application/json');
        
        if(accessToken != null){
            httpRequest.setHeader('Authorization','Bearer ' + accessToken);
        }
        
        httpRequest.setBody(body);
        
        return httpRequest;
    }
}