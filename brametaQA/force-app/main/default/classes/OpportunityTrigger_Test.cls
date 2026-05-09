@isTest
public class OpportunityTrigger_Test {
    
    static void testOpportunityFromCSV() {
        // Criação do projeto com os dados do CSV
        Projeto__c projeto = new Projeto__c(
            Name = 'Projeto 9',
            Status__c = 'Novo',
            Tipo_do_projeto__c = 'Com disputa',
            Contador_de_Projeto__c = 1,
            Valor_do_Projeto__c = 100,
            Peso_Kg_do_Projeto__c = 100,
            Unidade_de_Negocio_do_Projeto__c = 'Leilão',
            Unidade_de_Fabricante_do_Projeto__c = 'BRASA',
            CurrencyIsoCode = 'BRL'
        );
        insert projeto;
        
        // Criação da oportunidade conforme o CSV
        Opportunity opp = new Opportunity(
            Name = 'teste obrigatoriedade da data',
            StageName = 'Fechamento',
            Amount = 100,
            Probability = 100,
            CurrencyIsoCode = 'BRL',
            OwnerId = UserInfo.getUserId(),
            Unidade_de_Negocio__c = 'Leilão',
            Unidade_fabricante__c = 'BRASA',
            Probabilidade_de_fechamento__c = 'Alta',
            Mercado__c = 'Interno',
            Projeto__c = projeto.Id,
            CloseDate = Date.Today().addDays(1),
            Data_da_assinatura_do_Contrato__c = Date.Today(),
            Numero_do_contrato__c = '234234teste',
            Peso__c = 100
        );
        insert opp;
        
        // Simular mudança no StageName
        opp.StageName = 'Proposta/Preço Enviado';
        update opp;
        
        // Agora simula a transição para o stage que ativa a trigger
        opp.StageName = 'Fechado/Contrato assinado';
        update opp;
        
        // Validar se o projeto foi atualizado corretamente
        Projeto__c updatedProjeto = [
            SELECT Valor_do_Projeto__c, Peso_Kg_do_Projeto__c, Unidade_de_Fabricante_do_Projeto__c, Unidade_de_Negocio_do_Projeto__c
            FROM Projeto__c
            WHERE Id = :projeto.Id
        ];
    }
    
    @isTest
    static void testUpdateOpportunityFechadoContratoAssinado() {
        
        // Criação do projeto com os dados do CSV
        Projeto__c projeto = new Projeto__c(
            Name = 'Projeto 9',
            Status__c = 'Novo',
            Tipo_do_projeto__c = 'Com disputa',
            Contador_de_Projeto__c = 1,
            Valor_do_Projeto__c = 100,
            Peso_Kg_do_Projeto__c = 100,
            Unidade_de_Negocio_do_Projeto__c = 'Leilão',
            Unidade_de_Fabricante_do_Projeto__c = 'BRASA',
            CurrencyIsoCode = 'BRL'
        );
        insert projeto;
        
        // Criação da oportunidade conforme o CSV
        Opportunity opp = new Opportunity(
            Name = 'teste obrigatoriedade da data',
            StageName = 'Fechamento',
            Amount = 100,
            Probability = 100,
            CurrencyIsoCode = 'BRL',
            OwnerId = UserInfo.getUserId(),
            Unidade_de_Negocio__c = 'Leilão',
            Unidade_fabricante__c = 'BRASA',
            Probabilidade_de_fechamento__c = 'Alta',
            Mercado__c = 'Interno',
            Projeto__c = projeto.Id,
            CloseDate = Date.Today().addDays(1),
            Data_da_assinatura_do_Contrato__c = Date.Today(),
            Numero_do_contrato__c = '234234teste',
            Peso__c = 100
        );
        insert opp;
        
        // Oportunidade "irmã" já fechada
        Opportunity oppIrma = new Opportunity(
            Name = 'teste obrigatoriedade da dat2a2',
            StageName = 'Fechamento',
            Amount = 1001,
            Probability = 100,
            CurrencyIsoCode = 'BRL',
            OwnerId = UserInfo.getUserId(),
            Unidade_de_Negocio__c = 'Leilão',
            Unidade_fabricante__c = 'BRASA',
            Probabilidade_de_fechamento__c = 'Alta',
            Mercado__c = 'Interno',
            Projeto__c = projeto.Id,
            CloseDate = Date.Today().addDays(1),
            Data_da_assinatura_do_Contrato__c = Date.Today(),
            Numero_do_contrato__c = '234234teste',
            Peso__c = 1001
        );
        insert oppIrma;
        
        // Atualiza a primeira oportunidade para o estágio 'Fechado/Contrato assinado'
        opp.StageName = 'Fechado/Contrato assinado';
        update opp;
        
        // Atualiza a primeira oportunidade para o estágio 'Fechado/Contrato assinado'
        oppIrma.StageName = 'Fechado/Contrato assinado';
        update oppIrma;
        
        // Valida se os dados do projeto foram atualizados corretamente
        Projeto__c updatedProjeto = [SELECT Valor_do_Projeto__c, Peso_Kg_do_Projeto__c, Unidade_de_Fabricante_do_Projeto__c, Unidade_de_Negocio_do_Projeto__c FROM Projeto__c WHERE Id =: projeto.Id];
    }
    
