local magic = {}
local hidden = {}
function magic.add(tabe, id)
	if magic.position(tabe, id) == 0 then
		table.insert(tabe, id)
	end
end

function magic.remove(tabe, id)
	if magic.position(tabe, id) ~= 0 then
    	table.remove(tabe, magic.position(tabe, id))
	end
end

function magic.position(tabe, id)
	for k, v in pairs(tabe) do
		if v == id then
			return k
		end
	end
	return 0
end

RegisterNetEvent("hide:blip")
AddEventHandler("hide:blip", function(user, toogle)
	if not toogle then
		magic.remove(hidden, tonumber(user))
	else
		magic.add(hidden, tonumber(user))
	end
end)

local talking = ""
Citizen.CreateThread(function()
	while true do
		Wait(1)
		for id = 0, 64 do
			x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
			if NetworkIsPlayerActive(id) and GetDistanceBetweenCoords(x,y,z, GetEntityCoords(GetPlayerPed(-1))) < 10 and magic.position(hidden, GetPlayerServerId(id)) == 0 then
				ped = GetPlayerPed(id)
				blip = GetBlipFromEntity(ped)

				if NetworkIsPlayerTalking(id) then
					if GetPlayerPed(id) ~= GetPlayerPed(-1) then
						-- DrawMarker(2, x, y, z+1.10, 0, 0, 0, 0, 180.0, 0, 0.3, 0.1, 0.25, 0, 0, 200, 200, 0, GetEntityHeading(GetPlayerPed(-1)), 0, 0)
						--Citizen.InvokeNative(0xBFEFE3321A3F5015, ped, GetPlayerName(id), false, false, "", false)
						DrawTracerText(tostring(GetPlayerServerId(id)), {28, 135, 181, 200}, 1.25)
					end
					if talking == "" then
						talking = GetPlayerName(id)
					else
						talking = talking .. ", " .. GetPlayerName(id)
					end
				elseif GetPlayerPed(id) ~= GetPlayerPed(-1) then
					-- DrawMarker(2, x, y, z+1.10, 0, 0, 0, 0, 180.0, 0, 0.3, 0.1, 0.25, 0, 200, 0, 200, 0, GetEntityHeading(GetPlayerPed(-1)), 0, 0)
					--Citizen.InvokeNative(0xBFEFE3321A3F5015, ped, GetPlayerName(id), false, false, "", false)
					DrawTracerText(tostring(GetPlayerServerId(id)), {255, 255, 255, 200}, 1.25)
				end
			end
		end
		if talking ~= "" then
			-- no talking display at bottom of screen
			--[[
			SetTextFont(0)
			SetTextProportional(0)
			SetTextScale(0.0, 0.5)
			SetTextColour(53, 131, 203, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			SetTextEntry("STRING")
			AddTextComponentString("Talking")
			SetTextCentre(true)
			DrawText(0.5, 0.93)

			SetTextFont(0)
			SetTextProportional(0)
			SetTextScale(0.0, 0.35)
			SetTextColour(255, 255, 255, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			SetTextEntry("STRING")
			AddTextComponentString(talking)
			SetTextCentre(true)
			DrawText(0.5, 0.97)
			talking = ""
			--]]
		end

		-- BELOW THIS LINE IS WHERE SCAMMER'S PLAYERBLIPS SCRIPT BEGINS
		-- MODIFIED TO SHOW ONLY EMERGENCY PERSONEL
		-- extend minimap on keypress
		if IsControlJustPressed( 0, 20 ) then

			if not isRadarExtended then

				SetRadarBigmapEnabled( true, false )
				isRadarExtended = true

				Citizen.CreateThread(function()

					run = true

					while run do

						for i = 0, 500 do

							Wait(1)

							if not isRadarExtended then

								run = false
								break

							end

						end

						SetRadarBigmapEnabled( false, false )
						isRadarExtended = false

					end

				end)

			else

				SetRadarBigmapEnabled( false, false )
				isRadarExtended = false

			end

		end

		--Citizen.Trace("about to check if cop/ems...")
		if IsPedEmergencyPersonnel(GetPlayerPed(-1)) then
			--Citizen.Trace("ped was emergency!!!!")
			-- show blips
			for id = 0, 64 do

				local ped = GetPlayerPed( id )
				if ped then
					local pedType = getPedEmergencyPersonnelType(ped)
				end

				if NetworkIsPlayerActive( id ) and GetPlayerPed( id ) ~= GetPlayerPed( -1 ) then

					local blip = GetBlipFromEntity( ped )
					if not DoesBlipExist( blip ) and  IsPedEmergencyPersonnel(ped) then -- Add blip on player
						blip = AddBlipForEntity( ped )
						SetBlipSprite( blip, 1 )
						if pedType == "cop" then
							Citizen.Trace("pedType = " .. pedType)
							SetBlipColour(blip, 3)
						elseif pedType == "fire" then
							Citizen.Trace("pedType = " .. pedType)
							SetBlipColour(blip, 1)
						end
						Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) -- Player Blip indicator

					else -- update blip

						veh = GetVehiclePedIsIn( ped, false )
						blipSprite = GetBlipSprite( blip )
						if pedType == "cop" then
							SetBlipColour(blip, 3)
						elseif pedType == "fire" then
							SetBlipColour(blip, 1)
						end

						if not GetEntityHealth( ped ) then -- dead

							if blipSprite ~= 274 then

								SetBlipSprite( blip, 274 )
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false ) -- Player Blip indicator

							end

						elseif veh then

							vehClass = GetVehicleClass( veh )
							vehModel = GetEntityModel( veh )

							if vehClass == 15 then -- jet

								if blipSprite ~= 422 then

									SetBlipSprite( blip, 422 )
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false ) -- Player Blip indicator

								end

							elseif vehClass == 16 then -- plane

								if vehModel == GetHashKey( "besra" ) or vehModel == GetHashKey( "hydra" )
									or vehModel == GetHashKey( "lazer" ) then -- jet

									if blipSprite ~= 424 then

										SetBlipSprite( blip, 424 )
										Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false ) -- Player Blip indicator

									end

								elseif blipSprite ~= 423 then

									SetBlipSprite( blip, 423 )
									Citizen.InvokeNative (0x5FBCA48327B914DF, blip, false ) -- Player Blip indicator

								end

							elseif vehClass == 14 then -- boat

								if blipSprite ~= 427 then

									SetBlipSprite( blip, 427 )
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false ) -- Player Blip indicator

								end

							elseif vehModel == GetHashKey( "insurgent" ) or vehModel == GetHashKey( "insurgent2" )
							or vehModel == GetHashKey( "limo2" ) then -- insurgent (+ turreted limo cuz limo blip wont work)

								if blipSprite ~= 426 then

									SetBlipSprite( blip, 426 )
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false ) -- Player Blip indicator

								end

							elseif vehModel == GetHashKey( "rhino" ) then -- tank

								if blipSprite ~= 421 then

									SetBlipSprite( blip, 421 )
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false ) -- Player Blip indicator

								end

							elseif blipSprite ~= 1 then -- default blip

								SetBlipSprite( blip, 1 )
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) -- Player Blip indicator

							end

							-- Show number in case of passangers
							passengers = GetVehicleNumberOfPassengers( veh )

							if passengers then

								if not IsVehicleSeatFree( veh, -1 ) then

									passengers = passengers + 1

								end

								ShowNumberOnBlip( blip, passengers )

							else

								HideNumberOnBlip( blip )

							end

						else

							-- Remove leftover number
							HideNumberOnBlip( blip )

							if blipSprite ~= 1 then -- default blip

								SetBlipSprite( blip, 1 )
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) -- Player Blip indicator

							end

						end

						SetBlipRotation( blip, math.ceil( GetEntityHeading( veh ) ) ) -- update rotation
						SetBlipNameToPlayerName( blip, id ) -- update blip name
						SetBlipScale( blip,  0.85 ) -- set scale

						-- set player alpha
						if IsPauseMenuActive() then

							SetBlipAlpha( blip, 255 )

						else

							x1, y1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
							x2, y2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
							distance = ( math.floor( math.abs( math.sqrt( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) ) ) / -1 ) ) + 900
							-- Probably a way easier way to do this but whatever im an idiot

							if distance < 0 then

								distance = 0

							elseif distance > 255 then

								distance = 255

							end

							SetBlipAlpha( blip, distance )

						end

					end

				end

			end
		else -- not emergency personnel
			--Citizen.Trace("found non emergency personnel")
			for x = 0, 64 do
				--Wait(5000)
				--Citizen.Trace("checking " .. GetPlayerName(x))
				local everyPedInGame = GetPlayerPed(x)
				local pedBlip = GetBlipFromEntity(everyPedInGame)
				--Citizen.Trace("everyPedInGame = " .. everyPedInGame)
				--Citizen.Trace("pedBlip = " .. pedBlip)
				if GetBlipSprite( pedBlip ) ~= 2 then -- not invisible already
					--Citizen.Trace("pedBlip was not invisible already... making invisible...")
					SetBlipSprite(pedBlip, 2) -- make invis (ghetto way to remove blip)
					SetBlipScale( pedBlip,  0.01 ) -- set scale (ghetto way to remove blip)
				end
			end
		end
	end
