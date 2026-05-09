/*
* SE FOR PARA ADICIONAR MAIS ALGUM CÓDIGO NESSA TRIGGER POR FAVOR CRIAR UMA HANDLE E TRANFERIR O CÓDIGO DAQUI
* PARA HANDLE DEIXA SÓ O CÓDIGO DA VERIFICAÇÃO AQUI
*/ 
        
trigger OpportunityTrigger on Opportunity (after update) {

    Set<Id> projetoIds = new Set<Id>();
    Map<Id, Opportunity> oppsToProcess = new Map<Id, Opportunity>();
    List<Opportunity> listOppMarketShare = new List<Opportunity>();
    List<Date> listDateFechamentoNegocio = new List<Date>();

    // Filtra oportunidades relevantes
    for (Opportunity opp : Trigger.new) {
        if ((opp.Unidade_de_Negocio__c == 'Leilão' || 
            opp.Unidade_de_Negocio__c == 'Não leilão' || 
            opp.Unidade_de_Negocio__c == 'Solar') &&
            opp.StageName != 'Fechado/Não Assinado' &&
            opp.Projeto__c != null) {
                
            projetoIds.add(opp.Projeto__c);
            oppsToProcess.put(opp.Id, opp);
        }

        if (opp.StageName == 'Fechado/Contrato assinado' && opp.Estudo_de_Mercado_Relacionado__c == null) {
            listOppMarketShare.add(opp);
            listDateFechamentoNegocio.add(opp.CloseDate);
        }
    }

    /*
    * Codigo que atualiza os dados do Estudo de Mercado de acordo com as opp.
    */
    if(!listOppMarketShare.isEmpty()) {

        String query = 'SELECT Id, Name, Fontes__c, Mercado__c, Peso_atendido__c, Peso_estimado__c, Data_Inicio__c, Receita_estimada__c, Seguimento__c, Data_Final__c FROM Estudo_de_Mercado__c WHERE';

        for(DateTime dataInicio : listDateFechamentoNegocio) {
            query += '(Data_Inicio__c <= ' + dataInicio.format('yyyy-MM-dd') + ') OR ';
        }
        
        query = query.substring(0, query.length() - 4); // Remove o último ' OR '
        query += ' AND ';

        for(DateTime dataFim : listDateFechamentoNegocio) {
            query += '(Data_Final__c >= ' + dataFim.format('yyyy-MM-dd') + ') OR ';
        }
        query = query.substring(0, query.length() - 4); // Remove o último ' OR '

        System.debug('Query: ' + query);
        
        List<Estudo_de_Mercado__c> listEstudoMercado = Database.query(query);
        List<Estudo_de_Mercado__c> listUpdateEstMer = new List<Estudo_de_Mercado__c>();
        List<Opportunity> listUpdateOpp = new List<Opportunity>();

        Opportunity oppUpdate;

        for(Estudo_de_Mercado__c estMer : listEstudoMercado) {
            for(Opportunity opp : listOppMarketShare) {
                if(estMer.Data_Inicio__c <= opp.CloseDate
                    && estMer.Data_Final__c >= opp.CloseDate
                    && estMer.Mercado__c == opp.Mercado__c
                    && estMer.Seguimento__c == opp.Unidade_de_Negocio__c) {
                        
                        if(opp.Peso__c != null) {
                            estMer.Peso_atendido__c += opp.Peso__c;   
                        }
                        oppUpdate = new Opportunity(
                            id = opp.Id,
                            Estudo_de_Mercado_Relacionado__c = estMer.Id
                        );

                        listUpdateEstMer.add(estMer);
                        listUpdateOpp.add(oppUpdate);
                }
            }
        }

        if(!listUpdateEstMer.isEmpty()) {
            update listUpdateEstMer;
            update listUpdateOpp;
        }

    }

    if (projetoIds.isEmpty()) return;

    // Consulta projetos
    Map<Id, Projeto__c> projetosMap = new Map<Id, Projeto__c>(
        [SELECT Id, Valor_do_Projeto__c, Peso_Kg_do_Projeto__c, 
                Unidade_de_Fabricante_do_Projeto__c, Unidade_de_Negocio_do_Projeto__c 
        FROM Projeto__c 
        WHERE Id IN :projetoIds]
    );

    // Consulta oportunidades irmãs
    List<Opportunity> irmas = [
        SELECT Id, Amount, Peso__c, Projeto__c 
        FROM Opportunity 
        WHERE Projeto__c IN :projetoIds 
        AND StageName != 'Fechado/Não Assinado'
        AND (Unidade_de_Negocio__c = 'Leilão' OR Unidade_de_Negocio__c = 'Não leilão' OR Unidade_de_Negocio__c = 'Solar')
    ];

    // Agrupa irmãs por projeto
    Map<Id, List<Opportunity>> irmasPorProjeto = new Map<Id, List<Opportunity>>();
    for (Opportunity o : irmas) {
        if (!irmasPorProjeto.containsKey(o.Projeto__c)) {
            irmasPorProjeto.put(o.Projeto__c, new List<Opportunity>());
        }
        irmasPorProjeto.get(o.Projeto__c).add(o);
    }

    List<Projeto__c> projetosParaAtualizar = new List<Projeto__c>();

    for (Opportunity opp : oppsToProcess.values()) {
        List<Opportunity> irmasValidas = new List<Opportunity>();

        for (Opportunity irma : irmasPorProjeto.get(opp.Projeto__c)) {
            if (irma.Id != opp.Id) {
                irmasValidas.add(irma);
            }
        }

        Decimal somaValor = opp.Amount != null ? opp.Amount : 0;
        Decimal somaPeso = opp.Peso__c != null ? opp.Peso__c : 0;
        Integer total = 1;

        for (Opportunity irma : irmasValidas) {
            if (irma.Amount != null) somaValor += irma.Amount;
            if (irma.Peso__c != null) somaPeso += irma.Peso__c;
            total++;
        }

        Decimal mediaValor = somaValor / total;
        Decimal mediaPeso = somaPeso / total;

        Projeto__c projeto = projetosMap.get(opp.Projeto__c);
        projeto.Valor_do_Projeto__c = mediaValor.setScale(2);
        projeto.Peso_Kg_do_Projeto__c = mediaPeso.setScale(2);
        projeto.Unidade_de_Fabricante_do_Projeto__c = opp.Unidade_fabricante__c;
        projeto.Unidade_de_Negocio_do_Projeto__c = opp.Unidade_de_Negocio__c;

        projetosParaAtualizar.add(projeto);
    }

    if (!projetosParaAtualizar.isEmpty()) {
        update projetosParaAtualizar;
    }
}