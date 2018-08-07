-- 2013.06.20.1

if nw then
	-- do not load this file if nw is already defined
	error(... .. ".lua should not be loaded as a parser/module file")
end

--[[

This file provides documentation for the NextGen parser API and is a working stub for use
in IDE's and validating basic syntax and structure using a stand-alone lua engine.

The only unrepresented functionality at this point is install decoder, is decoding,
transient meta, and packet id.

--]]

-- These enumerations define the list of callbacks the script can receive as a session is
-- being parsed (see setEvents).
-- Individual event objects can be compared against event ids returned in event handlers
-- using their value field (i.e. nwevents.OnInit.value).
-- NOTE: the values assigned here have no meaning and are just placeholders
nwevents = {}
nwevents.OnInit = 0			-- fired when the parsing engine is initialized, only once.
nwevents.OnStart = 0		-- fired when the system starts capture.
nwevents.OnStop = 0			-- fired when the system stops capture.
nwevents.OnReset = 0		-- fired each time a stream is found and parsing begins on that stream.
nwevents.OnSessionBegin = 0	-- fired at the beginning of each session parsed.
nwevents.OnSessionEnd = 0	-- fired at the end of each session parsed.
nwevents.OnStreamBegin = 0	-- fired at the beginning of each stream parsed.
nwevents.OnStreamEnd = 0	-- fired at the end of each stream parsed.
nwevents.OnRequestBegin = 0	-- fired at the beginning of each request stream parsed.
nwevents.OnRequestEnd = 0	-- fired at the end of each request stream parsed.
nwevents.OnResponseBegin = 0-- fired at the beginning of each response stream parsed.
nwevents.OnResponseEnd = 0	-- fired at the end of each response stream parsed.

-- These enumerations define the list of possible data types that can be used for a index
-- key (see setKeys)
-- NOTE: the values assigned here have no meaning and are just placeholders
nwtypes ={}
nwtypes.Int8 = 0			-- A signed 8 bit number
nwtypes.UInt8 = 0			-- An unsigned 8 bit number
nwtypes.Int16 = 0			-- A signed 16 bit number
nwtypes.UInt16 = 0			-- An unsigned 16 bit number
nwtypes.Int32 = 0			-- A signed 32 bit number
nwtypes.UInt32 = 0			-- An unsigned 32 bit number
nwtypes.Int64 = 0			-- A signed 64 bit number
nwtypes.UInt64 = 0			-- An unsigned 64 bit number
nwtypes.UInt128 = 0			-- An unsigned 128 bit number
nwtypes.Float32 = 0			-- A 32 bit floating point number
nwtypes.Float64 = 0			-- A 64 bit floating point number
nwtypes.TimeT = 0			-- A 64 bit time representing the number of seconds from EPOCH
nwtypes.DayOfWeek = 0		-- A 8 bit integer representing the day of the week (0=Sunday, Saturday=6)
nwtypes.HourOfDay = 0		-- A 8 bit integer representing the hours of the day (0-23)
nwtypes.Binary = 0			-- Free form binary data (256 byte max)
nwtypes.Text = 0			-- Free form text (256 character max)
nwtypes.IPv4 = 0			-- A IPv4 address
nwtypes.IPv6 = 0			-- A IPv6 address
nwtypes.MAC = 0				-- A MAC address

nw = {}
nwlanguagekey = {}
nwpayload = {}
nwsession = {}
nwstream = {}
nwpacket = {}

-- nwlanguagekey.create(name [, keyFormat [, description]])
-- keyFormat defaults to nwtype.Text and description is optional.
function nwlanguagekey.create(name, keyFormat, description)
	local result = {}
	result.name = name
	result.description = description and description or ""
	result.type = keyFormat and keyFormat or nwtypes.Text
	return result
end

-- returns the system default meta for path components (i.e. "filename", "directory", and
-- "extension").
function nwlanguagekey.getPathDefaults()
	return nwlanguagekey.create("filename"),
		   nwlanguagekey.create("directory"),
		   nwlanguagekey.create("extension")
end

