players = {}

AddEventHandler('modest:playerLoaded', function(source, user)
	players[source] = true
end)

RegisterServerEvent('RPD:addPlayer')
AddEventHandler('RPD:addPlayer', function()
	players[source] = true
end)

AddEventHandler('playerDropped',function(reason)
	players[source] = nil
end)

RegisterServerEvent('RPD:userDead')
AddEventHandler('RPD:userDead', function(userName, street)
	local s = source
	TriggerEvent('modest:getPlayerFromId', source, function(user)
		downedUser = user
		TriggerEvent("modest:getPlayers", function(pl)
			local meta = {}
			for k, v in pairs(pl) do
				TriggerEvent("modest:getCharacterFromId", k, function(character)
					if k ~= s then
						if character.job == "cop" or character.job == "sheriff" or character.job == "highwaypatrol" or character.job == "ems" or character.job == "fire" then
							TriggerClientEvent("chatMessage", k, "911", {255, 0, 0}, userName .. " has been incapacitated on " .. street .. ".")
						end
					end
				end)
			end
		end)
	end)
end)

RegisterServerEvent("RPD:removeWeapons")
AddEventHandler("RPD:removeWeapons", function()
	TriggerEvent("modest:getPlayerFromId", source, function(user)
		-- user.inventory = {}
		-- user.weapons = {}
	end)
end)

AddEventHandler('chatMessageLocation', function(from,name,message,location)
	if(message:sub(1,1) == "/") then

		local args = splitString(message, " ")
		local cmd = args[1]


		if (cmd == "/respawn") then
			CancelEvent()
			TriggerClientEvent('RPD:allowRespawn', from)
		end

		if (cmd == "/revive") then
			CancelEvent()
			TriggerEvent('modest:getPlayerFromId', from, function(user)
				if user then
					if args[2] == nil then
						size = 10
					else
						size = tonumber(args[2])

						if size > 25 then
							size = 25
						elseif size < 0 then
							size = 0
						end
					end

					local userJob = user.job
					if user.getGroup() == "mod" or
						user.getGroup() == "admin" or
						user.getGroup() == "superadmin" or
						user.getGroup() == "owner" then
						TriggerClientEvent('RPD:allowRevive', -1, from, user.getGroup(), size)
					else
						TriggerEvent("modest:getCharacterFromId", from, function(character)
							if character.job == "cop" or character.job == "ems" or character.job == "fire" then
								TriggerClientEvent('RPD:allowRevive', -1, from, user.getGroup(), size)
							end
						end)
					end
				end
			end)
		end
	end
end)

function splitString(inputstr, sep)
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