end)

local emergencySkins = {
	{name = "s_m_y_sheriff_01", type="cop"},
	{name = "s_f_y_sheriff_01", type="cop"},
	{name = "s_m_y_blackops_01", type="cop"},
	{name = "s_m_m_fibsec_01", type="cop"},
	{name = "s_m_m_fiboffice_01", type="cop"},
	{name = "s_m_m_ciasec_01", type="cop"},
	{name = "s_m_y_cop_01", type="cop"},
	{name = "s_m_m_paramedic_01", type="fire"},
	{name = "s_m_y_fireman_01", type="fire"},
	{name = "s_f_y_scrubs_01", type="fire"}
}

function IsPedEmergencyPersonnel(ped)
	for i = 1, #emergencySkins do
		local skin = emergencySkins[i].name
		if IsPedModel(ped, GetHashKey(skin)) then
			return true
		end
	end
	return false
end

function getPedEmergencyPersonnelType(ped)
	local personnelIndex = 0
	for i = 1, #emergencySkins do
		local skin = emergencySkins[i].name
		if IsPedModel(ped, GetHashKey(skin)) then
			personnelIndex = i
		end
	end
	if personnelIndex ~= 0 then
		return emergencySkins[personnelIndex].type
	else
		return nil
	end
end

function DrawTracerText(text, color, spacing)
	local x,y,z = table.unpack(GetEntityCoords(ped))
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

	local scale = (1/dist)*30
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov

	SetTextFont(0)
	SetTextProportional(1)
	SetTextColour(table.unpack(color))
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	SetDrawOrigin(x, y, z+spacing, 0)
	SetTextScale(0.0*scale, 0.05*scale)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end
