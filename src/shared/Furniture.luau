-- Same native geometry powers the catalog previews and placed items.
local Catalog = require(script.Parent.Catalog)
local Furniture = {}
function Furniture.create(id, colorId, origin)
	local palette = Catalog.color(colorId) or Catalog.colors[1]
	local color = Color3.fromRGB(table.unpack(palette.rgb))
	local wood = Color3.fromRGB(143, 104, 75)
	local dark = Color3.fromRGB(49, 53, 57)
	local model = Instance.new("Model")
	model.Name = id
	local function p(name, size, position, tint, material, shape)
		local part = Instance.new("Part")
		part.Name, part.Size = name, size
		part.CFrame = origin * CFrame.new(position)
		part.Color = tint
		part.Material = material or Enum.Material.SmoothPlastic
		part.Anchored = true
		part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		if shape then part.Shape = shape end
		part.Parent = model
		return part
	end
	if id == "plant" then
		p("Vaso", Vector3.new(1.8, 1.7, 1.8), Vector3.new(0, .85, 0), color)
		p("Caule", Vector3.new(.18, 2, .18), Vector3.new(0, 2.5, 0), wood)
		for i = 1, 3 do
			p("Folhas", Vector3.new(2.1, 1.5, 2.1), Vector3.new((i - 2) * .55, 2.6 + i * .35, 0), Color3.fromRGB(68, 126, 80), Enum.Material.Grass, Enum.PartType.Ball)
		end
	elseif id == "lamp" then
		p("Base", Vector3.new(1.6, .25, 1.6), Vector3.new(0, .125, 0), dark)
		p("Haste", Vector3.new(.18, 4, .18), Vector3.new(0, 2.1, 0), wood)
		local shade = p("Cúpula", Vector3.new(2, 1.4, 2), Vector3.new(0, 4.2, 0), color, Enum.Material.Neon)
		local light = Instance.new("PointLight", shade)
		light.Color, light.Brightness, light.Range = Color3.fromRGB(255, 219, 170), 1, 15
	elseif id == "rug" then
		local rug = p("Tapete", Vector3.new(.12, 4.5, 4.5), Vector3.new(0, .08, 0), color, Enum.Material.Fabric, Enum.PartType.Cylinder)
		rug.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
		rug.CanCollide = false
	elseif id == "table" then
		p("Tampo", Vector3.new(3.2, .35, 2.6), Vector3.new(0, 2.4, 0), color)
		for _, x in {-1.2, 1.2} do for _, z in {-.9, .9} do
			p("Pé", Vector3.new(.25, 2.3, .25), Vector3.new(x, 1.15, z), wood, Enum.Material.Wood)
		end end
	elseif id == "chair" then
		p("Assento", Vector3.new(3.2, .8, 2.9), Vector3.new(0, 1.25, 0), color, Enum.Material.Fabric)
		p("Encosto", Vector3.new(3.2, 2.5, .6), Vector3.new(0, 2.3, -1.2), color, Enum.Material.Fabric)
		for _, x in {-1.5, 1.5} do
			p("Braço", Vector3.new(.45, 1.4, 3), Vector3.new(x, 1.9, 0), color, Enum.Material.Fabric)
			for _, z in {-1, 1} do p("Pé", Vector3.new(.3, .85, .3), Vector3.new(x, .425, z), wood) end
		end
	elseif id == "shelf" then
		for _, x in {-1.4, 1.4} do p("Lateral", Vector3.new(.25, 4.8, 1.3), Vector3.new(x, 2.4, 0), wood) end
		for level = 0, 3 do
			p("Prateleira", Vector3.new(3, .2, 1.4), Vector3.new(0, .15 + level * 1.5, 0), color)
			if level < 3 then for book = 1, 4 do
				p("Livro", Vector3.new(.3, .9, .8), Vector3.new(-.9 + book * .4, .7 + level * 1.5, 0), book % 2 == 0 and color or Color3.fromRGB(205, 175, 126))
			end end
		end
	end
	return model
end
return Furniture
