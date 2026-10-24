local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Mission = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Mission"))
local event = ReplicatedStorage:WaitForChild("RenovationUpdate")
local pink = Color3.fromRGB(241, 103, 205)
local gui = Instance.new("ScreenGui")
gui.Name = "RenovationHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local function panel(name, size, position, anchor)
	local frame = Instance.new("Frame", gui)
	frame.Name, frame.Size, frame.Position = name, size, position
	frame.AnchorPoint = anchor or Vector2.zero
	frame.BackgroundColor3 = Color3.fromRGB(19, 20, 30)
	frame.BackgroundTransparency = 0.12
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
	local border = Instance.new("UIStroke", frame)
	border.Color, border.Transparency = Color3.fromRGB(128, 114, 143), 0.5
	return frame
end
local function label(parent, text, pos, size, color)
	local l = Instance.new("TextLabel", parent)
	l.Position, l.Size = pos, size
	l.BackgroundTransparency = 1
	l.Text, l.TextColor3 = text, color or Color3.fromRGB(243, 241, 247)
	l.Font, l.TextSize = Enum.Font.GothamMedium, 16
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	return l
end
local profile = panel("Perfil", UDim2.fromOffset(280, 88), UDim2.fromOffset(18, 18))
label(profile, player.DisplayName, UDim2.fromOffset(16, 8), UDim2.fromOffset(250, 28))
local xp = label(profile, "", UDim2.fromOffset(16, 38), UDim2.fromOffset(250, 32), pink)
local wallet = panel("Carteira", UDim2.fromOffset(180, 55), UDim2.new(1, -18, 0, 18), Vector2.new(1, 0))
local cash = label(wallet, "", UDim2.fromOffset(14, 4), UDim2.fromOffset(155, 45), Color3.fromRGB(78, 225, 158))
local mission = panel("Missão", UDim2.fromOffset(280, 172), UDim2.fromOffset(18, 120))
label(mission, "REFORMAR CASA #1", UDim2.fromOffset(16, 10), UDim2.fromOffset(250, 30), pink)
local rows = {}
for i, stage in Mission.stages do
	rows[i] = label(mission, stage.title, UDim2.fromOffset(16, 42 + (i - 1) * 36), UDim2.fromOffset(250, 34))
end
local toolbar = panel("Ferramentas", UDim2.fromOffset(318, 76), UDim2.new(0.5, 0, 1, -18), Vector2.new(0.5, 1))
local slots = {}
for i, name in {"Saco", "Rolo", "Decoração"} do
	slots[i] = label(toolbar, i .. "  " .. name, UDim2.fromOffset(12 + (i - 1) * 102, 10), UDim2.fromOffset(96, 56))