-- nw.createParser(name, description [, appType])
-- Creates a new instance of a parser. This function must be called as the first line of
-- the script so that other parts of the script can reference the parser object. The name
-- is the system identifier given to the parser. Usually with no spaces. The desc can be
-- free text. The appType is used by the system to identify the application type as meta
-- is created.
function nw.createParser(name, description, appType)

	local parser = {}

	-- parser:setKeys(keysTable [, fileMeta, dirMeta, extMeta])
	-- Registers which keys the parser will create meta data for. The first parameter is a
	-- list of LanguageKeys and the path parameters are individual LanguageKeys.
	-- Example:
	--	parser:setKeys({nwlanguagekey.create("alert")})
	function parser:setKeys(keysTable, fileMeta, dirMeta, extMeta) end

	-- parser:setPorts(portsList)
	-- Registers which ports this parser would like to be notified on. When the system
	-- identifies a port it will fire the event if that port matches on what was
	-- registered. The first parameter is a table where the key is a port number and the
	-- value is a locally defined function callback. The setPorts function should be
	-- called in the script AFTER the call to createParser() and AFTER the callback
	-- function definition. The callback function will have a single argument (the port
	-- number) and any results will be discarded.
	-- Example:
	--	parser:setPorts({80 = function(port) end})
	function parser:setPorts(portsList) end

	-- parser:setTokens(tokensTable)
	-- Registers which tokens this parser would like to be notified on. When the system
	-- identifies a token it will fire the event if that token matches what was
	-- registered. The first parameter is a table where the key is a token string and the
	-- value is a locally defined function callback. The setTokens function should be
	-- called in the script AFTER the call to createParser() and AFTER the callback
	-- function definition.
	-- To match the token at line start or packet break, add '^' to the beginning of the
	-- token (e.g. "^USER"). To match the token at line end add a '$' to the end of the
	-- token (e.g. "USER$"). Use '%' to escape if necessary, where '%c' -> 'c' for any
	-- character c (e.g. "%^abc%1%%23%$" -> "^abc1%23$").
	-- The callback will pass the token index defined in self.tokens (e.g.
	-- self.tokens[token]) and the index of the first and last characters of the token
	-- occur in the payload (i.e. token, first,last). Any results from the callback are
	-- discarded.
	-- Example:
	--	parser:setTokens({["GET /"] = function(token, first, last) end})
	function parser:setTokens(tokensTable) end

	-- parser:setEvents(eventsTable)
	-- Registers which system events this parser would like to be notified on. When the
	-- system hits a state it will fire the event that was registered. The only parameter
	-- is a table keyed by LanguageKeys and the value is a locally defined function
	-- callback. The setEvents function should be called in the script AFTER the call to
	-- createParser() and AFTER the callback function definition.  The callback receives
	-- the event id as the only argument and any results are discarded.
	-- Example:
	--	parser:setEvents({[nwtypes.OnSessionBegin] = function(event) end})
	function parser:setEvents(eventsTable) end

	-- parser:setMeta(metaTable)
	-- Registers meta fields this parser would like to be notified on. When the system
	-- creates a meta value of the specified types, it will fire the event that was
	-- registered. The first parameter is a table where the key is an event enumeration
	-- and the value is a locally defined function callback. The setEvents function should
	-- be called in the script AFTER the call to createParser() and AFTER the callback
	-- function definition. The callback will pass the meta index defined in self.meta
	-- (e.g. self.meta[LanguageKey]) and the value created.
	-- Example:
	--	parser:setEvents({[nwlanguagekey.create("alert")] = function(meta, value) end})
	function parser:setMeta(metaTable) end

	-- parser:setCallbacks(callbacksTable)
	-- A single function for performing port, token, event, and meta callback
	-- registration.  The setCallbacks function should be called in the script AFTER the
	-- call to createParser() and AFTER the callback function definition.  Refer to the
	-- appropriate function for callback signatures.
	-- Example:
	--	parser:setCallbacks({
	--		[80]						= function(port) end,					-- port
	--		["GET /"]					= function(token, first, last) end		-- token
	--		[nwevents.OnSessionBegin]	= function(event) end,					-- event
	--		[nwlanguagekey.create("alert")]	= function(value) end				-- meta
	--	})
	function parser:setCallbacks(callbacksTable) end

	-- parser:createPathMeta(value [, encoding] [, fileMeta [, dirMeta [, extMeta]]])
	-- Create path meta from a single value.  The meta types can be omitted if specified
	-- by the call to setKeys.
	-- An optional encoding can be specified as a string or payload.  If specified, value
	-- will be converted from the specified encoding to utf-8.
	function parser:createPathMeta(value, encoding, fileMeta, dirMeta, extMeta) end

	-- parser:getSharedValue(name)
	-- Get the shared value in the parser's shared namespace with the specified name.  If
	-- no such shared value exists, nil is returned.
	function parser:getSharedValue(name) end
	
	-- parser:setSharedValue(name)
	-- Create or update a boolean, number, or string value in the parser's shared
	-- namespace.  This value is accessible across all instances of the parser.
	function parser:setSharedValue(name, value) end

	-- parser:removeSharedValue(name)
	-- Remove the specified shared value from the parser's shared namespace.  If the
	-- value does not exist, this function has no effect.
	function parser:removeSharedValue(name) end

	return parser
