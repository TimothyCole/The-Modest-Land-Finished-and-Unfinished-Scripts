function CreatePlayer(source, identifier, group)
	local self = {}

	self.source = source
	self.identifier = identifier
	self.group = group
	-- END --
	self.coords = {x = 0.0, y = 0.0, z = 0.0}
	self.session = {}
	self.bankDisplayed = false

	local rTable = {}

	rTable.getCoords = function()
		return self.coords
	end

	rTable.setCoords = function(x, y, z)
		self.coords = {x = x, y = y, z = z}
	end

	rTable.kick = function(r)
		DropPlayer(self.source, r)
	end

	-- rTable.addMoney = function(m)
	-- 	local newMoney = self.money + m
	--
	-- 	self.money = newMoney
	--
	-- 	TriggerClientEvent("modest:addedMoney", self.source, m, settings.defaultSettings.nativeMoneySystem)
	-- 	if not settings.defaultSettings.nativeMoneySystem then
	-- 		TriggerClientEvent('modest:activateMoney', self.source , self.money)
	-- 	end
	-- end
	--
	-- rTable.removeMoney = function(m)
	-- 	local newMoney = self.money - m
	--
	-- 	self.money = newMoney
	--
	-- 	TriggerClientEvent("modest:removedMoney", self.source, m, settings.defaultSettings.nativeMoneySystem)
	-- 	if not settings.defaultSettings.nativeMoneySystem then
	-- 		TriggerClientEvent('modest:activateMoney', self.source , self.money)
	-- 	end
	-- end
	--
	-- rTable.addBank = function(m)
	-- 	local newBank = self.bank + m
	-- 	self.bank = newBank
	--
	-- 	TriggerClientEvent("modest:addedBank", self.source, m)
	-- end
	--
	-- rTable.removeBank = function(m)
	-- 	local newBank = self.bank - m
	-- 	self.bank = newBank
	--
	-- 	TriggerClientEvent("modest:removedBank", self.source, m)
	-- end
	--
	-- rTable.displayMoney = function(m)
	-- 	TriggerClientEvent("modest:displayMoney", self.source, math.floor(m))
	-- end
	--
	-- rTable.displayBank = function(m)
	-- 	if not self.bankDisplayed then
	-- 		TriggerClientEvent("modest:displayBank", self.source, math.floor(m))
	-- 		self.bankDisplayed = true
	-- 	end
	-- end

	rTable.setSessionVar = function(key, value)
		self.session[key] = value
	end

	rTable.getSessionVar = function(k)
		return self.session[k]
	end

	rTable.getPermissions = function()
		return 0
	end

	rTable.setPermissions = function(p)
		self.permission_level = p
	end

	rTable.getIdentifier = function(i)
		return self.identifier
	end

	rTable.getGroup = function()
		return self.group
	end

	rTable.set = function(k, v)
		self[k] = v
	end

	rTable.get = function(k)
		return self[k]
	end

	rTable.setGlobal = function(g, default)
		self[g] = default or ""

		rTable["get" .. g:gsub("^%l", string.upper)] = function()
			return self[g]
		end

		rTable["set" .. g:gsub("^%l", string.upper)] = function(e)
			self[g] = e
		end

		Users[self.source] = rTable
	end

	return rTable
end
