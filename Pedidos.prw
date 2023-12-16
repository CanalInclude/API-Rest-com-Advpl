#Include 'Protheus.ch'
#Include 'Restful.ch'

WsRestful pedido Description 'API para trabalhar com pedidos de venda.'

    WsMethod GET TODOS Description 'Retorna todos os pedidos de venda' Path '/'

End WsRestful

WsMethod GET TODOS WsService pedido

    Local oJson     := JsonObject():New()
    Local oJsonRet  := JsonObject():New()
    Local aPedidos  := {}
    Local lRet      := .T.

    SC5->(DbSetOrder(1))
    SC5->(DbGoTop())

    While SC5->(!Eof())

        oJson := JsonObject():New()
        oJson['pedido'] := SC5->C5_NUM
        oJson['cliente'] := SC5->C5_CLIENTE
        oJson['loja'] := SC5->C5_LOJACLI

        Aadd(aPedidos, oJson)

        SC5->(DbSkip())

    EndDo

    oJsonRet['pedidos'] := aPedidos

    self:SetResponse(oJsonRet:ToJson())

Return lRet
