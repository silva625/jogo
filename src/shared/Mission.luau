-- Pure mission rules, shared by the server and command-line tests.
local Mission = {}
Mission.stages = {
	{ title = "Retire o lixo", total = 8, tool = "Saco de lixo", action = "Recolher" },
	{ title = "Pinte as paredes", total = 4, tool = "Rolo de pintura", action = "Pintar" },
	{ title = "Decore a casa", total = 3, tool = "Decoração", action = "Decorar" },
}
function Mission.new()
	return { stage = 1, count = 0, cash = 250, xp = 0, completed = false, used = {} }
end
function Mission.apply(state, stage, id)
	if state.completed or stage ~= state.stage or state.used[id] then
		return false
	end
	state.used[id] = true
	state.count += 1
	state.cash += 25
	state.xp += 20
	if state.count == Mission.stages[stage].total then
		state.stage += 1
		state.count = 0
		if state.stage > #Mission.stages then
			state.completed = true
			state.cash += 5000
			state.xp += 300
		end
	end
	return true
end
return Mission
