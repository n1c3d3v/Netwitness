local basestrike = nw.createParser("basestrik", "itentify the usage of base href tag")
basestrike:setKeys({
nwlanguagekey.create("basehref.tag"),
nwlanguagekey.create("basehref.value"),
nwlanguagekey.create("basehref.full"),
})


function basestrike:basexist(token, first, last)
local payload = nw.getPayload( 1, last + 200 )
local endmtoken = payload:find("=", last - 2, last + 4)
local bvalue = payload:find(">", endmtoken + 2, endmtoken +100)

if endmtoken then
nw.logInfo("primeira funcao rodou")
basehref = payload:tostring(endmtoken + 2, bvalue -2)

if basehref then
nw.createMeta(self.keys["basehref.tag"], "exists")
nw.createMeta(self.keys["basehref.value"], basehref)
nw.logInfo("final da primeira funcao")
end
end       
end


function basestrike:hrefexist(token, first, last)
nw.logInfo("encontrei o token")
local payload = nw.getPayload( 1, last + 200 )
local endmtoken = payload:find("href=", last, last + 20)
local bvalue2 = payload:find(">", endmtoken + 6 , endmtoken + 100)

nw.logInfo("valor do endmtoken")
nw.logInfo(endmtoken)
if endmtoken then

local hrefull = payload:tostring(endmtoken + 6, bvalue2 -2)
nw.logInfo(hrefull)
if basehref and hrefull then
local fullhref = basehref .. hrefull
nw.logInfo(fullhref)
nw.createMeta(self.keys["basehref.full"], fullhref)


end
end       
end

basestrike:setCallbacks({
["<base href="] = basestrike.basexist,
["<a"] = basestrike.hrefexist,
})
