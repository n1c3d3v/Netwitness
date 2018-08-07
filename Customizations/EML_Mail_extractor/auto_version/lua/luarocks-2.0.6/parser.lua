local getPath = nw.createParser("get_path", "extract path from HTTP GET requests")
getPath:setKeys({ nwlanguagekey.create("path"),})
function getPath:httpGet(token, first, last)
local payload = nw.getPayload()
local endOfLine = payload:find(" HTTP/1.1\013\010", last + 1, last + 100)
if endOfLine then
local path = payload:tostring(last + 1, endOfLine - 1)
if path then
nw.createMeta(self.keys.path, path)
end
end
end
getPath:setCallbacks({
["^GET "] = getPath.httpGet,})
