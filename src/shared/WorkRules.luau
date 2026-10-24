local WorkRules = {}
WorkRules.duration = { 1.8, 2.4, 1.2 }
function WorkRules.canFinish(started, now, stage)
	local duration = WorkRules.duration[stage]
	return duration ~= nil and type(started) == "number" and now - started >= duration - .18
end
return WorkRules
