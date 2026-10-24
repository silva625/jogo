local Work = require("../src/shared/WorkRules")
for stage = 1, 3 do
	assert(not Work.canFinish(nil, 10, stage))
	assert(not Work.canFinish(10, 10.1, stage), "Instant completion is rejected")
	assert(Work.canFinish(10, 10 + Work.duration[stage], stage))
end
assert(not Work.canFinish(10, 20, 4))
print("PASS: timed work requires a valid start, stage and hold duration")
