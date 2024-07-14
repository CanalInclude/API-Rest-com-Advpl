#INCLUDE 'Protheus.ch'

// Busca e valida o token de autenticação
User Function Teste()

    Local oApi := ConApi():New()
    Local xRet := ''
    

    // Teste de autenticação
    xRet := oApi:TestAuth()

Return xRet


// Busca produtos
User Function Teste1()

    Local oApi := ConApi():New()
    Local xRet := ''
    Local i := 0
    Local aProdutos := {}

    // Teste de busca e leitura de produtos
    xRet := oApi:GetProducts(5)

    // Varredura dos produtos retornados no JSON
    For i := 1 to Len( xRet['products'] )

        Aadd( aProdutos, { xRet['products'][i]['id'],;
                           xRet['products'][i]['title'],;
                           xRet['products'][i]['price'] } )

    Next i

Return xRet


// Adiciona produto
User Function Teste2()

    Local oApi := ConApi():New()
    Local xRet := ''
    Local oJsonProd := JsonObject():New()

    oJsonProd['title'] := 'Canal Include'
    oJsonProd['price'] := 123
    oJsonProd['descrição'] := 'Aprendendo a consumir API Rest'

    xRet := oApi:AddProduct(oJsonProd)

Return xRet


// Altera produto
User Function Teste3()

    Local oApi := ConApi():New()
    Local xRet := ''
    Local oJsonProd := JsonObject():New()

    oJsonProd['title'] := 'Samsung Galaxy S24'
    oJsonProd['price'] := 449

    xRet := oApi:ModifyProduct(oJsonProd, 1)

Return xRet

// Altera o produto com método Patch
User Function Teste4()

    Local oApi := ConApi():New()
    Local xRet := ''
    Local oJsonProd := JsonObject():New()

    oJsonProd['title'] := 'Samsung Galaxy S24'
    oJsonProd['price'] := 449

    xRet := oApi:ModifyPatch(oJsonProd, 1)

Return xRet


// Exclui produto
User Function Teste5()

    Local oApi := ConApi():New()
    Local xRet := ''

    xRet := oApi:DeleteProduct(1)

Return xRet
 