local bs = { [0] =
	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
	'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/',
}

db = {}
exposedDB = {}

function db.firstRunCheck()
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/themodestland/_compact", function(err, rText, headers)
	end, "POST", "", {["Content-Type"] = "application/json", Authorization = "Basic " .. auth})

	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/characters/_compact", function(err, rText, headers)
	end, "POST", "", {["Content-Type"] = "application/json", Authorization = "Basic " .. auth})

	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/themodestland", function(err, rText, headers)
		if err == 0 or err == 200 or err == 201 or err == 412 then
			PerformHttpRequest("http://" .. ip .. ":" .. port .. "/characters", function(err, rText, headers)
				if err == 0 or err == 201 or err == 412 then
					print("Welcome to The Modest Land.")
				elseif err == 401 then
					print("CouchDB is messed up!")
				else
					print("Unknown CouchDB error [" .. err .. "]: " .. rText)
				end
			end, "PUT", "", {Authorization = "Basic " .. auth})
		elseif err == 401 then
			print("CouchDB is messed up!")
		else
			print("Unknown CouchDB error [" .. err .. "]: " .. rText)
		end
	end, "PUT", "", {Authorization = "Basic " .. auth})
end

local url = "http://" .. ip .. ":" .. port .. "/"

local function requestDB(request, location, data, headers, callback)
	if request == nil or type(request) ~= "string" then request = "GET" end
	if headers == nil or type(headers) ~= "table" then headers = {} end
	if data == nil or type(data) ~= "table" then data = "" end
	if location == nil or type(location) ~= "string" then location = "" end

	if auth then
		headers.Authorization = 'Basic ' .. auth
	end

	if type(data) == "table" then
		data = json.encode(data)
	end

	PerformHttpRequest(url .. location, function(err, rText, headers)
		if callback then
			if err == 0 then
				err = 200
			end
			callback(err, rText, headers)
		end
	end, request, data, headers)
end

local function getUUID(amount, cb)
	if amount == nil or amount <= 0 then amount = 1 end

	requestDB('GET', '_uuids?count=' .. amount, nil, nil, function(err, rText, headers)
		if err ~= 200 then
			print('Error: Could not retrieve UUID, error code: ' .. err .. ", server returned: " .. rText)
		else
			if cb then
				if amount > 1 then
					cb(json.decode(rText).uuids)
				else
					cb(json.decode(rText).uuids[1])
				end
			end
		end
	end)
end

local function getDocument(uuid, callback)
	requestDB('GET', 'themodestland/' .. uuid, nil, nil, function(err, rText, headers)
		local doc =  json.decode(rText)

		if err ~= 200 then
			print("Error: Couldn't retrieve document, error code: " .. err .. ", server returned: " .. rText)
		else
			if callback then
				if doc then callback(doc) else callback(false) end
			end
		end
	end)
end

local function getCharacterDocument(uuid, callback)
	requestDB('GET', 'characters/' .. uuid, nil, nil, function(err, rText, headers)
		local doc =  json.decode(rText)

		if err ~= 200 then
			print("Error: Couldn't retrieve document, error code: " .. err .. ", server returned: " .. rText)
		else
			if callback then
				if doc then callback(doc) else callback(false) end
			end
		end
	end)
end

local function createDocument(doc, cb)
	if doc == nil or type(doc) ~= "table" then doc = {} end

	getUUID(1, function(uuid)
		requestDB('PUT', 'themodestland/' .. uuid, doc, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
			if err ~= 201 and err ~= 200 then
				print("Error: Couldn't create document error " .. err .. ", returned: " .. rText)
			else
				if cb then
					cb(rText, doc)
				end
			end
		end)
	end)
end

local function createCharacterDocument(doc, cb)
	if doc == nil or type(doc) ~= "table" then doc = {} end

	getUUID(1, function(uuid)
		requestDB('PUT', 'characters/' .. uuid, doc, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
			if err ~= 201 and err ~= 200 then
				print("Error: Couldn't create document error " .. err .. ", returned: " .. rText)
			else
				if cb then
					cb(rText, doc)
				end
			end
		end)
	end)
end

local function updateDocument(docID, updates, callback)
	if docID == nil then docID = "" end
	if updates == nil or type(updates) ~= "table" then updates = {} end

	getDocument(docID, function(doc)
		if doc then
			local update = doc
			for i in pairs(update)do
				if updates[i] then
					update[i] = updates[i]
				end
			end

			requestDB('PUT', 'themodestland/' .. docID, update, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
				if not json.decode(rText).ok then
					if err ~= 409 then
						print("Error: Couldn't update document error " .. err .. ", returned: " .. rText)
					end
				else
					if callback then
						callback(rText)
					end
				end
			end)
		else
			print("Error: Couldn't find document (" .. docID .. ")")
		end
	end)
end