end

-- nw.logDebug(msg)
-- Logs a debug message to the logging system. Expects the first parameter to be the
-- message.
function nw.logDebug(msg) end

-- nw.logInfo(msg)
-- Logs a informational message to the logging system. Expects the first parameter to be
-- the message.
function nw.logInfo(msg) end

-- nw.logWarning(msg)
-- Logs a warning message to the logging system. Expects the first parameter to be the
-- message.
function nw.logWarning(msg) end

-- nw.logFailuer(msg)
-- Logs a failure message to the logging system. Expects the first parameter to be the
-- message.
function nw.logFailure(msg) end

-- nw.getAppType()
-- Get the application type for the current session, may be zero if not yet assigned.
-- Returns the app type.
function nw.getAppType() end

-- nw.setAppType(appType)
-- Sets the application type (e.g. 21 for FTP) for the current session.
function nw.setAppType(appType) end

-- nw.getTransport()
-- returns the current transport protocol (udp/tcp), source port, and destination port.
function nw.getTransport() end

-- nw.getNetworkProtocol()
-- returns the current network protocol (ipv4/ipv6)
function nw.getNetworkProtocol() end

-- nw.createMeta(key, value [, j] [, encoding])
-- Creates meta of type key (e.g. self.keys.username) with the provided value.
-- value can be be of any lua value type or payload, but must be an index if the optional
-- index j is provided.
-- Strings and payloads are coerced to numeric types as if the had a textual
-- representation of the value (e.g. a payload referencing "123" will be coerced to the
-- base 10 numeric 123).
-- An optional encoding can be specified as a string or payload.  If specified, value will
-- be converted from the specified encoding to utf-8.
function nw.createMeta(key, value, j, encoding) end

-- nw.base64Decode(value)
-- Return a string containing the decoded bytes for base64 encoded string value.
function nw.base64Decode(value) end

-- nw.getSessionSource()
-- Get a string representation of the network (ipv4/ipv6) source address
-- NOTE: this is equivalent to nwsession.getSource() 
function nw.getSessionSource() end

-- nw.getSessionDestination()
-- Get a string representation of the network (ipv4/ipv6) destination address
-- NOTE: this is equivalent to nwsession.getDestination() 
function nw.getSessionDestination() end

-- nw.getSessionAddresses()
-- Get a string representation of the network (ipv4/ipv6) source and destination addresses
-- Example:
--	local src, dst = nw.getSessionAddresses()
-- NOTE: this is equivalent to nwsession.getAddresses() 
function nw.getSessionAddresses() end

-- nw.getSessionPorts()
-- Get the source and destination ports (tcp/udp)
-- Example:
--	local src, dst = nw.getSessionPorts()
-- NOTE: this is equivalent to nwsession.getPorts() 
function nw.getSessionPorts() end

-- nw.getSessionStats()
-- Get the number of streams, packets, bytes and payload bytes for the current session.
-- Example:
--	local streams, packets, bytes, pBytes = nw.getSessionStats()
-- NOTE: this is equivalent to nwsession.getStats() 
function nw.getSessionStats() end

-- nw.getStreamStats([s])
-- Get the number of packets, bytes, payload bytes, retransmitted packets, and
-- retransmitted payload bytes for the stream s.  If s is not specified it defaults to
-- the current stream.
-- Example:
--	local packets, bytes, pBytes, rPackets, rBytes = nw.getStreamStats()
-- NOTE: this is equivalent to nwstream.getSource() 
function nw.getStreamStats(s) end

-- nw.isRequestStream([s])
-- Returns true if the stream s is the request stream of the session.  If s is not
-- specified it defaults to the current stream.
-- NOTE: this is equivalent to nwstream.isRequest() 
function nw.isRequestStream(s) end

