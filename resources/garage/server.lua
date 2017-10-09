RegisterServerEvent("garage:storeVehicle")
AddEventHandler("garage:storeVehicle", function(handle, numberPlateText)
	local userSource = source
	TriggerEvent('modest:getPlayerFromId', userSource, function(user)
		local vehicles = user.getVehicles()
		for i = 1, #vehicles do
			local vehicle = vehicles[i]
			local vehiclePlate = vehicle.plate
			if string.match(numberPlateText,vehiclePlate) ~= nil then -- player actually owns the car that player is attempting to store
				vehicles[i].stored = true
				user.setVehicles(vehicles)
				TriggerClientEvent("garage:storeVehicle", source)
				return
			end
		end
		-- after checking all owned vehicles, player doesn't appear to own that car
		TriggerClientEvent("garage:notify", source, "~r~You do not own that vehicle!")
	end)
end)

function playerHasValidAutoInsurance(playerInsurance)
	local timestamp = os.date("*t", os.time())
	if playerInsurance.type == "auto" then
		if timestamp.year <= playerInsurance.expireYear then
			if timestamp.month < playerInsurance.expireMonth then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

RegisterServerEvent("garage:checkVehicles")
AddEventHandler("garage:checkVehicles", function()
	local s = source
	TriggerEvent('modest:getPlayerFromId', s, function(user)
		local vehicles = user.getVehicles()
		local playerInsurance = user.getInsurance()
		TriggerClientEvent("garage:checkVehicles", s, { vehicles = vehicles, insurance = playerHasValidAutoInsurance(playerInsurance) })
	end)
end)

RegisterServerEvent("garage:spawn")
AddEventHandler("garage:spawn", function(vehicles)
	local s = source
	TriggerEvent('modest:getPlayerFromId', s, function(user)
		user.setVehicles(vehicles)
	end)
end)

RegisterServerEvent("garage:checkBalance")
AddEventHandler("garage:checkBalance", function()
	local s = source
	TriggerEvent('modest:getPlayerFromId', s, function(user)
		TriggerClientEvent("garage:checkBalance", s, user.getMoney())
	end)
end)

RegisterServerEvent("garage:payBalance")
AddEventHandler("garage:payBalance", function(price)
	local s = source
	TriggerEvent('modest:getPlayerFromId', s, function(user)
		user.removeMoney(tonumber(price))
	end)
end)
