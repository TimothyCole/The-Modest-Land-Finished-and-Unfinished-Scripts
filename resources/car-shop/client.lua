local locations = {
    {
        garage = { x=-35.001, y=-1101.657, z=26.422 },
        spawn = { x=-31.086, y=-1089.593, z=26.422, heading=332.747 },
        preview = { x=-45.323, y=-1097.545, z=26.422, heading=148.275 },
    },
    {
        garage = { x=1224.850, y=2727.356, z=38.004 },
        spawn = { x=1230.095, y=2717.908, z=37.502, heading=131.941 },
        preview = { x=1218.155, y=2717.167, z=37.501, heading=204.264 },
    },
}

local pressed = false
local menuOpen = false
local garage = {}
local menu = nil
local demo = { car = nil, hash = nil }
Citizen.CreateThread(function()
	while true do
		Wait(1)
		for _, info in pairs(locations) do
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 50 then
				DrawMarker(1, info.garage.x, info.garage.y, info.garage.z-1.0, 0.5, 0, 0, 0, 0.0, 0, 3.0, 3.0, 0.75, 102, 66, 191, 125, false, false, 0, 0)
				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 2 then
					if menuOpen then
						garage = info

						if menu == nil then
							Menu.Title("Pitt's Cars")

							spawnMenu("Bicycles")
							spawnMenu("Compacts")
							spawnMenu("Coupes")
							spawnMenu("Sedans")
							spawnMenu("Muscle")
							spawnMenu("Offroads")
							spawnMenu("SUV")
							spawnMenu("Trucks")
							spawnMenu("Vans")
							spawnMenu("Sports Cars")
							spawnMenu("Classic Cars")
							spawnMenu("Super Cars")
							spawnMenu("Motorcycles")

							Menu.updateSelection()
						else
							if type(vehicles[menu]) == "table" then
								Menu.Title("Pitt's Cars - "..menu)

								for _, v in pairs(vehicles[menu]) do
									spawnCar(v.name, v.hash, v.cost)
								end
								spawnMenu("Back to categories")

								Menu.updateSelection()

								if IsControlPressed(0, 177) then
									menu = nil
									if demo.car ~= nil then
										Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(demo.car, false))
									end
								end
							end
						end

						DrawSpecialText("Press [ ~g~E~w~ ] to stop looking at the cars.")

				        if IsControlPressed(0, 86) then
				            if not pressed then
								menuOpen = false
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
					else
						DrawSpecialText("Press [ ~g~E~w~ ] to look at the selection of cars.")

				        if IsControlPressed(0, 86) then
				            if not pressed then
								menuOpen = true
								menu = nil
								currentOption = 1
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
					end
				elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.preview.x, info.preview.y, info.preview.z, true) >= 25 then
					if demo.car ~= nil then
						Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(demo.car, false))
						menu = nil
						currentOption = 1
					end
				end
			end
		end
	end
end)

function spawnMenu(option)
	if Menu.Option(option, true) then
		if option == "Back to categories" then
			menu = nil
		else
			menu = option
		end
		if demo.car ~= nil then
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(demo.car, false))
		end
		currentOption = 1
	end
end

function spawnCar(option, hash, price)
	if Menu.OptionData(option, tostring(price)) then
		menuOpen = false
		TriggerServerEvent("vs:checkVehicleMoney", { hash, price, option })
	end

	if vehicles[menu][currentOption] ~= nil and demo.hash ~= vehicles[menu][currentOption].hash then
		Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(demo.car, false))

		demo.hash = vehicles[menu][currentOption].hash
		RequestModel(demo.hash)
		while not HasModelLoaded(demo.hash) do
			RequestModel(demo.hash)
			Wait(0)
		end
		demo.car = CreateVehicle(demo.hash, garage.preview.x, garage.preview.y, garage.preview.z, garage.preview.heading, false, false)
		SetVehicleOnGroundProperly(demo.car)
		SetVehicleEngineOn(demo.car, false)
		FreezeEntityPosition(demo.car, true)
	end
end

RegisterNetEvent("vs:sold")
AddEventHandler("vs:sold", function(hash, name, plate)
	Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(demo.car, false))

	RequestModel(hash)
	while not HasModelLoaded(hash) do
		RequestModel(hash)
		Citizen.Wait(0)
	end

	local car = CreateVehicle(hash, garage.spawn.x, garage.spawn.y, garage.spawn.z, garage.spawn.heading, true, false)
	SetVehicleOnGroundProperly(car)
	SetVehRadioStation(car, "OFF")
	SetPedIntoVehicle(GetPlayerPed(-1), car, -1)
	SetVehicleEngineOn(car, true, false, false)
	SetEntityAsMissionEntity(car, true, true)
	SetVehicleNumberPlateText(car, plate)

	TriggerServerEvent("vs:setHandle", car)
	TriggerEvent("vs:notify", "Here's your ride, Thank you for your purchase.")
end)

RegisterNetEvent("vs:notify")
AddEventHandler("vs:notify", function(msg)
	Citizen.CreateThread(function()
		Wait(1)
		SetNotificationTextEntry("STRING");
		AddTextComponentString(msg);
		SetNotificationMessage("CHAR_CARSITE", "CHAR_CARSITE", true, 1, "Pitt's Cars", "", msg);
		DrawNotification(false, true);
	end)
end)

function DrawSpecialText(m_text)
    ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(250, 1)
end
