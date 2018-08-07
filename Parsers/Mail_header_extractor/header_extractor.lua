-- Criando o Parser
local headerextract = nw.createParser("header_extracter", "extract email headers")
-- Criando as varialveis de ambiente que armazenarao o metadado especifico dependendo do token
headerextract:setKeys({
nwlanguagekey.create("fireeyeheader"),
nwlanguagekey.create("xwhitelist"),
nwlanguagekey.create("xsmg"),
 
})
 
-- Função executada quando o Token for encontrado, esta tem o objetivo de armazenar uam certa quantidade do payload em uma variavel local, 
-- localizar o metadado desejado para ser armazenado no metakey
function headerextract:fireeyeget(token, first, last)
-- Armazenando uma quantidade de bytes equivalente ao começo do pacote, até o final do token + 50 bytes
local payload = nw.getPayload( 1, last +50 )
-- setando uma variavel para determinar o fim do payload, e assim armazenar apenas os bytes após o token
local endmtoken = payload:find(" ", last + 1, last + 4)
-- caso tal variavel tenha armazenado algum valor.
if endmtoken then
-- armazene esse valor dentro da variavel fireeyeheader
                local fireeye = payload:tostring(endmtoken +1, endmtoken +20)
 
                if fireeye then
-- atribuir o valor da variavel ao novo metakey fireeyeheader
                               nw.createMeta(self.keys.fireeyeheader, fireeye)
 
 
end
end      
end
 
 
 
function headerextract:whitelistget(token, first, last)
-- Armazenando uma quantidade de bytes equivalente ao começo do pacote, até o final do token + 50 bytes
local payload = nw.getPayload( 1, last + 11 )
-- setando uma variavel para determinar o fim do payload, e assim armazenar apenas os bytes após o token
local endmtoken = payload:find(" ", last + 1, last + 4)
-- caso tal variavel tenha armazenado algum valor.
if endmtoken then
-- armazene esse valor dentro da variavel fireeyeheader
                local whitelistval = payload:tostring(endmtoken +1, endmtoken +20)
-- Caso a variavel tenha armazenado algum valor
                if whitelistval then
-- atribuir o valor da variavel ao novo metakey xwhitelist
                               nw.createMeta(self.keys.xwhitelist, whitelistval)
-- Caso o token seja x fireeye
 
 
 
end
end      
end
 
 
function headerextract:xsmgget(token, first, last)
-- Armazenando uma quantidade de bytes equivalente ao começo do pacote, até o final do token + 50 bytes
local payload = nw.getPayload( 1, last + 11 )
-- setando uma variavel para determinar o fim do payload, e assim armazenar apenas os bytes após o token
local endmtoken = payload:find(" ", last + 1, last + 4)
-- caso tal variavel tenha armazenado algum valor.
if endmtoken then
-- armazene esse valor dentro da variavel fireeyeheader
                local xsmgval = payload:tostring(endmtoken +1, endmtoken +20)
-- Caso a variavel tenha armazenado algum valor
                if xsmgval then
-- atribuir o valor da variavel ao novo metakey xwhitelist
                               nw.createMeta(self.keys.xsmg, xsmgval)
-- Caso o token seja x fireeye
 
 
 
end
end      
end
 
 
headerextract:setCallbacks({
["X-FireEye:"] = headerextract.fireeyeget,
["X-PMX-WhiteList:"] = headerextract.whitelistget,
["x-smg-gsip:"] = headerextract.xsmgget,
 
})
