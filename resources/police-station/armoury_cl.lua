local armories = {
	{ name = "Police Department Armory", x = 454.053, y = -979.939, z = 30.689, h = 86.588, model = 368603149, gaveBirth = false }
}
local loadout = {
	{ display_name = "Flares", weapon = "WEAPON_FLARE", rank = 1 },
	{ display_name = "Tear Gas", weapon = "WEAPON_BZGAS", rank = 6 },
	{ display_name = "Flare Gun", weapon = "WEAPON_FLAREGUN", rank = 1 },
	{ display_name = "Fire Extinguisher", weapon = "WEAPON_FIREEXTINGUISHER", rank = 1 },
	{ display_name = "Flash Light", weapon = "WEAPON_FLASHLIGHT", rank = 1 },
	{ display_name = "Taser", weapon = "WEAPON_STUNGUN", rank = 1 },
	{ display_name = "Nightstick", weapon = "WEAPON_NIGHTSTICK", rank = 1 },
	{ display_name = "Combat Pistol", weapon = "WEAPON_COMBATPISTOL", rank = 1 },
	{ display_name = "Pump Shotgun", weapon = "WEAPON_PUMPSHOTGUN", rank = 1 },
	{ display_name = "Carbine Rifle", weapon = "WEAPON_CARBINERIFLE", rank = 4 },
	{ display_name = "Sniper Rifle", weapon = "WEAPON_SNIPERRIFLE", rank = 6 },
}
local pressed = false
local menuOpen = false
local weapons = {}
local availableWeapons = {}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for _,v in pairs(armories) do
			if not v.gaveBirth then
				RequestModel(v.model)

				while not HasModelLoaded(v.model) do
					RequestModel(v.model)
					Citizen.Wait(0)
				end

				local ped = CreatePed(4, v.model, v.x, v.y, v.z-1, v.h, false, false)
				armories[_].gaveBirth = true

				if ped then
					SetEntityCanBeDamaged(ped, false)
					SetPedCanRagdollFromPlayerImpact(ped, false)
					TaskSetBlockingOfNonTemporaryEvents(ped, true)
					SetPedFleeAttributes(ped, 0, 0)
					SetPedCombatAttributes(ped, 17, 1)
					SetEntityInvincible(ped)
					TaskStartScenarioInPlace(ped, "WORLD_HUMAN_COP_IDLES", 0, true);
				end
			end

			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v.x, v.y, v.z, true) < 50 and is_cop > 0 then
				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v.x, v.y, v.z, true) < 2.65 then
					DrawSpecialText("Press [ ~g~E~w~ ] to interact with Sandy.")
					if menuOpen and duty then
						Menu.Title(v.name)

						weapons = {}
						availableWeapons = {}
						for _,v in pairs(loadout) do
							if is_cop >= v.rank then
								local hasWeapon = HasPedGotWeapon(GetPlayerPed(-1), v.weapon, false)
								CheckOutWeapon(v.display_name, v.weapon, hasWeapon)
								if hasWeapon then
									table.insert(weapons, v.weapon)
								else
									table.insert(availableWeapons, v.weapon)
								end
							end
						end

						if #weapons > 0 then
							ReturnWeapons()
						end
						if #availableWeapons ~= 0 then
							CheckOutAllWeapons()
						end

						Menu.updateSelection()
					end

			        if IsControlPressed(0, 86) then
			            if not pressed then
							if duty then
								menuOpen = not menuOpen
							elseif is_cop > 0 then
								PDNotification("Armory", "I'm going to need you to go on duty before I can give you any weapons.")
							else
								PDNotification("Armory", "How did you get back here? Don't me call for backup!")
							end
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

function CheckOutWeapon(name, weapon, checkedOut)
	Menu.Bool(name, checkedOut, function(has)
		if has then
			GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(weapon), 200, true, true)
			GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(weapon), GetHashKey("COMPONENT_AT_PI_FLSH"))
			GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(weapon), GetHashKey("COMPONENT_AT_AR_FLSH"))
		else
			RemoveWeaponFromPed(GetPlayerPed(-1), GetHashKey(weapon))
		end
	end)
end

function CheckOutAllWeapons()
	if Menu.Option("Checkout All Weapons", true) then
		for _,v in pairs(availableWeapons) do
			GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(v), 200, true, true)
			GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(v), GetHashKey("COMPONENT_AT_PI_FLSH"))
			GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(v), GetHashKey("COMPONENT_AT_AR_FLSH"))
		end
	end
end

function ReturnWeapons()
	if Menu.Option("Return All Weapons", true) then
		RemoveAllPedWeapons(GetPlayerPed(-1))
	end
end
