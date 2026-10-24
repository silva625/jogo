local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mission = require(ReplicatedStorage.Shared.Mission)
local update = Instance.new("RemoteEvent")
update.Name = "RenovationUpdate"
update.Parent = ReplicatedStorage
local sessions = {}
local lots = Instance.new("Folder", workspace)
lots.Name = "Casas"
local nextLot = 0

local function part(parent, name, size, position, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.Position = name, size, position
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function send(player, message)
	local session = sessions[player]
	if not session then return end
	local s = session.state
	player:SetAttribute("Cash", s.cash)
	player:SetAttribute("XP", s.xp)
	player:SetAttribute("Stage", s.stage)
	player:SetAttribute("Progress", s.count)
	player:SetAttribute("Completed", s.completed)
	update:FireClient(player, message or "")
end
local function createHouse(player)
	nextLot += 1
	local offset = Vector3.new((nextLot - 1) * 90, 0, 0)
	local model = Instance.new("Model", lots)
	model.Name = "Casa de " .. player.Name
	local state = Mission.new()
	local session = { state = state, house = model, spawn = offset + Vector3.new(0, 4, 23), busy = false }
	sessions[player] = session
	local function make(name, size, pos, color, material)
		return part(model, name, size, offset + pos, color, material)
	end
	make("Jardim", Vector3.new(65, 1, 65), Vector3.new(0, -1, 0), Color3.fromRGB(82, 117, 79), Enum.Material.Grass)
	make("Caminho", Vector3.new(7, 0.2, 15), Vector3.new(0, -0.35, 22), Color3.fromRGB(158, 149, 142), Enum.Material.Cobblestone)
	make("Piso", Vector3.new(30, 1, 26), Vector3.zero, Color3.fromRGB(114, 84, 66), Enum.Material.WoodPlanks)
	-- Open roof lets the camera see the interior; a doorway opens onto the garden.
	local dirty = Color3.fromRGB(117, 106, 91)
	local walls = {
		make("Parede traseira", Vector3.new(30, 11, 0.6), Vector3.new(0, 6, -13), dirty, Enum.Material.Concrete),
		make("Parede esquerda", Vector3.new(0.6, 11, 26), Vector3.new(-15, 6, 0), dirty, Enum.Material.Concrete),
		make("Parede direita", Vector3.new(0.6, 11, 26), Vector3.new(15, 6, 0), dirty, Enum.Material.Concrete),
		make("Fachada", Vector3.new(11, 11, 0.6), Vector3.new(-9.5, 6, 13), dirty, Enum.Material.Concrete),
	}
	make("Fachada direita", Vector3.new(11, 11, 0.6), Vector3.new(9.5, 6, 13), Color3.fromRGB(210, 204, 192))
	make("Viga da entrada", Vector3.new(8, 3, 0.6), Vector3.new(0, 10, 13), Color3.fromRGB(210, 204, 192))
	for _, x in {-9, 9} do
		local window = make("Janela", Vector3.new(5, 5, 0.2), Vector3.new(x, 6.5, -12.6), Color3.fromRGB(162, 207, 220), Enum.Material.Glass)
		window.Transparency = 0.25
	end
	local sign = make("Placa", Vector3.new(10, 2, 0.4), Vector3.new(0, 11, 13.4), Color3.fromRGB(31, 28, 40))
	local surface = Instance.new("SurfaceGui", sign)
	surface.Face = Enum.NormalId.Back
	local title = Instance.new("TextLabel", surface)
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Text, title.TextScaled = "DE CASA EM CASA", true
	title.TextColor3 = Color3.fromRGB(245, 144, 221)
	title.Font = Enum.Font.GothamBold
	local prompts = {}
	local function refresh()
		for _, item in prompts do
			item.prompt.Enabled = not state.completed and item.stage == state.stage and not state.used[item.id]
		end
	end
	local function interactive(target, stage, id, position, onDone)
		local anchor = Instance.new("Attachment", target)
		anchor.Position = position or Vector3.zero
		local prompt = Instance.new("ProximityPrompt", anchor)
		prompt.ActionText = Mission.stages[stage].action
		prompt.ObjectText = Mission.stages[stage].title
		prompt.HoldDuration = stage == 1 and 0.5 or 1.2
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 10
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		table.insert(prompts, { prompt = prompt, stage = stage, id = id })
		prompt.Triggered:Connect(function(actor)
			if actor ~= player or session.busy then return end
			local root = actor.Character and actor.Character:FindFirstChild("HumanoidRootPart")
			if not root or (root.Position - anchor.WorldPosition).Magnitude > 12 then return end
			session.busy = true
			if Mission.apply(state, stage, id) then
				onDone()
				refresh()
				send(player, state.completed and "Casa reformada! +5.000 e +300 XP" or "+25 moedas · +20 XP")
			end
			session.busy = false
		end)
	end
	for i = 1, 8 do
		local x = ((i - 1) % 4) * 6 - 9
		local z = math.floor((i - 1) / 4) * 9 - 5
		local trash = make("Lixo " .. i, Vector3.new(2, 1.6, 2), Vector3.new(x, 1.3, z), Color3.fromRGB(66, 61, 59), Enum.Material.Slate)
		trash.Orientation = Vector3.new(0, i * 27, 0)
		interactive(trash, 1, "trash" .. i, nil, function() trash.Transparency = 1; trash.CanCollide = false end)
	end
	local positions = {Vector3.new(0, -3, 0.8), Vector3.new(0.8, -3, 0), Vector3.new(-0.8, -3, 0), Vector3.new(0, -3, -0.8)}
	for i, wall in walls do
		interactive(wall, 2, "wall" .. i, positions[i], function() wall.Color = Color3.fromRGB(219, 192, 210) end)
	end
	for i, position in {Vector3.new(-9, 2, -8), Vector3.new(9, 2, -8), Vector3.new(9, 2, 7)} do
		local item = make("Decoração " .. i, Vector3.new(3, 3, 3), position, Color3.fromRGB(231, 137, 212))
		item.Transparency, item.CanCollide = 0.7, false
		interactive(item, 3, "decor" .. i, nil, function()
			item.Transparency, item.CanCollide = 0, true
			item.Material = Enum.Material.Wood
			item.Color = Color3.fromRGB(105, 151, 119)
			make("Folhagem", Vector3.new(3.6, 2, 3.6), position + Vector3.new(0, 2.2, 0), Color3.fromRGB(71, 124, 83), Enum.Material.Grass).Shape = Enum.PartType.Ball
		end)
	end
	refresh()
	send(player)
	local function spawnCharacter(character)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root then character:PivotTo(CFrame.new(session.spawn)) end
	end
	player.CharacterAdded:Connect(spawnCharacter)
	if player.Character then task.spawn(spawnCharacter, player.Character) end
end
Players.PlayerAdded:Connect(createHouse)
for _, player in Players:GetPlayers() do task.spawn(createHouse, player) end
Players.PlayerRemoving:Connect(function(player)
	local session = sessions[player]
	if session then session.house:Destroy(); sessions[player] = nil end
end)
