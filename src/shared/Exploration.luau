local Exploration = { total = 12 }
function Exploration.new()
	return { collected = {}, count = 0 }
end
function Exploration.claim(progress, id)
	if type(id) ~= "number" or id % 1 ~= 0 or id < 1 or id > Exploration.total or progress.collected[id] then
		return false, 0, 0, false
	end
	progress.collected[id] = true
	progress.count += 1
	local complete = progress.count == Exploration.total
	return true, complete and 850 or 100, 25, complete
end
return Exploration
