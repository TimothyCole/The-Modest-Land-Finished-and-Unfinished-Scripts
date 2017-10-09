local locations = {
	{ garage = { x=328.137, y=-560.559, z=28.743 }, spawn = { x=329.917, y=-555.927, z=28.743, heading=338.901 } },
}

local pressed = false
local menuOpen = false
local outCar = nil
local garage = {}
Citizen.CreateThread(function()
	while true do
		Wait(1)
		for _, info in pairs(locations) do
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 50 and duty then
				if outCar == nil then
					DrawMarker(2, info.garage.x, info.garage.y, info.garage.z+1.10, 0.5, 1.4, 0, 0, 180.0, 0, 1.0, 0.1, 0.75, 66, 191, 112, 125, true, false, 0, 0)
					if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 5 then
						if menuOpen then
							garage = info
							Menu.Title("Hospital Garage")

							spawnCar("", "Ambulance", "ambulance", 1)
							spawnCar("", "Rapid Response", "sheriff2", 7)

							Menu.updateSelection()

							DrawSpecialText("Press [ ~g~E~w~ ] to close the garage.")

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
							DrawSpecialText("Press [ ~g~E~w~ ] to open the garage.")

							if IsControlPressed(0, 86) then
								if not pressed then
									menuOpen = true
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
					end
				else
					DrawMarker(2, info.garage.x, info.garage.y, info.garage.z+1.10, 0.5, 1.4, 0, 0, 180.0, 0, 1.0, 0.1, 0.75, 191, 66, 66, 125, true, false, 0, 0)
					if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 5 then
						if IsPedInAnyVehicle(GetPlayerPed(-1), true) ~= false and GetVehiclePedIsIn(GetPlayerPed(-1), false) == outCar then
							DrawSpecialText("Press [ ~r~Backspace~w~ ] to return your vehicle.")

							if IsControlPressed(0, 177) then
								if not pressed then
									SetEntityAsMissionEntity(outCar, true, true)
									Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(outCar))
									outCar = nil
									SetPedPropIndex(GetPlayerPed(-1), 0, 11, 0, 2)
								end

								pressed = true
								while pressed do
									Wait(0)
									if (IsControlPressed(0, 177) == false) then
										pressed = false
										break
									end
								end
							end
						else
							DrawSpecialText("Press [ ~g~E~w~ ] to get a new vehicle.")

							if IsControlPressed(0, 86) then
								if not pressed then
									outCar = nil
									menuOpen = true

									Citizen.CreateThread(function()
										Wait(1)
										SetNotificationTextEntry("STRING");
										text = "That car's coming out of your pay!"
										AddTextComponentString(text);
										SetNotificationMessage("CHAR_ANDREAS", "CHAR_ANDREAS", true, 1, "Hospital", "Garage", text);
										DrawNotification(false, true);

										-- TODO: Remove money from player!
										-- Dick lost our car!
									end)
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
					end
				end
			end
		end
	end
end)

function spawnCar(department, option, hash, rank)
	if is_ems >= rank then
		if Menu.OptionData(option, department) then
			menuOpen = false

			vehicle = GetHashKey(hash)
			RequestModel(vehicle)

			while not HasModelLoaded(vehicle) do
				RequestModel(vehicle)
				Citizen.Wait(0)
			end

			local car = CreateVehicle(vehicle, garage.spawn.x, garage.spawn.y, garage.spawn.z, garage.spawn.heading, true, false)
			SetVehicleOnGroundProperly(car)
			SetVehRadioStation(car, "OFF")
			SetPedIntoVehicle(GetPlayerPed(-1), car, -1)
			SetVehicleEngineOn(car, true, false, false)
			SetEntityAsMissionEntity(car, true, true)
			SetVehicleNumberPlateText(car, is_ems .. "-" .. GetPlayerServerId(PlayerId()))
			SetVehicleExtra(car, 1, true)
			SetVehicleExtra(car, 2, false)
			SetVehicleExtra(car, 3, true)
			SetVehicleExtra(car, 7, false)
			SetVehicleExtra(car, 11, true)
			SetVehicleExtra(car, 12, true)

			outCar = car

			Citizen.CreateThread(function()
				Wait(1)
				SetNotificationTextEntry("STRING");
				text = "Here's your vehicle return it in one peace for me."
				AddTextComponentString(text);
				SetNotificationMessage("CHAR_ANDREAS", "CHAR_ANDREAS", true, 1, "Hospital", "Garage", text);
				DrawNotification(false, true);
			end)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		DisablePlayerVehicleRewards(PlayerId())
	end
end)
