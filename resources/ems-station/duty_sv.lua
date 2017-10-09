RegisterServerEvent("ems:duty")
AddEventHandler("ems:duty", function(status)
	local s = source
	local job = "civ"
	if status then
		job = "ems"
	end
	TriggerEvent("modest:changeCharacterJobById", source, job, function(character)

	end)
end)

RegisterServerEvent("ems:clothes")
AddEventHandler("ems:clothes", function()
	local s = source
	TriggerEvent("modest:getCharacterFromId", s, function(character)
		TriggerClientEvent("ems:clothes", s, character)
	end)
end)

TriggerEvent('modest:addCommand', 'addems', function(source, args, user)
	local s = source
	local subject = tonumber(args[2])
	table.remove(args, 1)
	table.remove(args, 1)
	local rank = table.concat(args, " ")
	local rankID = Rank2ID(rank)

	if rankID == 0 then
		TriggerClientEvent("chatMessage", s, "", {}, rank.." does not appear to be a valid rank.")
		return
	end

	TriggerEvent("modest:getCharacterFromId", s, function(promoter)
		TriggerEvent("modest:getCharacterFromId", subject, function(emt)
			if promoter.is_ems >= 8 and promoter.is_ems > emt.is_ems and promoter.is_ems >= rankID then
				TriggerEvent("modest:changeCharacterById", subject, "is_ems", rankID, function(response)
					if response ~= nil then
						TriggerClientEvent("chatMessage", s, "", {}, "You promoted "..emt.first_name.." "..emt.last_name.." to ".. rank.."("..rankID..")")
						TriggerClientEvent("chatMessage", subject, "", {}, "You were promoted to ".. rank.."("..rankID..") by "..promoter.first_name.." "..promoter.last_name)
						TriggerClientEvent("ems:is_ems", subject, response.is_ems)
					end
				end)
			else
				TriggerClientEvent("chatMessage", s, "", {}, "You don't have enough power to touch "..emt.first_name.." "..emt.last_name.."'s rank.")
			end
		end)
	end)
end)
