ranks = {
	[1] = "Cadet",
	[2] = "Police Officer",
	[3] = "Police Officer II",
	[4] = "Sergeant",
	[5] = "Staff Sergeant",
	[6] = "Lieutenant",
	[7] = "Captain",
	[8] = "Assistant Chief",
	[9] = "Chief of Police",
	[10] = "State Trooper",
}

function ID2Rank(id)
	if ranks[id] then
		return ranks[id]
	else
		return "Cadet"
	end
end

function Rank2ID(rank)
	id = 0
	for _,v in ipairs(ranks) do
		if v == rank then
			id = _
		end
	end
	return id
end
