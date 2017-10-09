local listOn = false
local key = 168 -- F7 = 168, LALT = 19

Citizen.CreateThread(function()
    listOn = false
    while true do
        Wait(0)

        if IsControlPressed(0, key) then
            if not listOn then
				TriggerServerEvent("getScoreboard", GetPlayers())

                listOn = true
                while listOn do
                    Wait(0)
                    if(IsControlPressed(0, key) == false) then
                        listOn = false
                        SendNUIMessage({
                            meta = 'close'
                        })
                        break
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("scoreboard")
AddEventHandler("scoreboard", function(html)
	SendNUIMessage({ text = html })
end)

function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end

    return players
end
