account = nil
local accountCheck = false
local reverted = false
local voip = false
local hud = true
local skyCamHeight = 300.0
local skyCamera = { x=-682.0722, y=-266.1353, headings={ min=10, max=350 } }
local camera = nil
local old_camera = nil
local skyCam = nil

Citizen.CreateThread(function()
	while true do
		Wait(0)

		if not account and not accountCheck then
			TriggerServerEvent("character:getList")
			accountCheck = true
		elseif not account then
			if hud then
				local ped = GetPlayerPed(-1)
				SetEntityCoords(ped, 549.738, -2208.249, 68.981, 0.0, 0, 0, 1)
				FreezeEntityPosition(ped, true)
				DisplayHud(false)
				DisplayRadar(false)
				SetEnableHandcuffs(ped, true)
				RemoveAllPedWeapons(ped, true)
				TriggerEvent("modest:setMoneyDisplay", "0")
				TriggerEvent("compass:display", false)
				hud = false
				skyCam = skyCamera
				skyCam.heading = tostring(math.random()*math.random(skyCam.headings.min, skyCam.headings.max))
			end

			if type(skyCam.heading) == "string" and camera == nil then
				camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
				SetCamCoord(camera, skyCam.x, skyCam.y, skyCamHeight)
				SetCamRot(camera, 0.0, 0.0, skyCam.heading, true)
				RenderScriptCams(true, false, 0, 1, 0)
			end

			SetNuiFocus(true)
			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
				SendNUIMessage({
					type = "click"
				})
			end

			if not voip then
				TriggerEvent("voip", "off")
				voip = true
			end
		elseif not reverted then
			TriggerEvent("voip", "default")
			SendNUIMessage({
				type = "close"
			})

			SetNuiFocus(false)
			EnableControlAction(0, 1, true) -- LookLeftRight
			EnableControlAction(0, 2, true) -- LookUpDown
			EnableControlAction(0, 142, true) -- MeleeAttackAlternate
			EnableControlAction(0, 106, true) -- VehicleMouseControlOverride

			FreezeEntityPosition(GetPlayerPed(-1), false)
			DisplayHud(true)
			DisplayRadar(true)
			SetEnableHandcuffs(GetPlayerPed(-1), false)
			TriggerEvent("modest:setMoneyDisplay", "1.0")
			TriggerEvent("compass:display", true)

			local skin = "mp_" .. string.sub(account.gender, 1, 1) .. "_freemode_01"

			local model = GetHashKey(skin)
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Citizen.Wait(0)
			end
			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)
			SetPedComponentVariation(GetPlayerPed(-1), 0, 0, 0, 2)

			if json.encode(account.characteristics) == "[]" then
				RenderScriptCams(false, false, camera, 1, 0)
				DestroyCam(camera, false)
				TriggerEvent("morge:personalize", account, skin)
			elseif account.is_cop > 0 and old_camera == nil then
				old_camera = camera

				StartScreenEffect("CamPushInMichael", 5000, false)

				camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
				SetCamCoord(camera, 451.254, -992.409, skyCamHeight)
				SetCamRot(camera, -90.0, 0.0, 260.0, true)
				RenderScriptCams(true, false, camera, 1, 0)

				SetCamActiveWithInterp(camera, old_camera, 2500, false, false)

				while IsCamInterpolating(camera) do
					Citizen.Wait(100)
				end

				zoom = 0
				while zoom < 200 do
					SetCamCoord(camera, 451.254, -992.409, skyCamHeight-zoom)
					SetCamRot(camera, -90.0, 0.0, 260.0+zoom/2, true)
					zoom = zoom+3
					Citizen.Wait(1)
				end

				RenderScriptCams(false, false, old_camera, 1, 0)
				RenderScriptCams(false, false, camera, 1, 0)
				DestroyCam(old_camera, false)
				DestroyCam(camera, false)

				DoScreenFadeOut(1000)
				SetEntityCoords(GetPlayerPed(-1), 451.254, -992.409, 30.689, 1, 0, 0, 1)
				makeCharacter()
				DoScreenFadeIn(1000)
			elseif account.is_ems > 0 and old_camera == nil then
				old_camera = camera

				StartScreenEffect("CamPushInTrevor", 5000, false)

				camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
				SetCamCoord(camera, 360.31, -590.445, skyCamHeight)
				SetCamRot(camera, -90.0, 0.0, 260.0, true)
				RenderScriptCams(true, false, camera, 1, 0)

				SetCamActiveWithInterp(camera, old_camera, 2500, false, false)

				while IsCamInterpolating(camera) do
					Citizen.Wait(100)
				end

				zoom = 0
				while zoom < 200 do
					SetCamCoord(camera, 360.31, -590.445, skyCamHeight-zoom)
					SetCamRot(camera, -90.0, 0.0, 260.0+zoom/2, true)
					zoom = zoom+3
					Citizen.Wait(1)
				end

				RenderScriptCams(false, false, old_camera, 1, 0)
				RenderScriptCams(false, false, camera, 1, 0)
				DestroyCam(old_camera, false)
				DestroyCam(camera, false)

				DoScreenFadeOut(1000)
				SetEntityCoords(GetPlayerPed(-1), 360.31, -590.445, 28.6563, 1, 0, 0, 1)
				makeCharacter()
				DoScreenFadeIn(1000)
			elseif old_camera == nil then
				local spawns = {
				    {x = 434.14, y = -646.847, z = 28.7314},
				    {x = 434.753, y = -629.007, z = 28.7186},
				    {x = 412.16, y = -619.049, z = 28.7015}
				}
				local spawn = spawns[math.random(1,#spawns)]
				old_camera = camera

				StartScreenEffect("CamPushInFranklin", 5000, false)

				camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
				SetCamCoord(camera, spawn.x, spawn.y, skyCamHeight)
				SetCamRot(camera, -90.0, 0.0, 260.0, true)
				RenderScriptCams(true, false, camera, 1, 0)

				SetCamActiveWithInterp(camera, old_camera, 2500, false, false)

				while IsCamInterpolating(camera) do
					Citizen.Wait(100)
				end

				zoom = 0
				while zoom < 200 do
					SetCamCoord(camera, spawn.x, spawn.y, skyCamHeight-zoom)
					SetCamRot(camera, -90.0, 0.0, 260.0+zoom/2, true)
					zoom = zoom+3
					Citizen.Wait(1)
				end

				RenderScriptCams(false, false, old_camera, 1, 0)
				RenderScriptCams(false, false, camera, 1, 0)
				DestroyCam(old_camera, false)
				DestroyCam(camera, false)

				DoScreenFadeOut(1000)
				SetEntityCoords(GetPlayerPed(-1), spawn.x, spawn.y, spawn.z, 1, 0, 0, 1)
				makeCharacter()
				DoScreenFadeIn(1000)
			end

			reverted = true;
		end
	end
end)

function makeCharacter()
	local char = 0
	while char <= 11 do
		if account.characteristics[tostring(char)] ~= nil then
			if type(account.characteristics[tostring(char)]) == "table" then
				SetPedComponentVariation(GetPlayerPed(-1), char, account.characteristics[tostring(char)][1], account.characteristics[tostring(char)][2], 2)
			else
				SetPedComponentVariation(GetPlayerPed(-1), char, account.characteristics[tostring(char)], 0, 2)
			end
		end
		char = char + 1
	end
end

RegisterNUICallback('new', function(data, cb)
	TriggerServerEvent('character:new', data)
end)

RegisterNUICallback('disconnect', function(data, cb)
	TriggerServerEvent('character:disconnect')
end)

RegisterNUICallback('list', function(data, cb)
	TriggerServerEvent("character:getList")
end)

RegisterNUICallback('selected', function(data, cb)
	TriggerServerEvent('character:select', data)
end)

RegisterNetEvent('character:new')
AddEventHandler('character:new', function(status)
	TriggerServerEvent("character:getList")
end)

RegisterNetEvent('character:select')
AddEventHandler('character:select', function(character)
	account = character
end)

RegisterNetEvent('character:getList')
AddEventHandler('character:getList', function(character)
	SendNUIMessage({
		type = "list",
		characters = character
	})
	if character[1] == nil then
		SendNUIMessage({
			type = "error"
		})
	end
end)

RegisterNetEvent('character:getActive')
AddEventHandler('character:getActive', function(cb)
	cb(account)
end)

RegisterNetEvent('character:logout')
AddEventHandler('character:logout', function()
	TriggerServerEvent('character:logout')
	inMorge = false
	RenderScriptCams(false, false, morge_cam, 1, 0)
	DestroyCam(morge_cam, false)
	skyCam = nil
	camera = nil
	old_camera = nil
	skyCam = nil
	account = nil
	accountCheck = false
	reverted = false
	voip = false
	hud = true
end)
