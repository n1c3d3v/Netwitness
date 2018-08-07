 
-- Criando o Parser
local hostgetcompare = nw.createParser("hostgetcompare", "extract email headers")
-- Criando as varialveis de ambiente que armazenarao o metadado especifico dependendo do token
hostgetcompare:setKeys({
nwlanguagekey.create("hgequal"),
 
 
})
 
local getval
local hostval
 
 
function hostgetcompare:getcheck(token, first, last)
-- Armazenando uma quantidade de bytes equivalente ao começo do pacote, até o final do token + 50 bytes
local payload = nw.getPayload( 1, last +50 )
-- setando uma variavel para determinar o fim do payload, e assim armazenar apenas os bytes após o token
local endmtoken = payload:find(" ", last + 1, last + 4)
-- caso tal variavel tenha armazenado algum valor.
if endmtoken then
-- armazene esse valor dentro da variavel
                local hgval = payload:tostring(endmtoken +1, endmtoken +50)
               
               
                function hostgetcompare:hostcheck(token, first, last)
-- Armazenando uma quantidade de bytes equivalente ao começo do pacote, até o final do token + 50 bytes
local payload = nw.getPayload( 1, last +50 )
-- setando uma variavel para determinar o fim do payload, e assim armazenar apenas os bytes após o token
local endmtoken = payload:find(" ", last + 1, last + 4)
-- caso tal variavel tenha armazenado algum valor.
if endmtoken then
-- armazene esse valor dentro da variavel
                local hgval = payload:tostring(endmtoken +1, endmtoken +50)
 
 
 
 
 
function hostgetcompare:hgcheck(token, first, last)
-- Armazenando uma quantidade de bytes equivalente ao começo do pacote, até o final do token + 50 bytes
local payload = nw.getPayload( 1, last +50 )
-- setando uma variavel para determinar o fim do payload, e assim armazenar apenas os bytes após o token
local endmtoken = payload:find(" ", last + 1, last + 4)
-- caso tal variavel tenha armazenado algum valor.
if endmtoken then
-- armazene esse valor dentro da variavel
                local hgval = payload:tostring(endmtoken +1, endmtoken +50)
                if string.find(getval, hostval)
                               hgval = 'True'
                               nw.createMeta(self.keys.hgequal, hgval)
                else
                               hgval = 'False'
                               nw.createMeta(self.keys.hgequal, hgval)
               
 
 
 
end
end      
end
 
 
 
 
hostgetcompare:setCallbacks({
["GET [http://]http://"] = hostgetcompare.hgcheck,
["GET [https://]https://"] = hostgetcompare.hgcheck,
["Host:"] = hostgetcompare.hgcheck,
 
 
})