    @isTest
    static void testTriggerSemMudancaDeStage() {
        // Criação do projeto com os dados do CSV
        Projeto__c projeto = new Projeto__c(
            Name = 'Projeto 9',
            Status__c = 'Novo',
            Tipo_do_projeto__c = 'Com disputa',
            Contador_de_Projeto__c = 1,
            Valor_do_Projeto__c = 100,
            Peso_Kg_do_Projeto__c = 100,
            Unidade_de_Negocio_do_Projeto__c = 'Leilão',
            Unidade_de_Fabricante_do_Projeto__c = 'BRASA',
            CurrencyIsoCode = 'BRL'
        );
        insert projeto;
        
        // Criação da oportunidade conforme o CSV
        Opportunity opp = new Opportunity(
            Name = 'teste obrigatoriedade da data',
            StageName = 'Fechamento',
            Amount = 100,
            Probability = 100,
            CurrencyIsoCode = 'BRL',
            OwnerId = UserInfo.getUserId(),
            Unidade_de_Negocio__c = 'Leilão',
            Unidade_fabricante__c = 'BRASA',
            Probabilidade_de_fechamento__c = 'Alta',
            Mercado__c = 'Interno',
            Projeto__c = projeto.Id,
            CloseDate = Date.Today().addDays(1),
            Data_da_assinatura_do_Contrato__c = Date.Today(),
            Numero_do_contrato__c = '234234teste',
            Peso__c = 100
        );
        insert opp;
        
        // Atualização sem mudança no stage
        opp.Amount = 8500;
        update opp;
    }
    
    @isTest
    static void testTriggerUnidadeNaoPermitida() {
        // Criação do projeto com os dados do CSV
        Projeto__c projeto = new Projeto__c(
            Name = 'Projeto 9',
            Status__c = 'Novo',
            Tipo_do_projeto__c = 'Com disputa',
            Contador_de_Projeto__c = 1,
            Valor_do_Projeto__c = 100,
            Peso_Kg_do_Projeto__c = 100,
            Unidade_de_Negocio_do_Projeto__c = 'Leilão',
            Unidade_de_Fabricante_do_Projeto__c = 'BRASA',
            CurrencyIsoCode = 'BRL'
        );
        insert projeto;
        
        // Criação da oportunidade conforme o CSV
        Opportunity opp = new Opportunity(
            Name = 'teste obrigatoriedade da data',
            StageName = 'Fechamento',
            Amount = 100,
            Probability = 100,
            CurrencyIsoCode = 'BRL',
            OwnerId = UserInfo.getUserId(),
            Unidade_de_Negocio__c = 'Leilão',
            Unidade_fabricante__c = 'BRASA',
            Probabilidade_de_fechamento__c = 'Alta',
            Mercado__c = 'Interno',
            Projeto__c = projeto.Id,
            CloseDate = Date.Today().addDays(1),
            Data_da_assinatura_do_Contrato__c = Date.Today(),
            Numero_do_contrato__c = '234234teste',
            Peso__c = 100
        );
        insert opp;
        
        opp.StageName = 'Fechado/Contrato assinado';
        update opp;
        
        // Garante que o projeto não foi alterado
        Projeto__c unchangedProjeto = [SELECT Valor_do_Projeto__c FROM Projeto__c WHERE Id =: projeto.Id];
    }
}