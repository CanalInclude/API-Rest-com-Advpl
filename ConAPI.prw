#INCLUDE 'Protheus.ch'
#INCLUDE 'Restful.ch'

/*/ {Protheus.doc} ConAPI
    Classe exemplo para consumo de APIs de sistemas terceiros
    @type Class
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Class ConAPI

    Data cUrlBase
    Data cToken
    Data aHeader
    Data cEndPoint

    Method New() Constructor
    Method GetToken()
    Method GetHeader()
    Method TestAuth()
    Method GetProducts()
    Method AddProduct()
    Method ModifyProduct()
    Method ModifyPatch()
    Method DeleteProduct()

EndClass


/*/ {Protheus.doc} New
    Construtor de classe
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method New() Class ConAPI

    self:cUrlBase   := 'https://dummyjson.com'
    self:cToken     := self:GetToken()
    self:aHeader    := self:GetHeader()

Return self


/*/ {Protheus.doc} GetToken
    Retorna o cabeçalho padrão para as requisições
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method GetToken() Class ConAPI

    Local aHeader   := {}
    Local oJsonBody := JsonObject():New()
    Local oJsonRet  := JsonObject():New()
    Local oRest     := FwRest():New( self:cUrlBase ) // Instancia a classe FwRest já setando a URL base
    Local cToken    := ''

    // Define o EndPoint a ser utilizado
    self:cEndPoint := '/auth/login'
    oRest:SetPath( self:cEndPoint )

    // Cabeçalho
    Aadd( aHeader, "Content-Type: application/json" )

    //Montagem do Json, que será convertido em texto após chamada do método ToJson()
    oJsonBody['username'] := 'emilys'
    oJsonBody['password'] := 'emilyspass'

    // Define o Body da requisição
    oRest:SetPostParams( oJsonBody:ToJson() )

    // Realiza a requisição POST enviando o cabeçalho e o body setado anteriormente
    If oRest:Post( aHeader )

        // oRest:GetResult() retorna o Json devolvido pela API
        // Aquiutilizamos o método FromJson para converter o Json (texto) para Json (Objeto)
        oJsonRet:FromJson( oRest:GetResult() )

        // Acessamos a chave token do Json recebido
        cToken := oJsonRet['token']

    EndIf

Return cToken


/*/ {Protheus.doc} GetHeader
    Retorna o cabeçalho padrão para as requisições
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method GetHeader() Class ConAPI

    Local aHeader   := {}

    Aadd( aHeader, "Content-Type: application/json" )
    Aadd( aHeader, "Authorization: Bearer " + self:cToken )

Return aHeader


/*/ {Protheus.doc} TestAuth
    Metodo da API Teste para validar a autenticação
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method TestAuth() Class ConAPI

    Local oRest     := FwRest():New( self:cUrlBase ) // Instancia a classe FwRest já setando a URL base
    Local oJsonRet  := JsonObject():New()

    // Define o EndPoint a ser utilizado
    self:cEndPoint := '/auth/me'
    oRest:SetPath( self:cEndPoint )

    // Realiza a chamada GET passando o token de autenticação no Header
    If oRest:Get(self:aHeader)

        // Sucesso
        oJsonRet:FromJson( oRest:GetResult() )

    Else

        // Falha
        oJsonRet:FromJson( oRest:GetLastError() )

    EndIf

Return oJsonRet


/*/ {Protheus.doc} GetProducts
    Busca produtos na API
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method GetProducts(nLimit) Class ConAPI

    Local oRest     := FwRest():New( self:cUrlBase ) // Instancia a classe FwRest já setando a URL base
    Local oJsonRet  := JsonObject():New()

    // Define o EndPoint a ser utilizado
    self:cEndPoint := '/products'
    oRest:SetPath( self:cEndPoint + '?limit=' + cValtoChar(nLimit) )

    // Realiza a chamada GET passando o token de autenticação no Header
    If oRest:Get(self:aHeader)

        // Sucesso
        oJsonRet:FromJson( oRest:GetResult() )

    Else

        // Falha
        oJsonRet:FromJson( oRest:GetLastError() )

    EndIf