end
local hint = label(gui, "Aproxime-se dos objetos e segure E\nNo celular, toque no botão de interação", UDim2.new(0.5, -170, 1, -152), UDim2.fromOffset(340, 58))
hint.TextXAlignment = Enum.TextXAlignment.Center
local toast = panel("Notificação", UDim2.fromOffset(330, 54), UDim2.new(0.5, 0, 0, 20), Vector2.new(0.5, 0))
toast.Visible = false
local toastText = label(toast, "", UDim2.fromOffset(12, 4), UDim2.fromOffset(306, 46), Color3.fromRGB(78, 225, 158))
local complete = panel("Conclusão", UDim2.fromOffset(340, 230), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
complete.Visible = false
label(complete, "CASA REFORMADA!", UDim2.fromOffset(22, 22), UDim2.fromOffset(300, 46), pink).TextSize = 25
label(complete, "De casa abandonada a um novo lar.\n\nRecompensa: 5.000 moedas + 300 XP", UDim2.fromOffset(22, 78), UDim2.fromOffset(296, 82))
local close = Instance.new("TextButton", complete)
close.Size, close.Position = UDim2.fromOffset(296, 40), UDim2.fromOffset(22, 172)
close.Text, close.Font, close.TextSize = "Continuar explorando", Enum.Font.GothamBold, 16
close.BackgroundColor3, close.TextColor3 = pink, Color3.new(1, 1, 1)
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 12)
close.Activated:Connect(function() complete.Visible = false end)
local inventory = panel("Inventário", UDim2.fromOffset(320, 245), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
inventory.Visible = false
label(inventory, "INVENTÁRIO", UDim2.fromOffset(20, 12), UDim2.fromOffset(280, 36), pink)
local tools = label(inventory, "", UDim2.fromOffset(20, 55), UDim2.fromOffset(280, 125))
local bag = Instance.new("TextButton", gui)
bag.Size, bag.Position = UDim2.fromOffset(140, 38), UDim2.new(1, -158, 1, -62)
bag.Text, bag.BackgroundColor3, bag.TextColor3 = "Mochila [B]", Color3.fromRGB(35, 31, 46), Color3.new(1, 1, 1)
Instance.new("UICorner", bag).CornerRadius = UDim.new(0, 10)
bag.Activated:Connect(function() inventory.Visible = not inventory.Visible end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.B then inventory.Visible = not inventory.Visible end
end)
local shownCompletion = false
local function render()
	local stage = player:GetAttribute("Stage") or 1
	local count = player:GetAttribute("Progress") or 0
	local experience = player:GetAttribute("XP") or 0
	xp.Text = "Nível " .. (1 + math.floor(experience / 300)) .. "   •   " .. experience .. " XP"
	cash.Text = "$ " .. (player:GetAttribute("Cash") or 250)
	for i, definition in Mission.stages do
		local progress = i < stage and definition.total or (i == stage and count or 0)
		rows[i].Text = (i < stage and "✓ " or "○ ") .. definition.title .. " (" .. progress .. "/" .. definition.total .. ")"
		rows[i].TextColor3 = i < stage and Color3.fromRGB(78, 225, 158) or Color3.fromRGB(243, 241, 247)
		slots[i].TextColor3 = i == stage and pink or Color3.fromRGB(148, 143, 157)
	end
	tools.Text = "Ferramentas da reforma:\n\nSaco de lixo · Rolo de pintura · Decoração\n\nAtiva: " .. (Mission.stages[stage] and Mission.stages[stage].tool or "Reforma concluída")
	if player:GetAttribute("Completed") and not shownCompletion then
		shownCompletion = true
		complete.Visible = true
	end
end
for _, name in {"Stage", "Progress", "Cash", "XP", "Completed"} do player:GetAttributeChangedSignal(name):Connect(render) end
local toastVersion = 0
event.OnClientEvent:Connect(function(message)
	render()
	if message == "" then return end
	toastVersion += 1
	local version = toastVersion
	toastText.Text, toast.Visible = message, true
	task.delay(3, function() if version == toastVersion then toast.Visible = false end end)
end)
-- Compact the side panels on smaller screens without shrinking touch prompts.
local function resize()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local compact = camera.ViewportSize.X < 850
	for _, frame in {profile, wallet, mission} do
		local scale = frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", frame)
		scale.Scale = compact and 0.7 or 1
	end
	mission.Position = UDim2.fromOffset(18, compact and 86 or 120)
	bag.Position = UDim2.new(1, -158, 0, compact and 68 or 84)
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
resize()
render()

-- Hide overhead geometry locally when inside a house, keeping the roof in the world.
local houses = workspace:WaitForChild("Neighborhood"):WaitForChild("Casas")
local roofCache = {}
local function cacheHouse(house)
	local floor = house:FindFirstChild("Piso")
	local roof = house:FindFirstChild("Telhado")
	if not floor or not roof then return end
	local parts = roof:GetChildren()
	local porch = house:FindFirstChild("Cobertura varanda")
	if porch then table.insert(parts, porch) end
	roofCache[house] = { floor = floor, parts = parts }
end
for _, house in houses:GetChildren() do cacheHouse(house) end
houses.ChildAdded:Connect(cacheHouse)
houses.ChildRemoved:Connect(function(house) roofCache[house] = nil end)
local elapsed = 0
game:GetService("RunService").Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.15 then return end
	elapsed = 0
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	for _, entry in roofCache do
		local pos = root and entry.floor.CFrame:PointToObjectSpace(root.Position)
		local inside = pos and math.abs(pos.X) < 20 and math.abs(pos.Z) < 23 and pos.Y < 15
		for _, roof in entry.parts do
			if roof:IsA("BasePart") then roof.LocalTransparencyModifier = inside and 1 or 0 end
		end
	end
end)
