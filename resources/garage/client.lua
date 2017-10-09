local locations = {
	{ ['x'] = 1725.511, ['y'] = 4802.073, ['z'] = 41.629 },
	{ ['x'] = -31.911, ['y'] = 6414.208, ['z'] = 31.462 },
	{ ['x'] = 1879.495, ['y'] = 3758.417, ['z'] = 32.839 },
	{ ['x'] = -308.131, ['y'] = -758.039, ['z'] = 33.85 },
	{ ['x'] = 247.025, ['y'] = -748.579, ['z'] = 30.817 },
}

Citizen.CreateThread(function()
	for _, info in pairs(locations) do
		info.blip = AddBlipForCoord(info['x'], info['y'], info['z'])
		SetBlipSprite(info.blip, 357)
		SetBlipDisplay(info.blip, 4)
		SetBlipScale(info.blip, 0.9)
		SetBlipColour(info.blip, 4)
		SetBlipAsShortRange(info.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Garage")
		EndTextCommandSetBlipName(info.blip)
	end
end)

local allowed = true
local plate = nil
local pv = nil
local stored
local menuOpen = false
local vehicles = nil
local insurance = nil
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for _, info in pairs(locations) do
			if GetDistanceBetweenCoords(info['x'], info['y'], info['z'],GetEntityCoords(GetPlayerPed(-1))) < 75 then
				DrawMarker(1, info['x'], info['y'], info['z']-1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 0.25, 215, 70, 70, 150, 0, 0, 0, 0)
				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info['x'], info['y'], info['z'], true) < 4 then
					DrawSpecialText("Press [ ~g~E~w~ ] to access the garage!")
					if IsControlPressed(0, 86) then
						if not pressed then
							if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
								local handle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
								local numberPlateText = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
								TriggerServerEvent("garage:storeVehicle", handle, numberPlateText)
							else
								if not menuOpen then
									TriggerServerEvent("garage:checkVehicles")
									menuOpen = true
								else
									menuOpen = false
									vehicles = nil
									insurance = nil
								end
							end
						end

						pressed = true
						while pressed do
							Wait(0)
							if (IsControlPressed(0, 86) == false) then
								pressed = false
								break
							end
						end
					end
				elseif menuOpen then
					menuOpen = false
					vehicles = nil
					insurance = nil
				end
			end
		end
	end
end)

RegisterNetEvent("garage:checkVehicles")
AddEventHandler("garage:checkVehicles", function(data)
	TriggerServerEvent("garage:checkBalance")
	vehicles = data.vehicles
	insurance = data.insurance

	if vehicles == nil then
		-- NO CARS!
	end
end)

local checkBalance = nil
RegisterNetEvent("garage:checkBalance")
AddEventHandler("garage:checkBalance", function(bal)
	checkBalance = bal
end)

local impoundFee = 2000
function spawnCar(option, status, vehicle)
	if Menu.OptionData(option, status) then
		menuOpen = false

		if status == "~r~Impounded" then
			if impoundFee <= checkBalance then
				TriggerServerEvent("garage:payBalance", impoundFee)
				checkBalance = checkBalance - impoundFee
				TriggerEvent("garage:spawn", vehicles[vehicle])
				vehicles[vehicle].stored = false
				vehicles[vehicle].impounded = false
				TriggerServerEvent("garage:spawn", vehicles)
			else
				TriggerEvent("garage:notify", "This car was impounded. You need to pay the state ~r~$"..impoundFee.." ~w~before you can get this back.")
			end
		elseif status == "~g~       Stored" then
			TriggerEvent("garage:spawn", vehicles[vehicle])
			vehicles[vehicle].stored = false
			vehicles[vehicle].impounded = false
			TriggerServerEvent("garage:spawn", vehicles)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Wait(1)

		if vehicles ~= nil and menuOpen and checkBalance ~= nil then
			Menu.Title("Garage")

			for k, v in pairs(vehicles) do
				if v.impounded then
					status = "~r~Impounded"
					spawnCar(v.model, status, k)
				elseif v.stored then
					status = "~g~       Stored"
					spawnCar(v.model, status, k)
				elseif not v.stored and insurance then
					status = "~y~      Missing"
				end
			end

			Menu.updateSelection()
		end
	end
end)

RegisterNetEvent("garage:storeVehicle")
AddEventHandler("garage:storeVehicle", function()
	TriggerEvent("garage:notify", "~g~We'll keep this fine thing safe for you.")
	SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), true, true)
	Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(GetVehiclePedIsIn(GetPlayerPed(-1), false)))
end)

RegisterNetEvent("garage:spawn")
AddEventHandler("garage:spawn", function(veh)
	local modelHash = veh.hash
	local plateText = veh.plate
	local numberHash = modelHash

	if type(modelHash) ~= "number" then
		numberHash = tonumber(modelHash)
	end

	Citizen.CreateThread(function()
		RequestModel(numberHash)

		while not HasModelLoaded(numberHash) do
			RequestModel(numberHash)
			Citizen.Wait(0)
		end

		local playerPed = GetPlayerPed(-1)
		local playerCoords = GetEntityCoords(playerPed, false)
		local heading = GetEntityHeading(playerPed)
		local vehicle = CreateVehicle(numberHash, playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(playerPed), true, false)

		if veh.customization.mods ~= nil then
			SetVehicleModKit(vehicle, 0)
			for i=0, 24 do
				if veh.customization.mods[tostring(i)] ~= nil then
					SetVehicleMod(vehicle, i, veh.customization.mods[tostring(i)].mod, true)
				end
			end
			SetVehicleWindowTint(vehicle, veh.customization.windowtint)
			SetVehicleNumberPlateTextIndex(vehicle, veh.customization.plateindex)
			SetVehicleWheelType(vehicle, veh.customization.wheeltype)
			SetVehicleColours(vehicle, veh.customization.vehiclecol[1], veh.customization.vehiclecol[1])
			SetVehicleExtraColours(vehicle, veh.customization.vehiclecol[2], veh.customization.extracol[2])
			SetVehicleNeonLightsColour(vehicle, veh.customization.neoncolor[1], veh.customization.neoncolor[2], veh.customization.neoncolor[3])
		end

		SetVehicleNumberPlateText(vehicle, plateText)
		SetVehicleOnGroundProperly(vehicle)
		SetVehRadioStation(vehicle, "OFF")
		SetPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
		SetVehicleEngineOn(vehicle, true, false, false)
		SetEntityAsMissionEntity(vehicle, true, true)
	end)
end)

RegisterNetEvent("garage:notify")
AddEventHandler("garage:notify", function(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end)

function DrawSpecialText(m_text)
	ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(250, 1)
end
