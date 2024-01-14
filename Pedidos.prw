#Include 'Protheus.ch'
#Include 'Restful.ch'

WsRestful pedido Description 'API para trabalhar com pedidos de venda.'

    WsData Pag AS Integer
    WsData Qtd AS Integer

    WsMethod GET TODOS Description 'Retorna todos os pedidos de venda' Path '/'
    WsMethod GET DETALHE Description 'Retorna um pedido de venda no detalhe' Path '/{id}'  
    WsMethod POST CRIA Description 'Cria um pedido de venda' Path '/'  

END WsRestful


// Retorna todos os pedidos de venda
WsMethod GET TODOS WsService pedido

    Local oJson     := JsonObject():New()
    Local oJsonRet  := JsonObject():New()
    Local aPedidos  := {}
    Local cAlias    := GetNextAlias()
    Local lRet      := .T.
    Local nPag      := 0
    Local nQtd      := 0

    Default self:Pag := 1
    Default self:Qtd := 5

    nPag := self:Pag
    nQtd := self:Qtd

    // Tratamento para paginação
    BeginSql Alias cAlias

        SELECT  C5_FILIAL,
                C5_NUM
        FROM %Table:SC5%
        ORDER BY C5_FILIAL, C5_NUM
        OFFSET (%Exp:nPag% -1) * %Exp:nQtd% ROWS FETCH NEXT %Exp:nQtd% ROWS ONLY

    EndSql

    (cAlias)->(DbGoTop())

    // Varre todos os pedidos
    While (cAlias)->(!Eof())

        oJson := JsonObject():New()
        oJson['filial'] := (cAlias)->C5_FILIAL
        oJson['pedido'] := (cAlias)->C5_NUM
        oJson['detalhes'] := 'http://localhost:8080/rest/pedido/' + (cAlias)->C5_NUM
        
        Aadd(aPedidos, oJson)

        (cAlias)->(DbSkip())

    EndDo

    oJsonRet['pedidos'] := aPedidos

    self:SetResponse(oJsonRet:ToJson())

Return lRet



// Retorna todos os pedidos de venda
WsMethod GET DETALHE WsService pedido

    Local oJson     := JsonObject():New()
    Local oJsonItem := Nil
    Local lRet := .T.

    SC5->(DbSetOrder(1))

    If SC5->( DbSeek( cFilAnt + self:aUrlParms[1] ) )

        oJson['filial'] := SC5->C5_FILIAL
        oJson['pedido'] := SC5->C5_NUM
        oJson['tipo'] := SC5->C5_TIPO
        oJson['cliente'] := SC5->C5_CLIENT
        oJson['loja'] := SC5->C5_LOJAENT
        oJson['itens'] := {}

        SC6->(DbSetOrder(1))
        SC6->( DbSeek(SC5->C5_FILIAL + SC5->C5_NUM) )

        While SC6->(!Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM

            oJsonItem := JsonObject():New()
            oJsonItem['codigo'] := SC6->C6_PRODUTO
            oJsonItem['quantidade'] := SC6->C6_QTDVEN

            Aadd(oJson['itens'], oJsonItem)   

            SC6->(DbSkip())

        EndDo

        self:SetResponse(oJson:ToJson())
    
    Else

        SetRestFault(400, 'Pedido não foi encontrado!')
        lRet := .F.

    EndIF

Return lRet


// Cria um pedido de venda
WsMethod POST CRIA WsService pedido

    Local cBody     := self:GetContent()
    Local oJson     := JsonObject():New()
    Local xRetJson  := ''
    Local aCab      := {}
    Local aItem     := {}
    Local aItens    := {}
    Local lRet      := .T.
    Local i         := 0
    Local aErro     := {}
    Local cErro     := ''

    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.

    If !Empty(cBody)

        xRetJson := oJson:FromJson(cBody)

        If ValType(xRetJson) == 'U'

            Aadd(aCab, {'C5_TIPO', oJson['tipo'], Nil})
            Aadd(aCab, {'C5_CLIENTE', oJson['cliente'], Nil})
            Aadd(aCab, {'C5_LOJACLI', oJson['loja'], Nil})
            Aadd(aCab, {'C5_LOJAENT', oJson['loja'], Nil})
            Aadd(aCab, {'C5_TIPOCLI', oJson['tipoCli'], Nil})
            Aadd(aCab, {'C5_CONDPAG', oJson['condPag'], Nil})

            For i := 1 To Len(oJson['itens'])

                Aadd(aItem, {'C6_ITEM', StrZero(i, 2), Nil})
                Aadd(aItem, {'C6_PRODUTO', oJson['itens'][i]['produto'], Nil})
                Aadd(aItem, {'C6_QTDVEN', oJson['itens'][i]['qtdVen'], Nil})
                Aadd(aItem, {'C6_PRUNIT', oJson['itens'][i]['preco'], Nil})
                Aadd(aItem, {'C6_PRCVEN', oJson['itens'][i]['preco'], Nil})
                Aadd(aItem, {'C6_VALOR', oJson['itens'][i]['qtdVen'] * oJson['itens'][i]['preco'], Nil})
                Aadd(aItem, {'C6_TES', oJson['itens'][i]['tes'], Nil})

                Aadd(aItens, aItem)

                aItem := {}

            Next i

            MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCab, aItens, 3)

            If lMsErroAuto

                aErro := GetAutoGRLog()

                For i := 1 To Len(aErro)

                    cErro += aErro[i] + CRLF

                Next i
                
                SetRestFault(400, cErro)
                lRet := .F.

            Else
                
                self:SetResponse('Pedido incluído com sucesso!')
            
            EndIf

        Else

            SetRestFault(400, 'Falha na leitura do arquivo Json')
            lRet := .F.

        EndIf

    Else

        SetRestFault(400, 'Nenhuma informação enviada no body')
        lRet := .F.

    EndIf

Return lRet
