local locations = {
	{ garage = { x=459.3, y=-1017.175, z=28.161, heading=0.5 }, spawn = { x=460.163, y=-1019.645, z=27.678, heading=91.862 } }, --Mission Row
	{ garage = { x=-1072.499, y=-851.5816, z=4.875, heading=0.4 }, spawn = { x=-1068.55261, y=-854.3819, z=4.867, heading=218.812 } }, -- Vespucci Canals
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
					DrawMarker(2, info.garage.x, info.garage.y, info.garage.z+1.10, 0.5, 0, 0, 0, 180.0, 0, 1.0, 0.1, 0.75, 66, 191, 112, 125, true, false, 0, 0)
					if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 5 then
						if menuOpen then
							garage = info
							Menu.Title("Police Department Garage")

							spawnCar("LSPD Cadet", "Ford Crown Victoria", "police7", 1)
							spawnCar("LSPD", "Ford Taurus", "police3", 1)
							spawnCar("LSPD", "Chevrolet Impala", "police", 2)
							spawnCar("LSPD", "Dodge Charger", "police2", 2)
							spawnCar("LSPD", "Ford Crown Victoria", "police4", 2)
							spawnCar("LSPD", "Police Motorcycle", "policeb", 3)
							spawnCar("LSPD SV", "Ford Crown Victoria", "sheriff", 7)
							spawnCar("Unmarked", "Dodge Charger", "fbi", 4)
							spawnCar("Unmarked", "Ford Expedition", "fbi2", 4)
							spawnCar("Swat", "Riot Truck", "riot", 7)
							spawnCar("Trooper", "Dodge Charger", "police2", 10)
							spawnCar("Trooper", "Chevrolet Tahoe", "police6", 10)
							spawnCar("Trooper", "Ford Explorer", "police5", 2)

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
					DrawMarker(2, info.garage.x, info.garage.y, info.garage.z+1.10, 0.5, 0, 0, 0, 180.0, 0, 1.0, 0.1, 0.75, 191, 66, 66, 125, true, false, 0, 0)
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
										SetNotificationMessage("CHAR_ANDREAS", "CHAR_ANDREAS", true, 1, "Police Department", "Garage", text);
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
	if is_cop >= rank then
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
			SetVehicleNumberPlateText(car, is_cop.." "..GetPlayerName(PlayerId()))

			if hash == "policeb" then
				SetPedPropIndex(GetPlayerPed(-1), 0, 52, 0, 2)
			else
				SetVehicleColours(car, 12, 12)
			end

			if department == "Trooper" then
				SetVehicleLivery(car, 2)
			end

			outCar = car

			Citizen.CreateThread(function()
				Wait(1)
				SetNotificationTextEntry("STRING");
				text = "Here's your vehicle return it in one peace for me."
				AddTextComponentString(text);
				SetNotificationMessage("CHAR_ANDREAS", "CHAR_ANDREAS", true, 1, "Police Department", "Garage", text);
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
