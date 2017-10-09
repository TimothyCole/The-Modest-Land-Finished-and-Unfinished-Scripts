local locations = {
	{ garage = { x=460.514, y=-984.042, z=43.691 }, spawn = { x=449.265, y=-981.309, z=43.691, heading=22.709 } },
}

local pressed = false
local outHeli = nil
local garage = {}
Citizen.CreateThread(function()
	while true do
		Wait(1)
	    for _, info in pairs(locations) do
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 50 and duty and is_cop >= 6 then
				if outHeli == nil then
					if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 5 then
						DrawSpecialText("Press [ ~b~Enter~w~ ] to spawn a police chopper.")

				        if IsControlPressed(0, 176) then
				            if not pressed then
								garage = info
								SpawnHeli()

								SetPedPropIndex(GetPlayerPed(-1), 0, 19, 0, 2)
							end

							pressed = true
			                while pressed do
			                    Wait(0)
			                    if (IsControlPressed(0, 176) == false) then
			                        pressed = false
			                        break
			                    end
			                end
						end
					end
				elseif outHeli and not IsPedInAnyVehicle(GetPlayerPed(-1), true) then
					if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.garage.x, info.garage.y, info.garage.z, true) < 5 then
						DrawSpecialText("Press [ ~r~Backspace~w~ ] to return the chopper.")

						SetVehicleFixed(GetVehiclePedIsUsing(GetPlayerPed(-1)))
						SetVehicleDirtLevel(GetVehiclePedIsUsing(GetPlayerPed(-1)),  0.0000000001)
						SetVehicleDeformationFixed(GetVehiclePedIsUsing(GetPlayerPed(-1)))
						SetVehicleUndriveable(GetVehiclePedIsUsing(GetPlayerPed(-1)), false)
						SetVehicleEngineOn(GetVehiclePedIsUsing(GetPlayerPed(-1)), true, false, false)

				        if IsControlPressed(0, 177) then
				            if not pressed then
				                SetEntityAsMissionEntity(outHeli, true, true)
								Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(outHeli))
								outHeli = nil
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
					end
				end
			end
		end
	end
end)

function SpawnHeli()
	vehicle = GetHashKey("polmav")
	RequestModel(vehicle)

	while not HasModelLoaded(vehicle) do
		RequestModel(vehicle)
		Citizen.Wait(0)
	end

	local car = CreateVehicle(vehicle, garage.spawn.x, garage.spawn.y, garage.spawn.z, garage.spawn.heading, true, false)
	SetVehicleOnGroundProperly(car)
	SetVehRadioStation(car, "OFF")
	SetEntityAsMissionEntity(car, true, true)
	SetVehicleNumberPlateText(car, GetPlayerName(PlayerId()))
	SetVehicleLivery(car, 2)

	outHeli = car
end
