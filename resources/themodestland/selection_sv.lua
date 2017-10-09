local Characters = {}

RegisterServerEvent('character:disconnect')
AddEventHandler('character:disconnect', function()
	DropPlayer(source, "Disconnected at character selection.")
end)

RegisterServerEvent('character:getList')
AddEventHandler('character:getList', function()
	local s = source
	TriggerEvent('modest:getCharactersFromIdentifier', GetPlayerIdentifiers(source)[1], function(characters)
		TriggerClientEvent('character:getList', s, characters)
	end)
end)

RegisterServerEvent('character:new')
AddEventHandler('character:new', function(user)
	local s = source
	TriggerEvent('modest:createCharacter', { ['identifier'] = GetPlayerIdentifiers(source)[1], ['first_name'] = user.first_name, ['last_name'] = user.last_name, ['gender'] = user.gender }, function(created)
		TriggerClientEvent('character:new', s, true)
	end)
end)

RegisterServerEvent('character:select')
AddEventHandler('character:select', function(user)
	local s = source

	if user then
		TriggerClientEvent('character:select', source, user)

		if json.encode(user.characteristics) ~= "[]" then
			print(GetPlayerIdentifiers(source)[1] .. " logged in as " .. user.first_name .. " " .. user.last_name)
			RconLog({ msgType = 'characterLoggedIn', netID = source, name = GetPlayerName(source), guid = GetPlayerIdentifiers(source)[1], ip = GetPlayerEP(source), rp = user.first_name .. " " .. user.last_name })

			TriggerEvent("modest:addCharacterById", s, user, function(data)
				TriggerClientEvent("modest:activateMoney", s, data.cash)
			end)
		end
	end
end)

RegisterServerEvent('character:logout')
AddEventHandler('character:logout', function()
	local s = source
	TriggerEvent('modest:removeCharacterById', s, function(updated) end)
end)
