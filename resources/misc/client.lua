RegisterNetEvent('modestland:playerLoaded')
AddEventHandler('modestland:playerLoaded', function()
	exports.spawnmanager:forceRespawn()
	exports.spawnmanager:setAutoSpawnCallback(function()
		TriggerServerEvent('modestland:spawnPlayer')
	end)
end)

RegisterNetEvent('modestland:spawn')
AddEventHandler('modestland:spawn', function(model, job, spawn, weapons)
	exports.spawnmanager:spawnPlayer({x = 549.738, y = -2208.249, z = 68.981, model = 402729631, heading = 0.0}, function()

	end)
end)

zones = {['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz" }
headings = {
	[0] = { symbol = 'N', size = 0.03 },
	[45] = { symbol = 'NW', size = 0.053 },
	[90] = { symbol = 'W', size = 0.035 },
	[135] = { symbol = 'SW', size = 0.05 },
	[180] = { symbol = 'S', size = 0.03 },
	[225] = { symbol = 'SE', size = 0.045 },
	[270] = { symbol = 'E', size = 0.03 },
	[315] = { symbol = 'NE', size = 0.048 },
	[360] = { symbol = 'N', size = 0.03 },
}
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
		SetTextFont(0)
		SetTextProportional(1)
		SetTextScale(0.0, 0.35)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(1, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")

		AddTextComponentString("X: " .. x .. " - Y: " .. y .. " - Z: " ..  z .. " - Heading: ".. GetEntityHeading(GetPlayerPed(-1)))
		DrawText(0.006, 0.045)

		local pos = GetEntityCoords(GetPlayerPed(-1))
		local streetA, streetB = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
		local street = {}

		if not ((streetA == lastStreetA or streetA == lastStreetB) and (streetB == lastStreetA or streetB == lastStreetB)) then
			-- Ignores the switcharoo while doing circles on intersections
			lastStreetA = streetA
			lastStreetB = streetB
		end

		if lastStreetA ~= 0 then
			table.insert(street, GetStreetNameFromHashKey(lastStreetA))
		end

		if lastStreetB ~= 0 then
			table.insert(street, GetStreetNameFromHashKey(lastStreetB))
		end

		for k,v in pairs(headings) do
			direction = GetEntityHeading(GetPlayerPed())
			if(math.abs(direction - k) < 22.5)then
				direction = v
				break;
			end
		end

		if direction then
			DrawHUDText({0.005, 0.001}, {0.0, 0.8}, direction.symbol, false)
			DrawHUDText({direction.size, 0.007}, {0.0, 0.38}, "~y~"..table.concat(street, " ~w~&~y~ "), false)

			if GetNameOfZone(pos.x, pos.y, pos.z) ~= nil and zones[GetNameOfZone(pos.x, pos.y, pos.z)] and direction.size ~= nil then
				DrawHUDText({direction.size, 0.0275}, {0.0, 0.3}, "~b~"..zones[GetNameOfZone(pos.x, pos.y, pos.z)], false)
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

Citizen.CreateThread(function()
	for i = 1, 12 do
		Citizen.InvokeNative(0xDC0F817884CDD856, i, false)
	end
end)

Citizen.CreateThread(function()
	-- Pause Name
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), 'FE_THDR_GTAO', "The Modest Land")
	-- no police npc / never wanted
	while true do
		Wait(1)
		if GetPlayerWantedLevel(PlayerId()) ~= 0 then
			SetPlayerWantedLevel(PlayerId(),0,false)
			SetPlayerWantedLevelNow(PlayerId(),false)
			SetMaxWantedLevel(0)
		end
	end
end)

-- Citizen.CreateThread(function()
--     while true do
--         Wait(0)
--         if NetworkIsSessionStarted() then
--             NetworkSessionSetMaxPlayers(0, 32)
--             return
--         end
--     end
-- end)

Citizen.CreateThread(function()
	while true do
		-- These natives has to be called every frame.
		SetVehicleDensityMultiplierThisFrame(0.7)
		SetPedDensityMultiplierThisFrame(0.7)
		SetRandomVehicleDensityMultiplierThisFrame(0.9)
		SetParkedVehicleDensityMultiplierThisFrame(0.9)
		SetScenarioPedDensityMultiplierThisFrame(0.9, 0.9)

		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)
		data = ClearAreaOfCops(pos.x, pos.y, pos.z, 400.0)
		-- DrawHUDText({0.5, 0.9}, {0.5, 0.5}, "~r~DEBUG: ~w~" .. json.encode(data), true)

		Citizen.Wait(1)
	end
end)

RegisterNetEvent('announcement')
AddEventHandler('announcement', function(msg)
	SendNUIMessage({
		message = msg
	})
end)

function serializeTable(val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0

	local tmp = string.rep(" ", depth)

	if name then tmp = tmp .. name .. " = " end

	if type(val) == "table" then
		tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

		for k, v in pairs(val) do
			tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
		end

		tmp = tmp .. string.rep(" ", depth) .. "}"
	elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
		tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
		tmp = tmp .. (val and "true" or "false")
	else
		tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
	end

	return tmp
end