local function updateCharacter(docID, updates, callback)
	if docID == nil then docID = "" end
	if updates == nil or type(updates) ~= "table" then updates = {} end

	getCharacterDocument(docID, function(doc)
		if doc then
			local update = doc
			for i in pairs(update)do
				if updates[i] then
					update[i] = updates[i]
				end
			end

			requestDB('PUT', 'characters/' .. docID, update, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
				if not json.decode(rText).ok then
					if err ~= 409 then
						print("Error: Couldn't update document error " .. err .. ", returned: " .. rText)
					end
				else
					if callback then
						callback(rText)
					end
				end
			end)
		else
			print("Error: Couldn't find document (" .. docID .. ")")
		end
	end)
end

function db.updateUser(identifier, new, callback)
	db.retrieveUser(identifier, function(user)
		updateDocument(user._id, new, function(returned)
			callback(returned)
		end)
	end)
end

function db.updateCharacter(user, callback)
	updateCharacter(user._id, user, function(returned)
		callback(returned)
		for _,v in pairs(Characters) do
			if v._id == user._id then
				Characters[_]._rev = json.decode(returned).rev
			end
		end
	end)
end

function db.createUser(identifier, callback)
	if type(identifier) == "string" and identifier ~= nil then
		createDocument({
			identifier = identifier,
			group = "user",
			permission_level = 0,
		}, function(returned, document)
			if callback then
				callback(returned, document)
			end
		end)
	end
end

function db.createCharacter(character, callback)
	if type(character.identifier) == "string" and character.identifier ~= nil then
		createCharacterDocument({
			identifier = character.identifier,
			first_name = character.first_name,
			last_name = character.last_name,
			gender = character.gender,
			characteristics = {},
			inventory = {},
			licenses = {},
			vehicles = {},
			weapons = {},
			cash = 0,
			bank = 1000,
			is_cop = 0,
			is_ems = 0
		 }, function(returned, document)
			if callback then
				callback(returned, document)
			end
		end)
	end
end

function db.doesUserExist(identifier, callback)
	if identifier ~= nil and type(identifier) == "string" then
		requestDB('POST', 'themodestland/_find', {selector = {["identifier"] = identifier}}, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
			if rText then
				if callback then
					if json.decode(rText).docs[1] then callback(true) else callback(false) end
				end
			else
				print('Error occured.')
			end
		end)
	end
end

function db.retrieveUser(identifier, callback)
	if identifier ~= nil and type(identifier) == "string" then
		requestDB('POST', 'themodestland/_find', {selector = {["identifier"] = identifier}}, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
			local doc =  json.decode(rText).docs[1]
			if callback then
				if doc then callback(doc) else callback(false) end
			end
		end)
	end
end

function db.retrieveCharacters(identifier, callback)
	if identifier ~= nil and type(identifier) == "string" then
		requestDB('POST', 'characters/_find', {selector = {["identifier"] = identifier}}, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
			local doc =  json.decode(rText).docs
			if callback then
				if doc then callback(doc) else callback({}) end
			end
		end)
	else
		print("Error occured while retrieving user, missing parameter or incorrect parameter: identifier")
	end
end

function db.performCheckRunning()
	requestDB('GET', nil, nil, nil, function(err, rText, header)
		print(rText)
	end)
end

--db.firstRunCheck()
db.firstRunCheck()

function exposedDB.createDatabase(db, cb)
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db, function(err, rText, headers)
		if err == 0 then
			cb(true, 0)
		else
			cb(false, rText)
		end
	end, "PUT", "", {Authorization = "Basic " .. auth})
end

function exposedDB.createDocument(db, rows, cb)
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/_uuids", function(err, rText, headers)
		PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db .. "/" .. json.decode(rText).uuids[1], function(err, rText, headers)
			if err == 0 then
				cb(true, 0)
			else
				cb(false, rText)
			end
		end, "PUT", json.encode(rows), {["Content-Type"] = 'application/json', Authorization = "Basic " .. auth})
	end, "GET", "", {Authorization = "Basic " .. auth})
end

function exposedDB.getDocumentByRow(db, row, value, callback)
	local qu = {selector = {[row] = value}}
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db .. "/_find", function(err, rText, headers)
		local t = json.decode(rText)

		if(t)then
			if t.docs then
				if(t.docs[1])then
					callback(t.docs[1])
				else
					callback(false)
				end
			else
				callback(false)
			end
		else
			callback(false, rText)
		end
	end, "POST", json.encode(qu), {["Content-Type"] = 'application/json', Authorization = "Basic " .. auth})
end

function exposedDB.updateDocument(db, documentID, updates, callback)
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db .. "/" .. documentID, function(err, rText, headers)
		local doc = json.decode(rText)

		if(doc)then
			for i in pairs(updates)do
				doc[i] = updates[i]
			end

			PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db .. "/" .. doc._id, function(err, rText, headers)
				callback((err or true))
			end, "PUT", json.encode(doc), {["Content-Type"] = 'application/json', Authorization = "Basic " .. auth})
		end
	end, "GET", "", {["Content-Type"] = 'application/json', Authorization = "Basic " .. auth})
end

AddEventHandler('modest:exposeDBFunctions', function(cb)
	cb(exposedDB)
end)

-- Why the fuck is this required?
local theTestObject, jsonPos, jsonErr = json.decode('{"test":"tested"}')
