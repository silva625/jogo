local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mission = require(ReplicatedStorage.Shared.Mission)
local Decorations = require(ReplicatedStorage.Shared.Decorations)
local Furniture = require(ReplicatedStorage.Shared.Furniture)
local Exploration = require(ReplicatedStorage.Shared.Exploration)
local update = Instance.new("RemoteEvent")
update.Name = "RenovationUpdate"
update.Parent = ReplicatedStorage
local shop = Instance.new("RemoteEvent")
shop.Name = "DecorationShop"
shop.Parent = ReplicatedStorage
local sessions = {}
local lots = workspace:WaitForChild("Neighborhood"):WaitForChild("Casas")
local available = {}
local originals = {}
for i = 1, 8 do
	local house = lots:WaitForChild("Casa" .. i)
	available[i] = house
	originals[i] = house:Clone()
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
	player:SetAttribute("CrystalCount", session.exploration.count)
	update:FireClient(player, message or "", session.decor)
end
shop.OnServerEvent:Connect(function(player, action, id, color)
	local session = sessions[player]
	if not session or type(action) ~= "string" then return end
	local now = os.clock()
	if now - (session.lastShop or 0) < .15 then return end
	session.lastShop = now
	local message = ""
	if action == "Buy" and type(id) == "string" then
		local _, result = Decorations.buy(session.state, session.decor, id)
		message = result
	elseif action == "Select" and type(id) == "string" and type(color) == "string" then
		local _, result = Decorations.select(session.decor, id, color)
		message = result
	elseif action ~= "Sync" then return end
	send(player, message)
end)
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
	local session = { state = state, decor = Decorations.new(), exploration = Exploration.new(), house = model, slot = slot, spawn = marker.Position, busy = false }
	sessions[player] = session
	local walls = {}
	for i = 1, 4 do walls[i] = model:FindFirstChild("Paint" .. i) end
	local prompts = {}
	local function refresh()
		for _, item in prompts do
			item.prompt.Enabled = if item.stage == 3 then state.stage >= 3 else not state.completed and item.stage == state.stage and not state.used[item.id]
		end
	end
	local function interactive(target, stage, id, position, onDone, decorSlot)
		local anchor = Instance.new("Attachment", target)
		anchor.Position = position or Vector3.zero
		local prompt = Instance.new("ProximityPrompt", anchor)
		prompt.ActionText = stage == 3 and "Colocar / trocar decoração" or Mission.stages[stage].action
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
			if decorSlot then
				local ok, message = Decorations.place(state, session.decor, decorSlot)
				if ok then
					onDone()
					local wasCompleted = state.completed
					local rewarded = Mission.apply(state, stage, id)
					if not wasCompleted and state.completed then message = "Casa reformada! +5.000 e +300 XP"
					elseif rewarded then message ..= " +25 moedas · +20 XP" end
					refresh()
				end
				send(player, message)
				session.busy = false
				return
			end
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
			local existing = model:FindFirstChild("Furniture" .. i)
			if existing then existing:Destroy() end
			local chosen = session.decor.slots[i]
			local floor = model.Piso
			local base = CFrame.new(decoration.Position.X, floor.Position.Y + floor.Size.Y / 2 + .02, decoration.Position.Z) * floor.CFrame.Rotation
			local furnishing = Furniture.create(chosen.id, chosen.color, base)
			furnishing.Name, furnishing.Parent = "Furniture" .. i, model
			decoration.Transparency = .88
		end, i)
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

local surreal = workspace.Neighborhood:WaitForChild("Surreal")
local function nearby(player, target)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	return root and (root.Position - target.Position).Magnitude <= 12
end
for id = 1, Exploration.total do
	local crystal = surreal.Cristais:FindFirstChild("Crystal" .. id)
	local prompt = Instance.new("ProximityPrompt", crystal)
	prompt.ActionText, prompt.ObjectText = "Coletar cristal", "Fragmento de sonho · +100 moedas"
	prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = .4, 9, false
	prompt.Triggered:Connect(function(player)
		local session = sessions[player]
		if not session or not nearby(player, crystal) then return end
		local ok, cash, xp, complete = Exploration.claim(session.exploration, id)
		if not ok then return end
		session.state.cash += cash
		session.state.xp += xp
		player:SetAttribute("Crystal" .. id, true)
		if complete then session.decor.inventory.galaxy = (session.decor.inventory.galaxy or 0) + 1 end
		send(player, complete and "12/12! +750 bônus e Aquário de galáxia na mochila!" or "Cristal encontrado! +100 moedas · +25 XP")
	end)
end
for _, route in {
	{ name = "PortalOut", title = "Observatório dos Sonhos", destination = Vector3.new(135, 31, -149), look = Vector3.new(135, 31, -182) },
	{ name = "PortalReturn", title = "Voltar ao bairro", destination = Vector3.new(300, 4, 52), look = Vector3.new(255, 4, 52) },
} do
	local portal = surreal:FindFirstChild(route.name)
	local prompt = Instance.new("ProximityPrompt", portal)
	prompt.ActionText, prompt.ObjectText = "Atravessar portal", route.title
	prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 1, 10, false
	prompt.Triggered:Connect(function(player)
		local session = sessions[player]
		if not session or not nearby(player, portal) then return end
		local now = os.clock()
		if now - (session.lastPortal or -10) < 2 then return end
		session.lastPortal = now
		player.Character:PivotTo(CFrame.lookAt(route.destination, route.look))
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then root.AssemblyLinearVelocity = Vector3.zero end
		send(player, route.title)
	end)
end
