RegisterServerEvent("pd:duty")
AddEventHandler("pd:duty", function(status)
	local s = source
	local job = "civ"
	if status then
		job = "cop"
	end
	TriggerEvent("modest:changeCharacterJobById", source, job, function(character)
		-- TriggerClientEvent("chatMessage", s, "", {}, "Job: "..character.job)
	end)
end)

RegisterServerEvent("pd:clothes")
AddEventHandler("pd:clothes", function()
	local s = source
	TriggerEvent("modest:getCharacterFromId", s, function(character)
		TriggerClientEvent("pd:clothes", s, character)
	end)
end)