-- nw.isResponseStream([s])
-- Returns true if the current stream is the response stream of the session.  If s is not
-- specified it defaults to the current stream.
-- NOTE: this is equivalent to nwstream.isResponse() 
function nw.isResponseStream(s) end

-- nw.getPayload([s], [i [, j]])
-- Returns a payload object for the current or optionally specified stream that can be
-- manipulated as a lua string.  If there is no current stream (e.g. init, start/stop,
-- reset) the result will be nil.
-- i and j are optional, defaulting to 1 and -1 respectively.
-- WARINING:
--		A payload object is only valid for the life of a current session. Accessing a
--		saved payload object in a subsequent session will result in an error.
function nw.getPayload(s, i, j) end

-- nwpayload.byte(p [, i [, j]] [, le])
-- same as string.byte(s, [,i [, j]]) with i defaulting to 1 and j defaulting to i.
-- NOTE: this is equivalent to nwpayload.uint8.  The le argument (see nwpayload.uint8) 
-- is accepted and verified but has no effect.
function nwpayload.byte(p, i, j, le) end

-- nwpayload.short(p [, i [, j]] [, le])
-- NOTE: this is equivalent to nwpayload.int16 which should be prefered.
function nwpayload.short(p, i, j, le) end

-- nwpayload.int(p [, i [, j]] [, le])
-- NOTE: this is equivalent to nwpayload.int32 which should be prefered.
function nwpayload.int(p, i, j) end

-- nwpayload.int8(p [, i [, j]] [, le])
-- Return a single byte, signed value for each payload byte from indices i to j.  i
-- defaults to 1 and j defaults to i.  The endianess argument le is accepted and type
-- verified (must be a boolean) but has no effect reading single byte values.
function nwpayload.int8(p, i, j, le) end

-- nwpayload.uint8(p [, i [, j]] [, le])
-- Return a single byte, unsigned value for each payload byte from indices i to j.  i
-- defaults to 1 and j defaults to i.  The endianess argument le is accepted and type
-- verified (must be a boolean) but has no effect reading single byte values.
function nwpayload.uint8(p, i, j, le) end

-- nwpayload.int16(p [, i [, j]] [, le])
-- Return two byte, signed values for each pair of payload bytes from indices i to j (any
-- remaining bytes are ignored).  i defaults to 1 and j defaults to i + 1.  Endianess is
-- controlled by the parameter le which defaults to false (big endian).
function nwpayload.int16(p, i, j, le) end

-- nwpayload.uint16(p [, i [, j]] [, le])
-- Return two byte, unsigned values for each pair of payload bytes from indices i to j
-- (any remaining bytes are ignored).  i defaults to 1 and j defaults to i + 1.
-- Endianess is controlled by the parameter le which defaults to false (big endian).
function nwpayload.uint16(p, i, j, le) end

-- nwpayload.int32(p [, i [, j]] [, le])
-- Return four byte, signed values for each quartet of payload bytes from indices i to j
-- (any remaining bytes are ignored).  i defaults to 1 and j defaults to i + 1.
-- Endianess is controlled by the parameter le which defaults to false (big endian).
function nwpayload.int32(p, i, j, le) end

-- nwpayload.uint32(p [, i [, j]] [, le])
-- Return four byte, unsigned values for each quartet of payload bytes from indices i to j
-- (any remaining bytes are ignored).  i defaults to 1 and j defaults to i + 1.
-- Endianess is controlled by the parameter le which defaults to false (big endian).
function nwpayload.uint32(p, i, j, le) end

-- nwpayload.tostring(p [, i [, j]])
-- similar to nwpayload.sub with the result being the bytes at the referenced indices
-- copied into a lua string instead of a payload.  i defaults to 1 and j to -1.
function nwpayload.tostring(p, i, j) end

-- nwpayload.find(p, pattern [, i [, j]])
-- Similar to string.find
-- The pattern is always considered a literal (as if the plain parameter of string.find
-- were set to true). The i is the starting position of the find (inclusive) and the j is
-- the 1 based terminating index of the find (inclusive), the default value is -1.
function nwpayload.find(p, pattern, i, j) end

