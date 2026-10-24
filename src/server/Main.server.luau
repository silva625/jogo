local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mission = require(ReplicatedStorage.Shared.Mission)
local update = Instance.new("RemoteEvent")
update.Name = "RenovationUpdate"
update.Parent = ReplicatedStorage
local sessions = {}
local lots = workspace:WaitForChild("Neighborhood"):WaitForChild("Casas")
local available = {}
local originals = {}
for i = 1, 8 do
	local house = lots:WaitForChild("Casa" .. i)
	available[i] = house
	originals[i] = house:Clone()
end

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
	local slot, model
	for i = 1, 8 do
		if available[i] then slot, model = i, available[i]; break end
	end
	if not model then
		player:Kick("O bairro está cheio. Entre em outro servidor para ter sua casa.")
		return
	end
	available[slot] = nil
	model.Name = "Casa de " .. player.Name
	local state = Mission.new()
	local marker = model:FindFirstChild("SpawnMarker")
	local session = { state = state, house = model, slot = slot, spawn = marker.Position, busy = false }
	sessions[player] = session
	local walls = {}
	for i = 1, 4 do walls[i] = model:FindFirstChild("Paint" .. i) end
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
		local trash = model:FindFirstChild("Trash" .. i)
		interactive(trash, 1, "trash" .. i, nil, function()
			trash.Transparency = 1
			trash.CanCollide = false
		end)
	end
	local positions = {Vector3.new(0, -2, 1), Vector3.new(1, -2, 0), Vector3.new(-1, -2, 0), Vector3.new(0, -2, -1)}
	for i, wall in walls do
		interactive(wall, 2, "wall" .. i, positions[i], function()
			wall.Color = Color3.fromRGB(219, 192, 210)
		end)
	end
	for i = 1, 3 do
		local decoration = model:FindFirstChild("Decor" .. i)
		interactive(decoration, 3, "decor" .. i, nil, function()
			decoration.Transparency, decoration.CanCollide = 0, true
			decoration.Material = Enum.Material.Wood
			decoration.Color = Color3.fromRGB(150, 112, 84)
			local leaves = part(model, "Folhagem", Vector3.new(3.6, 2.8, 3.6), decoration.Position + Vector3.new(0, 2.2, 0), Color3.fromRGB(71, 124, 83), Enum.Material.Grass)
			leaves.Shape = Enum.PartType.Ball
		end)
	end
	refresh()
	send(player)
	local function spawnCharacter(character)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root and sessions[player] == session then
			character:PivotTo(CFrame.lookAt(session.spawn, model.Piso.Position + Vector3.new(0, 3, 0)))
		end
	end
	player.CharacterAdded:Connect(spawnCharacter)
	if player.Character then task.spawn(spawnCharacter, player.Character) end
end
Players.PlayerAdded:Connect(createHouse)
for _, player in Players:GetPlayers() do task.spawn(createHouse, player) end
Players.PlayerRemoving:Connect(function(player)
	local session = sessions[player]
	if session then
		session.house:Destroy()
		local replacement = originals[session.slot]:Clone()
		replacement.Parent = lots
		available[session.slot] = replacement
		sessions[player] = nil
	end
end)
