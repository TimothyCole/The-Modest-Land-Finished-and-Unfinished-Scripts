local price, vehicleName, hash, plate
RegisterServerEvent("vs:checkVehicleMoney")
AddEventHandler("vs:checkVehicleMoney", function(params)
	local s = source
	TriggerEvent('modest:getCharacterFromId', s, function(user)
		local license = nil
		local licenses = user.licenses
		local vehicles = user.vehicles
		for i = 1, #licenses do
			if licenses[i].name == "Driver's License" then
				license = licenses[i]
			end
		end
		if license ~= nil then
			if license.points >= 12 then
				hash = params[1]
				price = params[2]
				vehicleName = params[3]
				if tonumber(price) <= user.cash then
					plate = tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9))
					TriggerClientEvent("vs:sold", s, hash, vehicleName, tostring(plate))
					user.removeCash(tonumber(price))
				else
					TriggerClientEvent("vs:notify", s, "You can't afford a vehicle of $"..price..". Come back you've got the money.")
				end
			else
				TriggerClientEvent("vs:notify", s, "Are you nuts?! I can't sell you a car with a suspended license!")
			end
		else
			TriggerClientEvent("vs:notify", s, "You don't have a drivers license, come back when you've learned how to drive.")
		end
	end)
end)

RegisterServerEvent("vs:setHandle")
AddEventHandler("vs:setHandle", function(vehicleHandle)
	TriggerEvent('modest:getCharacterFromId', source, function(user)
		local vehicles = user.vehicles
		if vehicles then
			local vehicle = {
				model = stringSplit(vehicleName, "(")[1],
				hash = hash,
				plate = plate,
				customization = {},
				stored = false,
				impounded = false
			}
			table.insert(vehicles, vehicle)
			user.setVehicles(vehicles)
		end
	end)
end)

function stringSplit(inputstr, sep)
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
