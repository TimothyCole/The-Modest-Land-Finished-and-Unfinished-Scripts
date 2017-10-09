RegisterServerEvent('morge:characterize')
AddEventHandler('morge:characterize', function(account)
	local s = source
	TriggerEvent('modest:updateCharacter', account, function(updated)
		TriggerClientEvent('character:logout', s)
	end)
end)
