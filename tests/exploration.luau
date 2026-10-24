local E = require("../src/shared/Exploration")
local p = E.new()
local cash, xp, bonuses = 0, 0, 0
assert(not E.claim(p, 0) and not E.claim(p, 13) and not E.claim(p, 1.5))
for i = 1, 12 do
	local ok, reward, experience, complete = E.claim(p, i)
	assert(ok)
	cash += reward
	xp += experience
	if complete then bonuses += 1 end
	assert(not E.claim(p, i), "Crystals cannot be farmed twice")
end
assert(cash == 1950 and xp == 300 and bonuses == 1)
assert(p.count == 12 and E.new().count == 0)
print("PASS: exploration rewards, one completion bonus, invalid IDs and independent progress")
