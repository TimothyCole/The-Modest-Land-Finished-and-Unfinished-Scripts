ranks = {
	[1] = "EMT Recruit",
	[2] = "Probationary EMT",
	[3] = "EMT",
	[4] = "Paramedic",
	[5] = "Lieutenant",
	[6] = "Senior Lieutenant",
	[7] = "Captain",
	[8] = "Senior Captain",
	[9] = "Battalion Chief",
	[10] = "Assistant Chief",
	[11] = "EMS Advisor",
	[12] = "Fire Chief",
	[13] = "Senior Paramedic",
}

function ID2Rank(id)
	if ranks[id] then
		return ranks[id]
	else
		return "EMT Recruit"
	end
end

function Rank2ID(rank)
	id = 0
	for _,v in ipairs(ranks) do
		if string.lower(v) == string.lower(rank) then
			id = _
		end
	end
	return id
end
