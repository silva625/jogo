local ShopRules = {}
-- Local coordinates relative to the physical shop floor; also used by the UI.
function ShopRules.inside(x, y, z)
	return math.abs(x) <= 26 and y >= 0 and y <= 12 and math.abs(z) <= 18
end
return ShopRules
