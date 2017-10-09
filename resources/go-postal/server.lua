local activeJobs = {}

RegisterServerEvent("postal:giveMoney")
AddEventHandler("postal:giveMoney", function(amount)
	local userSource = source
	TriggerEvent('modest:getCharacterFromId', userSource, function(user)
		user.addCash(amount)
	end)
end)

RegisterServerEvent("postal:addJob")
AddEventHandler("postal:addJob", function(job)
	activeJobs[source] = job
end)

TriggerEvent('modest:addCommand', 'gopostal', function(source, args, user)
	if activeJobs[source] == nil then
		TriggerClientEvent('chatMessage', source, "Go Postal", {0, 255, 0}, "You're not currently working for Go Postal. Please return to one of our facilities to start your next job.")
	else
		TriggerClientEvent('chatMessage', source, "Go Postal", {0, 255, 0}, "You're current job has been placed on your map.")
		TriggerClientEvent('placeMarker', source, activeJobs[source].x, activeJobs[source].y)
	end
end)
