-- Native terrain supplies grass detail and smooth hills during Play. The static
-- ground remains in the place so the entire map is still visible in the editor.
local terrain = workspace.Terrain
local landscape = workspace:WaitForChild("Neighborhood"):WaitForChild("Paisagismo")
terrain.Decoration = true
terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(91, 117, 70))
terrain:SetMaterialColor(Enum.Material.LeafyGrass, Color3.fromRGB(82, 107, 63))
terrain:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(118, 101, 78))
local ground = landscape:WaitForChild("Terreno")
terrain:FillBlock(ground.CFrame, ground.Size, Enum.Material.Grass)
ground.Transparency, ground.CanCollide, ground.CanQuery = 1, false, false
for _, hill in landscape:GetChildren() do
	if hill.Name == "Colina distante" then
		terrain:FillBall(hill.Position - Vector3.new(0, 8, 0), math.max(17, hill.Size.Y / 2 + 5), Enum.Material.Grass)
		hill.Transparency, hill.CanCollide, hill.CanQuery = 1, false, false
	end
end
