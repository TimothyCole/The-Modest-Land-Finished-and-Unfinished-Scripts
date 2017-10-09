Citizen.CreateThread(function()
	while true do
		Wait(1)

		playerPed = GetPlayerPed(-1)
		if playerPed then
			playerCar = GetVehiclePedIsIn(playerPed, false)
			if playerCar and GetPedInVehicleSeat(playerCar, -1) == playerPed then
				carSpeed = GetEntitySpeed(playerCar)
				speed = math.ceil(carSpeed * 2.236936)
				prefix = "MPH"

				DrawHUDText({0.1575, 0.87}, {0.5, 1.75}, tostring(speed), false)
				DrawHUDText({0.175, 0.9555}, {0.5, 0.5}, "~y~" .. prefix, true)
			end
		end
	end
end)

function DrawHUDText(p, s, text, center)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(table.unpack(s))
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(center)
	SetTextEntry("STRING")

	AddTextComponentString(text)
	DrawText(table.unpack(p))
end
