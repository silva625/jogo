-- Frame-rate-independent blending and continuous procedural work poses.
local WorkMotion = {}
function WorkMotion.alpha(dt)
	return 1 - math.exp(-math.max(0, dt) * 14)
end
function WorkMotion.sample(stage, elapsed)
	local cycle = math.sin(math.max(0, elapsed) * math.pi * 2 * (stage == 1 and 1.2 or .8))
	if stage == 1 then return { shoulder = 38 + cycle * 10, side = 10 + cycle * 9, elbow = 20, waist = -7, left = 0 } end
	if stage == 2 then return { shoulder = 88 + cycle * 13, side = -8, elbow = 25 - cycle * 8, waist = -2, left = 0 } end
	return { shoulder = 42 + cycle * 3, side = -8, elbow = 20, waist = -3, left = 40 }
end
return WorkMotion
