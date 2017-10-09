function toggleMenu(menuOpened)
	if menuOpened then
		SetNuiFocus(false)
		EnableControlAction(0, 1, true) -- LookLeftRight
		EnableControlAction(0, 2, true) -- LookUpDown
		EnableControlAction(0, 142, true) -- MeleeAttackAlternate
		EnableControlAction(0, 106, true) -- VehicleMouseControlOverride

		SendNUIMessage({
			type = "close"
		})
		menuOpened = false

		if GetVehiclePedIsIn(GetPlayerPed(-1), false) == 0 then
			ClearPedTasksImmediately(GetPlayerPed(-1))
		end
	else
		SetNuiFocus(true)
		DisableControlAction(0, 1, true) -- LookLeftRight
		DisableControlAction(0, 2, true) -- LookUpDown
		DisableControlAction(0, 142, true) -- MeleeAttackAlternate
		DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		SendNUIMessage({
			type = "list"
		})

		SendNUIMessage({ type = "add", name = "Voice", id = "voice" })
		SendNUIMessage({ type = "add", name = "Emotes", id = "emotes" })
		SendNUIMessage({ type = "add", name = "Inventory", id = "inventory" })
		SendNUIMessage({ type = "add", name = "Show ID", id = "id" })
		SendNUIMessage({ type = "add", name = "Phone", id = "phone" })

		if GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= 0 then
			SendNUIMessage({ type = "add", name = "Toogle Engine", id = "vehicle--engine" })
			SendNUIMessage({ type = "add", name = "Toogle Windows", id = "vehicle--windows" })
			SendNUIMessage({ type = "add", name = "Control Doors", id = "vehicle--doors" })
		else
			PlaceObjectOnGroundProperly(GetPlayerPed(-1))
			TaskStartScenarioInPlace(GetPlayerPed(-1), "PROP_HUMAN_STAND_IMPATIENT", 0, true)
		end

		menuOpened = true
	end
end

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
			SendNUIMessage({
				type = "click"
			})
		end

		if IsControlPressed(0, 288) then
			toggleMenu(false)
		end
	end
end)

RegisterNUICallback('close', function(data, cb)
	toggleMenu(true)
end)
