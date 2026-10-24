local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local surreal = workspace:WaitForChild("Neighborhood"):WaitForChild("Surreal")
for index, orb in surreal:GetChildren() do
	if orb.Name == "OrbeFlutuante" then
		TweenService:Create(orb, TweenInfo.new(2.5 + (index % 3), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = orb.Position + Vector3.new(0, 2, 0) }):Play()
	end
end
for id = 1, 12 do
	local crystal = surreal:WaitForChild("Cristais"):WaitForChild("Crystal" .. id)
	local function refresh()
		local collected = player:GetAttribute("Crystal" .. id) == true
		crystal.LocalTransparencyModifier = collected and .92 or 0
		local prompt = crystal:FindFirstChildOfClass("ProximityPrompt")
		if prompt then prompt.Enabled = not collected end
	end
	player:GetAttributeChangedSignal("Crystal" .. id):Connect(refresh)
	crystal.ChildAdded:Connect(refresh)
	refresh()
end
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name, gui.ResetOnSpawn = "ExplorationHUD", false
local card = Instance.new("TextLabel", gui)
card.Position, card.Size = UDim2.new(0, 18, 1, -92), UDim2.fromOffset(260, 66)
card.BackgroundColor3, card.BackgroundTransparency = Color3.fromRGB(30, 26, 48), .1
card.Font, card.TextSize, card.TextColor3 = Enum.Font.GothamMedium, 14, Color3.fromRGB(172, 227, 255)
card.TextWrapped = true
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
local function progress()
	card.Text = "FRAGMENTOS DE SONHO  " .. (player:GetAttribute("CrystalCount") or 0) .. "/12\nComplete e ganhe um Aquário de galáxia"
end
player:GetAttributeChangedSignal("CrystalCount"):Connect(progress)
local function resize()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local small = camera.ViewportSize.X < 850
	card.Position = small and UDim2.fromOffset(18, 218) or UDim2.new(0, 18, 1, -92)
	local scale = card:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", card)
	scale.Scale = small and .7 or 1
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
resize()
progress()
