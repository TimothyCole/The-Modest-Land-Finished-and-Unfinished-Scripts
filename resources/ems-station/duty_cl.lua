local locations = {
	{ x=318.833, y=-558.513, z=28.743 },
}

local pressed = false
duty = true
is_ems = 13
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for _, info in pairs(locations) do
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.x, info.y, info.z, true) < 50 and is_ems > 0 then
				DrawMarker(1, info.x, info.y, info.z-1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 0.5, 55, 160, 205, 150, 0, 0, 2, 0, 0, 0, 0)
				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.x, info.y, info.z, true) < 1.5 then
					if not duty then
						DrawSpecialText("Press [ ~g~E~w~ ] to sign on duty")
					else
						DrawSpecialText("Press [ ~g~E~w~ ] to sign off duty".."~n~".."Press [ ~b~Enter~w~ ] to modify your uniform.")
					end
					if IsControlPressed(0, 86) then
						if not pressed then
							duty = not duty
							TriggerServerEvent("ems:duty", duty)
							setOutfit()
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
end)

RegisterNetEvent("ems:is_ems")
AddEventHandler("ems:is_ems", function(status)
	is_ems = status
end)

function setOutfit()
	if duty then
		if is_ems >= 8 then
			SetPedComponentVariation(GetPlayerPed(-1), 11, 13, 0, 2)
		else
			SetPedComponentVariation(GetPlayerPed(-1), 11, 13, 3, 2)
		end
		SetPedComponentVariation(GetPlayerPed(-1), 8, 15, 0, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 4, 9, 3, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 3, 92, 0, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 6, 25, 0, 2)

	else
		TriggerServerEvent("ems:clothes")
		SetPedPropIndex(GetPlayerPed(-1), 1, 18, 0, 2)
		SetPedPropIndex(GetPlayerPed(-1), 0, 11, 0, 2)
	end
end

RegisterNetEvent("ems:clothes")
AddEventHandler("ems:clothes", function(character)
	local char = 0
	while char <= 11 do
		if character.characteristics[tostring(char)] ~= nil then
			if type(character.characteristics[tostring(char)]) == "table" then
				SetPedComponentVariation(GetPlayerPed(-1), char, character.characteristics[tostring(char)][1], character.characteristics[tostring(char)][2], 2)
			else
				SetPedComponentVariation(GetPlayerPed(-1), char, character.characteristics[tostring(char)], 0, 2)
			end
		end
		char = char + 1
	end
end)

function PDNotification(n_department, n_text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(n_text)
	n_image = "CHAR_ANDREAS"
	if n_department == "Armory" then
		n_image = "CHAR_ARTHUR"
	end
	SetNotificationMessage(n_image, n_image, true, 1, "Hospital", n_department, n_text)
	DrawNotification(false, true)
end

function DrawSpecialText(m_text)
	ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(250, 1)
end
