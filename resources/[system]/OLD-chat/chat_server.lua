RegisterServerEvent('chatCommandEntered')
RegisterServerEvent('chatMessageEntered')

AddEventHandler('chatMessageEntered', function(name, color, message, location)
    if not name or not color or not message or #color ~= 3 then
        return
    end
    local userSource = source
	TriggerEvent('modest:getCharacterFromId', userSource, function(character)
		if character then
			name = character.first_name.." "..character.last_name

			if character.is_cop > 0 and character.job == "cop" then
				name = exports['police-station']:ID2Rank(character.is_cop).." | "..name
				color = {77, 157, 223}
			elseif character.is_ems > 0 and character.job == "ems" then
				name = exports['ems-station']:ID2Rank(character.is_ems).." | "..name
				color = {255, 51, 153}
			else
				name = "Civilian | " .. name
				color = {153, 255, 102}
			end
		end
	end)

    TriggerEvent('chatMessageLocation', userSource, name, message, location)

    if not WasEventCanceled() then
        TriggerClientEvent('chatMessageLocation', -1, name, color, message, location)
    end

    print(name .. ': ' .. message)
end)

-- player join messages
AddEventHandler('playerActivated', function()
    -- TriggerClientEvent('chatMessage', -1, '', { 0, 0, 0 }, '^2* ' .. GetPlayerName(userSource) .. ' joined.')
end)

AddEventHandler('playerDropped', function(reason)
    --TriggerClientEvent('chatMessage', -1, '', { 0, 0, 0 }, '^2* ' .. GetPlayerName(userSource) ..' left (' .. reason .. ')')
	TriggerEvent("gps:removeEMSReqLookup")
end)

-- say command handler
AddEventHandler('rconCommand', function(commandName, args)
    if commandName == "say" then
        local msg = table.concat(args, ' ')

        TriggerClientEvent('chatMessage', -1, 'console', { 0, 0x99, 255 }, msg)
        RconPrint('CONSOLE: ' .. msg .. "\n")

        CancelEvent()
    end
end)

-- tell command handler
AddEventHandler('rconCommand', function(commandName, args)
    if commandName == "tell" then
        local target = table.remove(args, 1)
        local msg = table.concat(args, ' ')

        TriggerClientEvent('chatMessage', tonumber(target), 'console', { 0, 0x99, 255 }, msg)
        RconPrint('CONSOLE: ' .. msg .. "\n")

        CancelEvent()
    end
end)
