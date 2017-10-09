local locations = {
	{ x=-452.147, y=6005.43, z=30.500 },
	{ x=439.817, y=-993.397, z=30.689 },
	{ x=1854.330, y=3700.847, z=33.265 },
	{ x=450.8, y=-992.3, z = 30.689 }
}

local pressed = false
duty = false
is_cop = 0
duty = true
is_cop = 10
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for _, info in pairs(locations) do
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.x, info.y, info.z, true) < 50 and is_cop > 0 then
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
							TriggerServerEvent("pd:duty", duty)
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

RegisterNetEvent("pd:is_cop")
AddEventHandler("pd:is_cop", function(status)
	is_cop = status
end)

function setOutfit()
	if duty then
		SetPedComponentVariation(GetPlayerPed(-1), 8, 58, 0, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 11, 55, 0, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 4, 35, 0, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 6, 24, 0, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 3, 0, 0, 2)
		SetPedPropIndex(GetPlayerPed(-1), 1, 18, 0, 2)
		SetPedArmour(GetPlayerPed(-1), 100)
		PDNotification("", "Good Morning "..GetPlayerName(PlayerId())..". Stop by and see Sandy at the armory to pick up your weapons.")
	else
		TriggerServerEvent("pd:clothes")
		SetPedPropIndex(GetPlayerPed(-1), 1, 18, 0, 2)
		SetPedPropIndex(GetPlayerPed(-1), 0, 11, 0, 2)
		SetPedArmour(GetPlayerPed(-1), 0)
		SetPedComponentVariation(GetPlayerPed(-1), 9, 0, 1, 2)
	end
end

RegisterNetEvent("pd:clothes")
AddEventHandler("pd:clothes", function(character)
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
	SetNotificationMessage(n_image, n_image, true, 1, "Police Department", n_department, n_text)
	DrawNotification(false, true)
end

function DrawSpecialText(m_text)
	ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(250, 1)
end
