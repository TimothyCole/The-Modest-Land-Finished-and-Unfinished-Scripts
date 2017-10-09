local blips = {
	{ title="Go Postal", colour=39, id=85, x=-311.6630, y=-1029.1395, z=30.3850 },
	{ title="Go Postal", colour=39, id=85, x=-441.5871, y=6144.7211, z=31.4783 },
	{ title="Go Postal", colour=39, id=85, x=-3157.6508, y=1128.9541, z=20.8447 },
	{ title="Go Postal", colour=39, id=85, x=2983.7958, y=3488.7570, z=71.3818 }
}

local gopostal = {
	{ x=-8.1763, y=-1111.0294, z=28.6175 },
	{ x=-317.0818, y=6090.0209, z=31.4622 },
	{ x=-1297.8881, y=-384.5165, z=36.7344 },
	{ x=822.2550, y=-2144.3666, z=28.7616 },
	{ x=-652.4305, y=-940.2009, z=22.0881 },
	{ x=237.428, y=-43.655, z=69.698 },
	{ x=2583.2360, y=286.6179, z=108.4577 },
	{ x=1703.9606, y=3750.3444, z=34.0815 },
	{ x=-1131.3316, y=2699.0109, z=18.8003 }
}

Citizen.CreateThread(function()
    for _, info in pairs(blips) do
		info.blip = AddBlipForCoord(info.x, info.y, info.z)
		SetBlipSprite(info.blip, info.id)
		SetBlipDisplay(info.blip, 4)
		SetBlipScale(info.blip, 0.9)
		SetBlipColour(info.blip, info.colour)
		SetBlipAsShortRange(info.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(info.title)
		EndTextCommandSetBlipName(info.blip)
    end
end)

local pressed = false
local distance = nil
local job = nil
local lastTruck = 0
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
	    for _, info in pairs(blips) do
			if info.title == "Go Postal" and GetDistanceBetweenCoords(info.x, info.y, info.z,GetEntityCoords(GetPlayerPed(-1))) < 50 and not job then
				DrawMarker(1, info.x, info.y, info.z-1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 0.25, 0, 155, 255, 200, 0, 0, 0, 0)
				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), info.x, info.y, info.z, true) < 2 and (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false or GetVehiclePedIsIn(GetPlayerPed(-1), false) == lastTruck) then
					DrawSpecialText("Press [ ~b~Enter~w~ ] to start working for Go Postal")
			        if IsControlPressed(0, 176) then
			            if not pressed then
							job = gopostal[math.random(#gopostal)]
							job.distance = GetDistanceBetweenCoords(job.x, job.y, job.z, GetEntityCoords(GetPlayerPed(-1)))
							job.truck = -1

							if GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= lastTruck or IsPedInAnyVehicle(GetPlayerPed(-1), true) == false then
								vehicle = GetHashKey("boxville2")
								RequestModel(vehicle)

								while not HasModelLoaded(vehicle) do
									RequestModel(vehicle)
									Citizen.Wait(0)
								end

								job.truck = CreateVehicle(vehicle, info.x, info.y, info.z+1.0, 2.0, true, false)
							else
								job.truck = lastTruck
							end

							if job.truck ~= -1 then
								SetVehicleOnGroundProperly(job.truck)
								SetVehRadioStation(job.truck, "OFF")
								SetPedIntoVehicle(GetPlayerPed(-1), job.truck, -1)
								SetVehicleEngineOn(job.truck, true, false, false)
								SetEntityAsMissionEntity(job.truck, true, true)

								SetNewWaypoint(job.x, job.y)
								lastTruck = job.truck
								TriggerServerEvent("postal:addJob", job)
							else
								SetNotificationTextEntry("STRING")
								AddTextComponentString("Failed to get truck! Try again.")
								DrawNotification(0,1)
								job = nil
							end

							pressed = true
			                while pressed do
			                    Wait(0)
			                    if(IsControlPressed(0, 176) == false) then
			                        pressed = false
			                        break
			                    end
			                end
		                end
	                end
				end
			end
		end
		if job and GetDistanceBetweenCoords(job.x, job.y, job.z, GetEntityCoords(GetPlayerPed(-1))) < 50 then
			DrawMarker(1, job.x, job.y, job.z-1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 0.25, 0, 155, 255, 200, 0, 0, 0, 0)
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), job.x, job.y, job.z, true) < 4 and GetVehiclePedIsIn(GetPlayerPed(-1), false) == job.truck then
				DrawSpecialText("Press [ ~g~E~w~ ] to deliver your Go Postal packages")
		        if IsControlPressed(0, 86) then
		            if not pressed then

						if job.distance > 2500 then
							pay = 2500
						else
							pay = math.ceil(job.distance)
						end

						SetNotificationTextEntry("STRING")
						AddTextComponentString("~h~Job Completed!~h~ ~n~" .. "+ ~g~$" .. pay)
						TriggerServerEvent("postal:giveMoney", pay)
						DrawNotification(0,1)
						job = nil

						pressed = true
		                while pressed do
		                    Wait(0)
		                    if(IsControlPressed(0, 86) == false) then
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

RegisterNetEvent("placeMarker")
AddEventHandler("placeMarker", function(x, y)
	SetNewWaypoint(x, y)
end)

function DrawSpecialText(m_text)
    ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(250, 1)
end
