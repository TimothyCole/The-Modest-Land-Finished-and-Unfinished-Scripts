-- Server
Users = {}
Characters = {}
commands = {}
settings = {}
settings.defaultSettings = {
	['pvpEnabled'] = true,
	['permissionDenied'] = false,
	['debugInformation'] = false,
	['enableRankDecorators'] = false,
	['moneyIcon'] = "$",
	['nativeMoneySystem'] = false,
	['commandDelimeter'] = '/'
}
settings.sessionSettings = {}
commandSuggestions = {}

AddEventHandler('playerDropped', function()
	local numberSource = tonumber(source)
	if Users[numberSource] then
		TriggerEvent("modest:playerDropped", Users[numberSource])
		db.updateCharacter(Characters[numberSource], function()
			Users[numberSource] = nil
			Characters[numberSource] = nil
		end)
	end
end)

local justJoined = {}

RegisterServerEvent('modest:firstJoinProper')
AddEventHandler('modest:firstJoinProper', function()
	registerUser(GetPlayerIdentifiers(source)[1], source)
	justJoined[source] = true

	if(settings.defaultSettings.pvpEnabled)then
		TriggerClientEvent("modest:enablePvp", source)
	end
end)

AddEventHandler('modest:setSessionSetting', function(k, v)
	settings.sessionSettings[k] = v
end)

AddEventHandler('modest:getSessionSetting', function(k, cb)
	cb(settings.sessionSettings[k])
end)

RegisterServerEvent('playerSpawn')
AddEventHandler('playerSpawn', function()
	if(justJoined[source])then
		TriggerEvent("modest:firstSpawn", source, Users[source])
		justJoined[source] = nil
	end
end)

AddEventHandler("modest:setDefaultSettings", function(tbl)
	for k,v in pairs(tbl) do
		if(settings.defaultSettings[k] ~= nil)then
			settings.defaultSettings[k] = v
		end
	end

	debugMsg("Default settings edited.")
end)

AddEventHandler('chatMessageLocation', function(source, n, message, location)
	if(startswith(message, settings.defaultSettings.commandDelimeter))then
		local command_args = stringsplit(message, " ")

		command_args[1] = string.gsub(string.lower(command_args[1]), settings.defaultSettings.commandDelimeter, "")

		local command = commands[command_args[1]]

		if(command)then
			CancelEvent()
			if(command.perm > 0)then
				if Users[source].getPermissions() >= command.perm or groups[Users[source].getGroup()]:canTarget(command.group) then
					command.cmd(source, command_args, Users[source], location)
					TriggerEvent("modest:adminCommandRan", source, command_args, Users[source], command)
				else
					command.callbackfailed(source, command_args, Users[source])
					TriggerEvent("modest:adminCommandFailed", source, command_args, Users[source])

					if(type(settings.defaultSettings.permissionDenied) == "string" and not WasEventCanceled())then
						TriggerClientEvent('chatMessage', source, "", {0,0,0}, defaultSettings.permissionDenied)
					end

					debugMsg("Non admin (" .. GetPlayerName(source) .. " " .. Users[source].getGroup() .. ") attempted to run " .. command.group .. " command: " .. command_args[1])
				end
			else
				command.cmd(source, command_args, Users[source], location)
				TriggerEvent("modest:userCommandRan", source, command_args)
			end

			TriggerEvent("modest:commandRan", source, command_args, Users[source])
		else
			TriggerEvent('modest:invalidCommandHandler', source, command_args, Users[source])

			if WasEventCanceled() then
				CancelEvent()
			end
		end
	else
		TriggerEvent('modest:chatMessage', source, message, Users[source])
	end
end)

function addCommand(command, callback, suggestion)
	commands[command] = {}
	commands[command].perm = 0
	commands[command].group = "user"
	commands[command].cmd = callback

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

	debugMsg("Command added: " .. command)
end

AddEventHandler('modest:addCommand', function(command, callback, suggestion)
	addCommand(command, callback, suggestion)
end)

function addAdminCommand(command, perm, callback, callbackfailed)
	commands[command] = {}
	commands[command].perm = perm
	commands[command].group = "superadmin"
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	debugMsg("Admin command added: " .. command .. ", requires permission level: " .. perm)
end

AddEventHandler('modest:addAdminCommand', function(command, perm, callback, callbackfailed)
	addAdminCommand(command, perm, callback, callbackfailed)
end)

function addGroupCommand(command, group, callback, callbackfailed)
	commands[command] = {}
	commands[command].perm = math.maxinteger
	commands[command].group = group
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	debugMsg("Group command added: " .. command .. ", requires group: " .. group)
end

AddEventHandler('modest:addGroupCommand', function(command, group, callback, callbackfailed)
	addGroupCommand(command, group, callback, callbackfailed)
end)

RegisterServerEvent('modest:updatePositions')
AddEventHandler('modest:updatePositions', function(x, y, z)
	if(Users[source])then
		Users[source].setCoords(x, y, z)
	end
end)
