AddEventHandler('modest:playerLoaded', function(source, user)
	TriggerClientEvent('modestland:playerLoaded', source)
end)

RegisterServerEvent("modestland:spawnPlayer")
AddEventHandler("modestland:spawnPlayer", function()
	local userSource = source
	TriggerEvent('modest:getPlayerFromId', userSource, function(user)
		TriggerClientEvent("modestland:spawn", userSource)
	end)
end)

-- Announcing
TriggerEvent('modest:addGroupCommand', 'announce', "admin", function(source, args, user)
	table.remove(args, 1)
	TriggerClientEvent('announcement', -1, table.concat(args, " "))
end, function(source, args, user)
	TriggerClientEvent('announcement', source, "Insufficienct permissions!")
end)

AddEventHandler('rconCommand', function(commandName, args)
	if commandName == 'announce' or commandName == 'announcement' then
		local message = table.concat(args, " ")
		if message == "" then
			RconPrint("Usage: announce [message]\n")
			CancelEvent()
			return
		end

		TriggerClientEvent('announcement', -1, message)

		CancelEvent()
	end
end)

function serializeTable(val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0

	local tmp = string.rep(" ", depth)

	if name then tmp = tmp .. name .. " = " end

	if type(val) == "table" then
		tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

		for k, v in pairs(val) do
			tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
		end

		tmp = tmp .. string.rep(" ", depth) .. "}"
	elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
		tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
		tmp = tmp .. (val and "true" or "false")
	else
		tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
	end

	return tmp
end
