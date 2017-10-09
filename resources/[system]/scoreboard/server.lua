local characters = {}

RegisterServerEvent('loggedIn')
AddEventHandler('loggedIn', function()
	characters[GetHostId(source)] = "John Doe"
end)

RegisterServerEvent("getScoreboard")
AddEventHandler("getScoreboard", function(ptable)
	local players = {}
	for _, i in ipairs(ptable) do
		if characters[i] then
			if GetPlayerName(i) and GetPlayerPing(i) then
				table.insert(players, '<tr><td>' .. i .. '</td><td>' .. GetPlayerName(i) .. '</td><td>' .. GetPlayerPing(i) .. '<small>ms</small></td></tr>')
			end
		else
			if GetPlayerName(i) and GetPlayerPing(i) then
				table.insert(players, '<tr><td>' .. i .. '</td><td>' .. GetPlayerName(i) .. '</td><td>' .. GetPlayerPing(i) .. '<small>ms</small></td></tr>')
			end
		end
	end
	TriggerClientEvent("scoreboard", source, table.concat(players))
end)