Return oJsonRet


/*/ {Protheus.doc} AddProduct
    Adiciona um produto
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method AddProduct(oJsonBody) Class ConAPI

    Local oJsonRet  := JsonObject():New()
    Local oRest     := FwRest():New( self:cUrlBase ) // Instancia a classe FwRest já setando a URL base

    // Define o EndPoint a ser utilizado
    self:cEndPoint := '/products/add'
    oRest:SetPath( self:cEndPoint )

    // Define o Body da requisição
    oRest:SetPostParams( oJsonBody:ToJson() )

    // Realiza a requisição POST enviando o cabeçalho e o body recebido por parâmetro
    If oRest:Post( self:aHeader )

        // oRest:GetResult() retorna o Json devolvido pela API
        // Aqui utilizamos o método FromJson para converter o Json (texto) para Json (Objeto)
        oJsonRet:FromJson( oRest:GetResult() )

    Else

        // Retorna detalhes do erro
        oJsonRet:FromJson( oRest:GetLastError() )

    EndIf

Return oJsonRet


/*/ {Protheus.doc} DeleteProduct
    Exclui um produto
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method DeleteProduct(nIdProduct) Class ConAPI

    Local oJsonRet  := JsonObject():New()
    Local oRest     := FwRest():New( self:cUrlBase ) // Instancia a classe FwRest já setando a URL base

    // Define o EndPoint a ser utilizado
    self:cEndPoint := '/products/' + cValToChar(nIdProduct)
    oRest:SetPath( self:cEndPoint )

    // Realiza a requisição DELETE enviando o cabeçalho
    If oRest:Delete( self:aHeader )

        // oRest:GetResult() retorna o Json devolvido pela API
        // Aqui utilizamos o método FromJson para converter o Json (texto) para Json (Objeto)
        oJsonRet:FromJson( oRest:GetResult() )

    Else

        // Retorna detalhes do erro
        oJsonRet:FromJson( oRest:GetLastError() )

    EndIf

Return oJsonRet


/*/ {Protheus.doc} ModifyProduct
    Altera um produto
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method ModifyProduct(oJsonBody, nIdProduct) Class ConAPI

    Local oJsonRet  := JsonObject():New()
    Local oRest     := FwRest():New( self:cUrlBase ) // Instancia a classe FwRest já setando a URL base

    // Define o EndPoint a ser utilizado
    self:cEndPoint := '/products/' + cValToChar(nIdProduct)
    oRest:SetPath( self:cEndPoint )

    // Realiza a requisição POST enviando o cabeçalho e o body convertido de JSON para text recebido por parâmetro
    If oRest:Put( self:aHeader, oJsonBody:ToJson() )

        // oRest:GetResult() retorna o Json devolvido pela API
        // Aqui utilizamos o método FromJson para converter o Json (texto) para Json (Objeto)
        oJsonRet:FromJson( oRest:GetResult() )

    Else

        // Retorna detalhes do erro
        oJsonRet:FromJson( oRest:GetLastError() )

    EndIf

Return oJsonRet

/*/ {Protheus.doc} ModifyProduct
    Altera um produto
    @type Method
    @author Leonardo Bilar
    @since 21/05/2024
/*/
Method ModifyPatch(oJsonBody, nIdProduct) Class ConAPI

    Local cRetHead  := ''
    Local cUrl      := self:cUrlBase + '/products/' + cValToChar(nIdProduct) // define a URL do EndPoint
    Local cBody     := oJsonBody:ToJson()
    Local oJsonRet  := JsonObject():New()

    // Envia a Requisição com método PATCH
    cRet := HttpQuote(cUrl, "PATCH", "", cBody, 120, self:aHeader, @cRetHead)

    If !Empty(cRet)

        oJsonRet:FromJson(cRet)

    EndIf

Return oJsonRet
