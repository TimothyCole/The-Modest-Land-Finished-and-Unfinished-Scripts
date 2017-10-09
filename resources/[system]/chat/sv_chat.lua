RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('_chat:messageEntered', function(name, color, message, location)
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

AddEventHandler('__cfx_internal:commandFallback', function(command)
	local name = GetPlayerName(source)

	TriggerEvent('chatMessage', source, name, '/' .. command)

	if not WasEventCanceled() then
		TriggerClientEvent('chatMessage', -1, name, { 255, 255, 255 }, '/' .. command)
	end

	CancelEvent()
end)

RegisterCommand('say', function(source, args, rawCommand)
	TriggerClientEvent('chatMessage', -1, (source == 0) and 'Government' or GetPlayerName(source), {191, 50, 50}, rawCommand:sub(5))
end)
