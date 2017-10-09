RegisterServerEvent("hide:blip")
AddEventHandler("hide:blip", function(user, toggle)
	TriggerClientEvent("hide:blip", -1, source, toggle)
end)
