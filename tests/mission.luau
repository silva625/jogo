local Mission = require("../src/shared/Mission")
local state = Mission.new()
assert(not Mission.apply(state, 2, "early"), "Cannot skip stages")
assert(Mission.apply(state, 1, "trash1"))
assert(not Mission.apply(state, 1, "trash1"), "Duplicate gives no reward")
assert(state.cash == 275 and state.xp == 20)
for i = 2, 8 do assert(Mission.apply(state, 1, "trash" .. i)) end
assert(state.stage == 2 and state.count == 0)
for i = 1, 4 do assert(Mission.apply(state, 2, "wall" .. i)) end
for i = 1, 3 do assert(Mission.apply(state, 3, "decor" .. i)) end
assert(state.completed and state.cash == 5625 and state.xp == 600)
assert(not Mission.apply(state, 3, "extra"), "Completion reward only once")
assert(not Mission.new().completed, "Players have independent progress")
print("PASS: stage order, duplicate protection, rewards, completion and independent state")
