@IsTest
public class JiraConnectControllerTest {
    @TestSetup
    static void setupTest(){
        JiraConnect__c jc = new JiraConnect__c(
            apiKey__c = '12345fgdfgdg', 
            client_id__c = '12345fgdfgdg',
            client_secret__c = '12345fgdfgdg', 
            convocacaoApiKey__c = '12345fgdfgdg', 
            convocacaoURL__c = '12345fgdfgdg', 
            Endpoint__c = 'https://test.godigibee.io/pipeline/brametal/v1',
            Name = '12345fgdfgdg', 
            ordemFaturamentoApiKey__c = '12345fgdfgdg', 
            ordemFaturamentoURL__c = '12345fgdfgdg', 
            tokenURL__c = '12345fgdfgdg'
        );
        insert jc;
        
        Account acc = new Account (
            Name = 'newAcc1',
            BillingCity = 'FLORIANOPOLIS',
            BillingCountry = 'Brasil',
            BillingCountryCode = 'BR',
            BillingPostalCode = '88025-255',
            BillingState = 'SC',
            BillingStateCode = 'SC',
            BillingStreet = 'Rua 1234',
            CNPJ__c = '02.474.103/0001-19',
            Classifica_o_do_Cliente__c = 'Bronze'
        );  
        insert acc;
        
        Contract cont = new Contract(
            AccountId = acc.Id,
            Contrato_SAP__c = '1000000001',
            Prazo_de_entrega_Fundacao_Dias__c = 30,
            Cod_imposto__c = 'C0 - Consumo: Sem imposto', 
            Condi_es_pagamento__c = '0000 - ANTECIPADO (100%)', 
            Data_base__c = date.Today(), 
            Frete__c = 'EXW', 
            Mercado__c = 'Interno', 
            Nome_da_obra__c = 'Teste', 
            Pais__c = 'Brasil', 
            Peso_Kg__c = 50000, 
            Setor_de_atividade__c = 'Solar GD', 
            Tipo_de_embalagem__c = 'Serial', 
            Unidade_de_medida_de_venda__c = 'KG', 
            Unidade_de_neg_cio__c = 'Leilão',
            Unidade_fabricante__c = 'BRASA', 
            Valor_Kg__c = 50000, 
            Valor_total__c = 50000
        );
        insert cont;
        
        Cronograma_contratual__c cron = new Cronograma_contratual__c(
            Contrato__c = cont.Id,
            CurrencyIsoCode = 'BRL',
            Peso_planejado__c = 30000,
            Data_de_entrega__c = date.Today(),
            Data_limite_para_recebimento_da_OF__c = date.Today()
        );
        insert cron;
        
        Ordem_de_fabricacao__c ofab = new Ordem_de_fabricacao__c(
            RecordTypeId = Schema.SObjectType.Ordem_de_fabricacao__c.getRecordTypeInfosByDeveloperName().get('OF_PDR').getRecordTypeId(),
            Cronograma_contratual__c = cron.Id,
            Contrato__c = cont.Id,
            APV__c = 'Sim', 
            Data_de_recebimento__c = date.Today(), 
            Nome_da_conta__c = acc.Id, 
            Peso_cliente_Kg__c = 100, 
            Referencia_do_cliente__c = 'abc',
            Tipo_de_circuito__c = 'Simples'
        );
        insert ofab;
        
        Produto_da_ordem_de_fabricacao__c prof = new Produto_da_ordem_de_fabricacao__c(
            Ordem_de_fabricacao__c = ofab.Id,
            Codigo_do_material__c = '7000011557',
            Peso_unitario_Kg__c = 10, 
            Quantidade__c = 1, 
            Sigla__c = 'aa', 
            Tipo_de_circuito__c = 'Simples', 
            Tipo_de_produto__c = 'CLIENTE ATC'
        );
        insert prof;
        
        Convocacao_de_inspecao__c conv = new Convocacao_de_inspecao__c(
            Contrato__c = cont.Id,
            Ordem_de_fabricacao__c = ofab.Id,
            Peso_convocado__c = 123,
            PMO__c = 'Sim',
            Convocacao_dispensada__c = 'Sim'
        );
        insert conv;
        
        Pricebook2 pb = new Pricebook2(
            Name = 'Teste',
            Description = 'Teste'
        );
        insert pb;
        
        Product2 prd = new Product2(
            Name = 'Teste',
            ProductCode = '7000011557'
        );
        insert prd;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prd.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = prd.Id,
            UnitPrice = 12
        );
        insert pbe;
        
        Order orde = new Order(
            AccountId = acc.Id,
            ContractId = cont.Id,
            Ordem_de_fabricacao__c = ofab.Id,
            Status = 'Draft',
            EffectiveDate = date.Today(),
            Pricebook2Id = pb.Id,
            Motivo_da_OV__c = 'Z01 - Amostra gratuita', 
            Ordem_de_venda_SAP__c = '1000000001', 
            Peso_do_pedido_Kg__c = 10
        );
        insert orde;
        
        OrderItem oite = new OrderItem(
            Contrato__c = cont.Id,
            Convocacao_de_inspecao__c = conv.Id,
            Ordem_de_fabricacao__c = ofab.Id,
            OrderId = orde.Id,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            UnitPrice = 100,
            Data_prevista_de_expedicao__c = date.Today(), 
            Produto_da_ordem_de_fabricacao__c = prof.Id
        );
        insert oite;
    }
    
    @isTest
    private static void testePreparaDadosOF(){
        Test.startTest();
        
        List<Ordem_de_fabricacao__c> ofs = [Select Id from Ordem_de_fabricacao__c];
        
        if(ofs.size() > 0){
            JiraConnectController.preparaDadosOF(ofs[0].Id);
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void testePreparaDadosOFSemProduto(){
        Test.startTest();
        
        List<Produto_da_ordem_de_fabricacao__c> prodOf = [Select Id, Codigo_do_material__c from Produto_da_ordem_de_fabricacao__c];
        
        if(prodOf.size() > 0){
            prodOf[0].Codigo_do_material__c = '987123';
            update prodOf;
        }
        
        
        List<Ordem_de_fabricacao__c> ofs = [Select Id from Ordem_de_fabricacao__c];
        
        if(ofs.size() > 0){
            JiraConnectController.preparaDadosOF(ofs[0].Id);
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void testePreparaDadosConvocacao(){
        Test.startTest();
        
        List<Convocacao_de_inspecao__c> cvs = [Select Id from Convocacao_de_inspecao__c];
        
        if(cvs.size() > 0){
            JiraConnectController.preparaDadosConvocacao(cvs[0].Id);
        }
        
        Test.stopTest();
    }
}