Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsSessionStarted() then
			-- Citizen.InvokeNative(0x170F541E1CADD1DE, false)
			-- Citizen.InvokeNative(0x0772DF77852C2E30, 1, 1)

			TriggerServerEvent('modest:firstJoinProper')
			TriggerEvent('modest:allowedToSpawn')
			return
		end
	end
end)

local loaded = false
local cashy = 0
local oldPos

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local pos = GetEntityCoords(GetPlayerPed(-1))

		if(oldPos ~= pos)then
			TriggerServerEvent('modest:updatePositions', pos.x, pos.y, pos.z)

			if(loaded)then
				SendNUIMessage({
					setmoney = true,
					money = cashy
				})

				loaded = false
			end
			oldPos = pos
		end
	end
end)

local myDecorators = {}

RegisterNetEvent("modest:setPlayerDecorator")
AddEventHandler("modest:setPlayerDecorator", function(key, value, doNow)
	myDecorators[key] = value
	DecorRegister(key, 3)

	if(doNow)then
		DecorSetInt(GetPlayerPed(-1), key, value)
	end
end)

local firstSpawn = true
AddEventHandler("playerSpawned", function()
	for k,v in pairs(myDecorators)do
		DecorSetInt(GetPlayerPed(-1), k, v)
	end

	if firstSpawn then
		firstSpawn = false
	end
end)

RegisterNetEvent('modest:setMoneyIcon')
AddEventHandler('modest:setMoneyIcon', function(i)
	SendNUIMessage({
		seticon = true,
		icon = i
	})
end)

RegisterNetEvent('modest:activateMoney')
AddEventHandler('modest:activateMoney', function(e)
	SendNUIMessage({
		setmoney = true,
		money = e
	})
end)

RegisterNetEvent("modest:addedMoney")
AddEventHandler("modest:addedMoney", function(m, native)
	SendNUIMessage({
		addcash = true,
		money = m
	})
end)

RegisterNetEvent("modest:removedMoney")
AddEventHandler("modest:removedMoney", function(m, native, current)
	SendNUIMessage({
		removecash = true,
		money = m
	})
end)

RegisterNetEvent("modest:setMoneyDisplay")
AddEventHandler("modest:setMoneyDisplay", function(val)
	SendNUIMessage({
		setDisplay = true,
		display = val
	})
end)

RegisterNetEvent("modest:enablePvp")
AddEventHandler("modest:enablePvp", function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			for i = 0,32 do
				if NetworkIsPlayerConnected(i) then
					if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
						SetCanAttackFriendly(GetPlayerPed(i), true, true)
						NetworkSetFriendlyFireOption(true)
					end
				end
			end
		end
	end)
end)