-- nwpayload.len(p)
-- Same as string.len(s) (see http://www.lua.org/manual/5.1/manual.html#pdf-string.len)
function nwpayload.len(p) end

-- nwpayload.sub(p, i [, j])
-- Same as string.sub(p) (see http://www.lua.org/manual/5.1/manual.html#pdf-string.sub)
-- The returned value, if not nil, is a lua string and has no dependencies on the payload
-- object
function nwpayload.sub(p, i, j) end

-- nwpayload.pos(p)
-- return the index into the stream of the start of the payload object
function nwpayload.pos(p) end

-- nwpayload.equal(p, value)
-- determine if the payload or lua string contains the same value
function nwpayload.equal(p, value) end

-- nwpayload.getPacketPayload(p)
-- get the payload object for the first packet in the current payload
function nwpayload.getPacketPayload(p) end

-- nwpayload.getNextPacketPayload(p)
-- get the payload object for the packet following the begining of the current payload
function nwpayload.getNextPacketPayload(p) end

-- nwsession.getStats()
-- Get the number of streams, packets, bytes and payload bytes for the current session.
-- Example:
--	local streams, packets, bytes, pBytes = nwsession.getStats()
function nwsession.getStats() end

-- nwsession.getSource()
-- Get a string representation of the network (ipv4/ipv6) source address
function nwsession.getSource() end

-- nwsession.getDestination()
-- Get a string representation of the network (ipv4/ipv6) destination address
function nwsession.getDestination() end

-- nwsession.getAddresses()
-- Get a string representation of the network (ipv4/ipv6) source and destination addresses
-- Example:
--	local src, dst = nwsession.getAddresses()
function nwsession.getAddresses() end

-- nwsession.getPorts()
-- Get the source and destination ports (tcp/udp)
-- Example:
--	local src, dst = nwsession.getPorts()
function nwsession.getPorts() end

-- nwsession.getRequestStream()
-- Return the request stream object for the current session or nil if the current session
-- does not have a request stream.
function nwsession.getRequestStream() end

-- nwsession.getResponseStream()
-- Return the response stream object for the current session or nil if the current session
-- does not have a response stream.
function nwsession.getResponseStream() end

-- nwsession.getFirstPacket()
-- Return the first packet in the session.
function nwsession.getFirstPacket() end

-- nwsession.getLastPacket()
-- Return the last packet in the session.
function nwsession.getLastPacket() end

-- nwstream.getStats([s])
-- Get the number of packets, bytes, payload bytes, retransmitted packets, and
-- retransmitted payload bytes for the stream s.  If s is not specified, the current
-- stream will be used.
-- Example:
--	local packets, bytes, pBytes, rPackets, rBytes = nwstream.getStats(requestStream)
function nwstream.getStats(s) end

-- nwstream.isRequest([s])
-- Returns true if stream s is the request stream of the session, false otherwise.  s
-- defaults to the current stream.
function nwstream.isRequest(s) end

-- nwstream.isResponse([s])
-- Returns true if stream s is the response stream of the session, false otherwise.  s
-- defaults to the current stream.
function nwstream.isResponse(s) end

-- nwstream.getFirstPacket([s])
-- Return the first packet in stream s.  s defaults to the current stream.
function nwstream.getFirstPacket(s) end

-- nwstream.getLastPacket([s])
-- Return the last packet in stream s.  s defaults to the current stream.
function nwstream.getLastPacket(s) end

-- nwstream.getPayload([s], [i [, j]])
-- Return the 
function nwstream.getPayload(s, i, j) end

-- nwpacket.hasSessionNext(p)
-- Return true if packet p is not the last packet in the session, false otherwise.
function nwpacket.hasSessionNext(p) end

-- nwpacket.hasSessionPrevious(p)
-- Return true if packet p is not the first packet in the session, false otherwise.
function nwpacket.hasSessionPrevious(p) end

-- nwpacket.getSessionNext(p)
-- Return the packet following p in the session or nil if p is the last packet in the
-- session.  All packets present in the session can be accessed in the order which they
-- were captured.
function nwpacket.getSessionNext(p) end

-- nwpacket.getSessionPrevious(p)
-- Return the packet preceding p in the session or nil if p is the first packet in the
-- session.  All packets present in the session can be accessed in the order which they
-- were captured.
function nwpacket.getSessionPrevious(p) end

-- nwpacket.hasStreamNext(p)
-- Return true if packet p is not the last packet in the stream it belongs to, false
-- otherwise.
function nwpacket.hasStreamNext(p) end

-- nwpacket.hasStreamPrevious(p)
-- Return true if packet p is not the first packet in the stream it belongs to, false
-- otherwise.
function nwpacket.hasStreamPrevious(p) end

-- nwpacket.getStreamNext(p)
-- Return the packet following p in the stream it belongs to or nil if p is the last
-- packet in the stream.  Streams account for TCP sequencing, re-ordering/removing
-- packets to handle out of order packets and retransmits.
function nwpacket.getStreamNext(p) end

-- nwpacket.getStreamPrevious(p)
-- Return the packet preceding p in the stream it belongs to or nil if p is the last
-- packet in the stream.  Streams account for TCP sequencing, re-ordering/removing
-- packets to handle out of order packets and retransmits.
function nwpacket.getStreamPrevious(p) end

-- nwpacket.getTimestamp(p)
-- get the capture time in seconds and milliseconds for packet p
function nwpacket.getTimestamp(p) end

-- nwpacket.getSize(packet)
-- get the total bytes and payload bytes for packet p
function nwpacket.getSize(p) end

-- nwpacket.getTcpSeqAndFlags(p)
-- get the TCP sequence number and flags for packet p (both will be 0 if p does not
-- contain a TCP frame).
function nwpacket.getTcpSeqAndFlags(p) end

-- nwpacket.getPayload(p [, i [, j]])
-- get a payload object referencing the payload bytes (or subset) for packet p. 
function nwpacket.getPayload(p, i, j) end

-- nwpacket.byte(p [, i [, j]] [, le])
-- same as string.byte(s, [,i [, j]]) with i defaulting to 1 and j defaulting to i.
-- NOTE: this is equivalent to nwpacket.uint8.  The le argument (see nwpacket.uint8) 
-- is accepted and verified but has no effect.
function nwpacket.byte(p, i, j, le) end

-- nwpacket.int8(p [, i [, j]] [, le])
-- Return a single byte, signed value for each payload byte from indices i to j.  i
-- defaults to 1 and j defaults to i.  The endianess argument le is accepted and type
-- verified (must be a boolean) but has no effect reading single byte values.
function nwpacket.int8(p, i, j, le) end

-- nwpacket.uint8(p [, i [, j]] [, le])
-- Return a single byte, unsigned value for each payload byte from indices i to j.  i
-- defaults to 1 and j defaults to i.  The endianess argument le is accepted and type
-- verified (must be a boolean) but has no effect reading single byte values.
function nwpacket.uint8(p, i, j, le) end

-- nwpacket.int16(p [, i [, j]] [, le])
-- Return two byte, signed values for each pair of payload bytes from indices i to j (any
-- remaining bytes are ignored).  i defaults to 1 and j defaults to i + 1.  Endianess is
-- controlled by the parameter le which defaults to false (big endian).
function nwpacket.int16(p, i, j, le) end

-- nwpacket.uint16(p [, i [, j]] [, le])
-- Return two byte, unsigned values for each pair of payload bytes from indices i to j
-- (any remaining bytes are ignored).  i defaults to 1 and j defaults to i + 1.
-- Endianess is controlled by the parameter le which defaults to false (big endian).
function nwpacket.uint16(p, i, j, le) end

-- nwpacket.int32(p [, i [, j]] [, le])
-- Return four byte, signed values for each quartet of payload bytes from indices i to j
-- (any remaining bytes are ignored).  i defaults to 1 and j defaults to i + 1.
-- Endianess is controlled by the parameter le which defaults to false (big endian).
function nwpacket.int32(p, i, j, le) end

-- nwpacket.uint32(p [, i [, j]] [, le])
-- Return four byte, unsigned values for each quartet of payload bytes from indices i to j
-- (any remaining bytes are ignored).  i defaults to 1 and j defaults to i + 1.
-- Endianess is controlled by the parameter le which defaults to false (big endian).
function nwpacket.uint32(p, i, j, le) end

-- nwpacket.tostring(p [, i [, j]])
-- Copy the packet bytes from indices i to j into a Lua string.  i defaults to 1 and j to
-- -1.
-- NOTE: Converting packets to Lua strings is processor and memory intensive and could
-- negatively impact system performance if used improperly.
function nwpacket.tostring(p, i, j) end
