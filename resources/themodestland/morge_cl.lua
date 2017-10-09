RegisterNetEvent("GUI:Title")
AddEventHandler("GUI:Title", function(title)
	Menu.Title(title)
end)

RegisterNetEvent("GUI:Option")
AddEventHandler("GUI:Option", function(option, cb)
	cb(Menu.Option(option, true))
end)

RegisterNetEvent("GUI:Int")
AddEventHandler("GUI:Int", function(option, int, min, max, cb)
	Menu.Int(option, int, min, max, function(data)
		cb(data)
	end)
end)

RegisterNetEvent("GUI:Update")
AddEventHandler("GUI:Update", function()
	Menu.updateSelection()
end)

inMorge = false
pedModel = nil
morge_cam = nil
RegisterNetEvent("morge:personalize")
AddEventHandler("morge:personalize", function(character, skin)
	Citizen.CreateThread(function()
		morge_cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetEntityCoords(GetPlayerPed(-1), 397.3683, -1004.3312, -99.0040, 1, 0, 0, 1)
		SetCamCoord(morge_cam, 403.0473, -998.4642, -98.9540)
		SetCamRot(morge_cam, 0.0, 0.0, 360, true)
		RenderScriptCams(true, false, 0, 1, 0)

		DoScreenFadeOut(1000)
		local model = GetHashKey(skin)
		RequestModel(model)
		while not HasModelLoaded(model) do
			RequestModel(model)
			Citizen.Wait(0)
		end
		pedModel = CreatePed(4, model, 402.9461, -996.6815, -99.0, 180.0, false)
		PlaceObjectOnGroundProperly(pedModel)
		if pedModel then
			SetEntityCanBeDamaged(pedModel, false)
			SetPedCanRagdollFromPlayerImpact(pedModel, false)
			TaskSetBlockingOfNonTemporaryEvents(pedModel, true)
			SetPedFleeAttributes(pedModel, 0, 0)
			SetPedCombatAttributes(pedModel, 17, 1)
			SetEntityInvincible(pedModel)
		end
		DoScreenFadeIn(1000)

		inMorge = true
		local characterize = {}
		characterize[0] = 0
		characterize[2] = {}
		characterize[2][1] = 0
		characterize[2][2] = 0
		characterize[3] = 0
		characterize[11] = {}
		characterize[11][1] = 0
		characterize[11][2] = 0
		characterize[8] = 0
		characterize[4] = {}
		characterize[4][1] = 0
		characterize[4][2] = 0
		characterize[6] = 0

		SetPedComponentVariation(pedModel, 11, 0, 1, 0)
		SetPedComponentVariation(pedModel, 8, 0, 1, 0)

		SetPedHeadOverlay(pedModel, 1, 2, 1.0 / 20.0);
		Citizen.InvokeNative(0x497BF74A7B9CB952, pedModel, 2, 1, 2, 2);

		-- Cop
		-- SetPedComponentVariation(pedModel, 4, 25, 2, 2)--pants
		-- SetPedComponentVariation(pedModel, 6, 24, 0, 2)--shoes
		-- SetPedComponentVariation(pedModel, 8, 58, 0, 2)--shirt
		-- SetPedComponentVariation(pedModel, 11, 55, 0, 2)--torso

		while inMorge do
			TriggerEvent("GUI:Title", "Character Creator")

			TriggerEvent("GUI:Int", "Face", characterize[0], 0, 55, function(cb)
				characterize[0] = cb
				SetPedComponentVariation(pedModel, 0, characterize[0], 0, 2)
			end)

			TriggerEvent("GUI:Int", "Hair", characterize[2][1], 0, 36, function(cb)
				characterize[2][1] = cb
				SetPedComponentVariation(pedModel, 2, characterize[2][1], characterize[2][2], 2)
			end)

			TriggerEvent("GUI:Int", "Hair Color", characterize[2][2], 0, 63, function(cb)
				characterize[2][2] = cb
				SetPedComponentVariation(pedModel, 2, characterize[2][1], characterize[2][2], 2)
			end)

			TriggerEvent("GUI:Int", "Torso", characterize[3], 0, 162, function(cb)
				characterize[3] = cb
				SetPedComponentVariation(pedModel, 3, characterize[3], 0, 2)
			end)

			TriggerEvent("GUI:Int", "Shirt", characterize[11][1], 0, 240, function(cb)
				if cb == 55 and characterize[11][1] == 54 then
					cb = 56
				elseif cb == 55 and characterize[11][1] == 56 then
					cb = 54
				end
				characterize[11][1] = cb
				SetPedComponentVariation(pedModel, 11, characterize[11][1], characterize[11][2], 2)
			end)

			TriggerEvent("GUI:Int", "Shirt Color", characterize[11][2], 0, 240, function(cb)
				characterize[11][2] = cb
				SetPedComponentVariation(pedModel, 11, characterize[11][1], characterize[11][2], 2)
			end)

			TriggerEvent("GUI:Int", "Under Shirt", characterize[8], 0, 240, function(cb)
				characterize[8] = cb
				SetPedComponentVariation(pedModel, 8, characterize[8], 0, 2)
			end)

			TriggerEvent("GUI:Int", "Pants", characterize[4][1], 0, 88, function(cb)
				characterize[4][1] = cb
				SetPedComponentVariation(pedModel, 4, characterize[4][1], characterize[4][2], 0, 2)
			end)

			TriggerEvent("GUI:Int", "Pants Color", characterize[4][2], 0, 88, function(cb)
				characterize[4][2] = cb
				SetPedComponentVariation(pedModel, 4, characterize[4][1], characterize[4][2], 0, 2)
			end)

			TriggerEvent("GUI:Int", "Feet", characterize[6], 0, 88, function(cb)
				characterize[6] = cb
				SetPedComponentVariation(pedModel, 6, characterize[6], 0, 2)
			end)

			TriggerEvent("GUI:Option", "Save Character", function(cb)
				if cb then
					account.characteristics = characterize
					TriggerServerEvent("morge:characterize", account)
				else

				end
			end)

			TriggerEvent("GUI:Update")

			Wait(0)
		end
	end)
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)

		if inMorge then
			local ped = GetPlayerPed(-1)
			FreezeEntityPosition(ped, true)
			DisplayHud(false)
			DisplayRadar(false)
			SetEnableHandcuffs(ped, true)
			RemoveAllPedWeapons(ped, true)
			TriggerEvent("modest:setMoneyDisplay", "0")
			TriggerEvent("compass:display", false)

			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
				SendNUIMessage({
					type = "click"
				})
			end
		end
	end
end)

local pressed = false
local heading = 180.0
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if inMorge == true then
			DrawSpecialText("Press [ ~g~E~w~ ] to turn around")
			if IsControlPressed(0, 86) then
				if not pressed then
					if heading <= 180 then
						heading = 360.0
					else
						heading = 180.0
					end
					SetEntityHeading(pedModel, heading)
					DrawSpecialText("Press [ ~g~E~w~ ] to turn around")
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
end)

function DrawSpecialText(m_text)
	ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(250, 1)
end
