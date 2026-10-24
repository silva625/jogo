local M = require("../src/shared/WorkMotion")
local function blend(fps)
	local w = 0
	for _ = 1, fps do w += (1 - w) * M.alpha(1 / fps) end
	return w
end
assert(math.abs(blend(30) - blend(144)) < 1e-8, "Blend must not depend on frame rate")
local w = 1
for _ = 1, 60 do w += (0 - w) * M.alpha(1 / 60) end
assert(w < .001, "Canceled actions fade back to the default pose")
assert(M.alpha(0) == 0 and M.alpha(-1) == 0)
for stage = 1, 3 do
	for i = 0, 100 do
		local t = i / 10
		local a, b = M.sample(stage, t), M.sample(stage, t + 1e-5)
		assert(math.abs(a.shoulder - b.shoulder) < .01, "No pose jumps")
		assert(a.shoulder >= 0 and a.shoulder < 115, "Bounded arm angles")
	end
end
print("PASS: animation blending is stable at 30/144 FPS; poses continuous and bounded")
