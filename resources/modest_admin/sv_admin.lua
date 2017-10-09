TriggerEvent("modest:addGroup", "owner", "superadmin", function(group) end)
TriggerEvent("modest:addGroup", "mod", "user", function(group) end)

TriggerEvent('modest:addCommand', 'rank', function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Rank: ^*^2 " .. user.getGroup())
end)

TriggerEvent('modest:addGroupCommand', 'noclip', "admin", function(source, args, user)
	TriggerClientEvent("modest_admin:noclip", source)
end, function(source, args, user)
	-- TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Kicking
TriggerEvent('modest:addGroupCommand', 'kick', "mod", function(source, args, user)
	if(GetPlayerName(tonumber(args[2])))then
		local player = tonumber(args[2])

		-- User permission check
		TriggerEvent("modest:getPlayerFromId", player, function(target)

			local reason = args
			table.remove(reason, 1)
			table.remove(reason, 1)
			if #reason == 0 then
				reason = "Kicked: You have been kicked from the server. Probably for FailRP/RDM/VDM/Mic Spam/No Mic"
			else
				reason = "Kicked: " .. table.concat(reason, " ")
			end

			local production = GetConvarInt('production', 0)
			if production > 0 then
				local url = 'https://discordapp.com/api/webhooks/340071278042021888/Vrb4L49TCn8NtEUTD5iCzja421doBlVZcIVHWJRMMNevHxhwqpW9DFlfa3oXDr4w_7gy'
				PerformHttpRequest(url, function(err, text, headers)
					if text then
						print(text)
					end
				end, "POST", json.encode({
					embeds = {
						{
							description = "**Display Name:** " ..GetPlayerName(player).. " \n**Identifier:** " ..GetPlayerIdentifiers(player)[1].. " \n**Reason:** " ..reason:gsub("Kicked: ", "").. " \n**Kicked By:** "..GetPlayerName(source),
							color = 16777062,
							author = {
								name = "User Kicked From The Server"
							}
						}
					}
				}), { ["Content-Type"] = 'application/json' })
			end

			TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, GetPlayerName(player) .. " has been ^3kicked^0 (" .. reason .. ")")
			DropPlayer(player, reason)
		end)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

TriggerEvent('modest:addGroupCommand', 'ban', "admin", function(source, args, user)
	local userSource = source
	TriggerEvent('modest:exposeDBFunctions', function(GetDoc)
		local banner = GetPlayerName(userSource)
		local bannerId = GetPlayerIdentifiers(userSource)[1]
		local targetPlayer = tonumber(args[2])
		table.remove(args, 1)
		table.remove(args, 1)
		local reason = table.concat(args, " ")
		idents = GetPlayerIdentifiers(targetPlayer)
		local id = idents[1]
		DropPlayer(targetPlayer, "Banned: " .. reason)
	    TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, GetPlayerName(targetPlayer) .. " has been ^2banned^0 (" .. reason .. ")")
		GetDoc.createDocument("bans",  {identifier = id, banned = true, reason = reason, bannerName = banner, bannerId = bannerId, timestamp = os.date("%x", os.time())}, function() end)
	end)
end, function(source,args,user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

function stringsplit(self, delimiter)
  local a = self:Split(delimiter)
  local t = {}

  for i = 0, #a - 1 do
     table.insert(t, a[i])
  end

  return t
end

-- Freezing
local frozen = {}
TriggerEvent('modest:addGroupCommand', 'freeze', "mod", function(source, args, user)
	if(GetPlayerName(tonumber(args[2])))then
		local player = tonumber(args[2])

		-- User permission check
		TriggerEvent("modest:getPlayerFromId", player, function(target)

			if(frozen[player])then
				frozen[player] = false
			else
				frozen[player] = true
			end

			TriggerClientEvent('modest_admin:freezePlayer', player, frozen[player])

			local state = "unfrozen"
			if(frozen[player])then
				state = "frozen"
			end

			TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been " .. state .. " by ^2" .. GetPlayerName(source))
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been " .. state)
			TriggerEvent('modest:getPlayers', function(players)
				-- notify all admins/mods
				for id, adminOrMod in pairs(players) do
					local adminOrModGroup = adminOrMod.getGroup()
					if adminOrModGroup == "mod" or adminOrModGroup == "admin" or adminOrModGroup == "superadmin" or adminOrModGroup == "owner" then
						TriggerClientEvent('chatMessage', id, "", {0, 0, 0}, "Player ^2" .. GetPlayerName(source) .. "^0 froze " .. GetPlayerName(player))
					end
				end
			end)
		end)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

TriggerEvent('modest:addGroupCommand', 'tp', "owner", function(source, args, user)
	if GetPlayerName(tonumber(args[2])) then
		local player = tonumber(args[2])

		TriggerEvent("modest:getPlayerFromId", player, function(target)
			if target then
				TriggerClientEvent('modest_admin:teleportUser', source, target.getCoords().x, target.getCoords().y, target.getCoords().z)
			end
		end)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	-- TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- -- Kill yourself
-- TriggerEvent('modest:addCommand', 'die', function(source, args, user)
-- 	TriggerClientEvent('modest_admin:kill', source)
-- 	TriggerClientEvent('chatMessage', source, "", {0,0,0}, "^1^*You killed yourself.")
-- end)

-- Killing
TriggerEvent('modest:addGroupCommand', 'slay', "owner", function(source, args, user)
	if(GetPlayerName(tonumber(args[2])))then
		local player = tonumber(args[2])

		TriggerEvent("modest:getPlayerFromId", player, function(target)
			TriggerClientEvent('modest_admin:kill', player)

			TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been killed by ^2" .. GetPlayerName(source))
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been killed.")
		end)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Rcon commands
AddEventHandler('rconCommand', function(commandName, args)
	if commandName == 'setrank' then
		if #args ~= 2 then
			RconPrint("Usage: setrank {id} {rank}\n")
			CancelEvent()
			return
		end

		if GetPlayerName(tonumber(args[1])) == nil then
			RconPrint("Player not ingame\n")
			CancelEvent()
			return
		end

		TriggerEvent("modest:getAllGroups", function(groups)
			if(groups[args[2]])then
				TriggerEvent("modest:setPlayerData", tonumber(args[1]), "group", args[2], function(response, success)
					RconPrint(response)

					if(true)then
						print(args[1] .. " " .. args[2])
						TriggerClientEvent('modest:setPlayerDecorator', tonumber(args[1]), 'group', tonumber(args[2]), true)
						TriggerClientEvent('chatMessage', -1, "Government", {191, 50, 50}, "^4^*" .. GetPlayerName(tonumber(args[1])) .. "^r^0 was made an ^4^*" .. args[2])
					end
				end)
			else
				RconPrint("This rank does not exist.\n")
			end
		end)

		CancelEvent()
	end
end)

-- Logging
AddEventHandler("modest:adminCommandRan", function(source, command, group)
	local S = source
	TriggerEvent("modest:getCharacterFromId", source, function(character)
		local Command = command[1]
		if Command ~= "kick" or Command ~= "ban" then
			table.remove(command, 1)
			local Args = command

			if #Args > 0 then
				Command = Command .. " \n**Args:** " .. table.concat(Args, " ")
			end

			local production = GetConvarInt('production', 0)
			if production > 0 then
				local url = 'https://discordapp.com/api/webhooks/340071278042021888/Vrb4L49TCn8NtEUTD5iCzja421doBlVZcIVHWJRMMNevHxhwqpW9DFlfa3oXDr4w_7gy'
				PerformHttpRequest(url, function(err, text, headers)
					if text then
						print(text)
					end
				end, "POST", json.encode({
					embeds = {
						{
							description = "**Character Name:** " ..character.first_name .. " ".. character.last_name.." \n**Identifier:** " ..GetPlayerIdentifiers(S)[1].." \n**Command:** " ..Command,
							color = 3181517,
							author = {
								name = "User Ran Admin Command"
							}
						}
					}
				}), { ["Content-Type"] = 'application/json' })
			end
		end
	end)
end)
