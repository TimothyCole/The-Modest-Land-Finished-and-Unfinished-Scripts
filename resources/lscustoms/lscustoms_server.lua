local tbl = {
[1] = {locked = false},
[2] = {locked = false},
[3] = {locked = false},
[4] = {locked = false},
[5] = {locked = false}
}
RegisterServerEvent('lockGarage')
AddEventHandler('lockGarage', function(b,garage)
	tbl[tonumber(garage)].locked = b
	TriggerClientEvent('lockGarage',-1,tbl)
	-- print(json.encode(tbl))
end)
RegisterServerEvent('getGarageInfo')
AddEventHandler('getGarageInfo', function()
	TriggerClientEvent('lockGarage',-1,tbl)
	-- print(json.encode(tbl))
end)

-- Add a command everyone is able to run. Args is a table with all the arguments, and the user is the user object, containing all the user data.
-- TriggerEvent('modest:addCommand', 'unlockgarage', function(source, args, user)
-- 	if tonumber(user.getPermissions()) > 0 then
-- 		TriggerClientEvent("lsCustoms:garageUnlock", -1) -- unlock everyone's ls customs
-- 		TriggerClientEvent("chatMessage", source, "", {0, 0, 0}, "^2LS Customs has been unlocked, my niqqa!")
-- 	else
-- 		print("non admin/mod tried to unlock ls customs...")
-- 	end
-- end)


RegisterServerEvent("lsc:checkBalance")
AddEventHandler("lsc:checkBalance", function()
	local s = source
	TriggerEvent('modest:getCharacterFromId', s, function(user)
		TriggerClientEvent("lsc:checkBalance", s, user.cash)
	end)
end)

RegisterServerEvent("lsc:payBalance")
AddEventHandler("lsc:payBalance", function(price)
	local s = source
	TriggerEvent('modest:getCharacterFromId', s, function(user)
		user.removeCash(tonumber(price))
	end)
end)

RegisterServerEvent("lsc:saveCustomized")
AddEventHandler("lsc:saveCustomized", function(customized, thisPlate)
	local s = source
	TriggerEvent('modest:getCharacterFromId', s, function(user)
		local vehicles = user.vehicles
		local rightCar = nil
		for k, v in pairs(vehicles) do
			if type(thisPlate) == "number" then
				-- TriggerClientEvent("chatMessage", -1, "LSC Debug", {32, 54, 120}, "Plate: "..thisPlate)
				if vehicles[k].plate - thisPlate == 0 then
					rightCar = k
				end
			end
		end
		if rightCar ~= nil then
			vehicles[rightCar].customization = customized
			user.setVehicles(vehicles)
		end
	end)
end)

RegisterServerEvent("lsc:loadCustomized")
AddEventHandler("lsc:loadCustomized", function(thisPlate)
	local s = source
	TriggerEvent('modest:getCharacterFromId', s, function(user)
		local vehicles = user.vehicles
		local rightCar = nil
		for k, v in pairs(vehicles) do
			if type(thisPlate) == "number" then
				if vehicles[k].plate - thisPlate == 0 then
					rightCar = v
				end
			end
		end
		if rightCar ~= nil then
			TriggerClientEvent("lsc:loadCustomized", s, rightCar.customization)
		end
	end)
end)
