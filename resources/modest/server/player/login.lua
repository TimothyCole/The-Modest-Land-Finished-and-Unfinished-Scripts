function LoadUser(identifier, source, new)
	db.retrieveUser(identifier, function(user)
		Users[source] = CreatePlayer(source, user.identifier, user.group)
		TriggerEvent('modest:playerLoaded', source, Users[source])

		TriggerClientEvent('modest:setPlayerDecorator', source, 'rank', Users[source]:getPermissions())
		TriggerClientEvent('modest:setMoneyIcon', source, settings.defaultSettings.moneyIcon)

		for k,v in pairs(commandSuggestions) do
			TriggerClientEvent('chat:addSuggestion', source, settings.defaultSettings.commandDelimeter .. k, v.help, v.params)
		end

		if new then
			TriggerEvent('modest:newPlayerLoaded', source, Users[source])
		end
	end)
end

function getPlayerFromId(id)
	return Users[id]
end

function stringsplit(inputstr, sep)
	if sep == nil then
			sep = "%s"
		end
		local t={} ; i=1
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
		end
	return t
end

AddEventHandler("modest:removeCharacterById", function(s, cb)
	Characters[s] = nil
end)

AddEventHandler("modest:addCharacterById", function(s, data, cb)
	Characters[s] = data
	Characters[s].job = "civ"
	TriggerEvent('modest:characterLoaded', s, Characters[s])
	TriggerClientEvent('pd:is_cop', s, Characters[s].is_cop)
	TriggerClientEvent('ems:is_ems', s, Characters[s].is_ems)
	Characters[s].setCash = function(m)
		local prevMoney = Characters[s].cash
		local newMoney = m

		Characters[s].cash = m

		if (prevMoney - newMoney) < 0 then
			TriggerClientEvent("modest:addedMoney", s, math.abs(prevMoney - newMoney), false)
		else
			TriggerClientEvent("modest:removedMoney", s, math.abs(prevMoney - newMoney), false)
		end

		TriggerClientEvent("modest:activateMoney", s, Characters[s].cash, false)
	end
	Characters[s].addCash = function(m)
		TriggerClientEvent("modest:addedMoney", s, m, false)
		Characters[s].cash = Characters[s].cash + m
		TriggerClientEvent("modest:activateMoney", s, Characters[s].cash, false)
	end
	Characters[s].removeCash = function(m)
		TriggerClientEvent("modest:removedMoney", s, m, false)
		Characters[s].cash = Characters[s].cash - m
		TriggerClientEvent("modest:activateMoney", s, Characters[s].cash, false)
	end
	Characters[s].setVehicles = function(v)
		Characters[s].vehicles = v
	end
	Characters[s].setLicenses = function(l)
		Characters[s].licenses = l
	end
	Characters[s].setInventory = function(i)
		Characters[s].inventory = i
	end
	Characters[s].setWeapons = function(w)
		Characters[s].weapons = w
	end
	cb(Characters[s])
end)

AddEventHandler("modest:changeCharacterById", function(s, param, value, cb)
	if(Characters)then
		if(Characters[s])then
			for _,v in pairs(Characters[s]) do
				if _ == param then
					Characters[s][_] = value
				end
			end

			db.updateCharacter(Characters[s], function(created)
				cb(Characters[s])
			end)
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)

AddEventHandler("modest:changeCharacterJobById", function(s, job, cb)
	if(Characters)then
		if(Characters[s])then
			Characters[s].job = job
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)

AddEventHandler("modest:getCharacterFromId", function(s, cb)
	if(Characters)then
		if(Characters[s])then
			cb(Characters[s])
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)

AddEventHandler('modest:getPlayers', function(cb)
	cb(Users)
end)

function registerUser(identifier, source)
	db.doesUserExist(identifier, function(exists)
		if exists then
			LoadUser(identifier, source, false)
		else
			db.createUser(identifier, function(r, user)
				LoadUser(identifier, source, true)
			end)
		end
	end)
end

AddEventHandler("modest:setPlayerData", function(user, k, v, cb)
	if Users[user] then
		if Users[user].get(k) then
			Users[user].set(k, v)

			db.updateUser(Users[user].get('identifier'), {[k] = v}, function(d)
				if d == true then
					cb("Player data edited", true)
				else
					cb(d, false)
				end
			end)
		else
			cb("Column does not exist!", false)
		end
	else
		cb("User could not be found!", false)
	end
end)

AddEventHandler("modest:setPlayerDataId", function(user, k, v, cb)
	db.updateUser(user, {[k] = v}, function(d)
		cb("Player data edited.", true)
	end)
end)

AddEventHandler("modest:getCharactersFromIdentifier", function(identifier, cb)
	db.retrieveCharacters(identifier, function(user)
		cb(user)
	end)
end)

AddEventHandler("modest:getPlayerFromId", function(user, cb)
	if(Users)then
		if(Users[user])then
			cb(Users[user])
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)

AddEventHandler("modest:createCharacter", function(character, cb)
	db.createCharacter(character, function(created)
		cb(created)
	end)
end)

AddEventHandler("modest:getPlayerFromIdentifier", function(identifier, cb)
	db.retrieveUser(identifier, function(user)
		cb(user)
	end)
end)

AddEventHandler("modest:updateCharacter", function(account, cb)
	db.updateCharacter(account, function(created)
		cb(created)
	end)
end)

local function savePlayerData()
	SetTimeout(600000, function()
		for _,v in pairs(Characters) do
			if Characters[_] ~= nil and json.encode(Characters[_].characteristics) ~= "[]" then
				TriggerEvent("modest:updateCharacter", Characters[_], function(created) end)
			end
		end

		savePlayerData()
	end)
end

savePlayerData()
