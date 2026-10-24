local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mission = require(ReplicatedStorage.Shared.Mission)
local Decorations = require(ReplicatedStorage.Shared.Decorations)
local Furniture = require(ReplicatedStorage.Shared.Furniture)
local WorkRules = require(ReplicatedStorage.Shared.WorkRules)
local WorkAnimation = require(script.Parent.WorkAnimation)
local ShopRules = require(ReplicatedStorage.Shared.ShopRules)
local update = Instance.new("RemoteEvent")
update.Name = "RenovationUpdate"
update.Parent = ReplicatedStorage
local shop = Instance.new("RemoteEvent")
shop.Name = "DecorationShop"
shop.Parent = ReplicatedStorage
local sessions = {}
local store = workspace:WaitForChild("Neighborhood"):WaitForChild("Loja")
local function atStore(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local position = store.Piso.CFrame:PointToObjectSpace(root.Position)
	return ShopRules.inside(position.X, position.Y, position.Z)
end
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
		if not atStore(player) then send(player, "Para comprar, visite a loja Casa & Cia no fim da rua."); return end
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
	local session = { state = state, decor = Decorations.new(), house = model, slot = slot, spawn = marker.Position, busy = false }
	sessions[player] = session
	local walls = {}
	for i = 1, 4 do walls[i] = model:FindFirstChild("Paint" .. i) end
	local prompts = {}
	local function stopWork()
		if session.work then session.work.animation.stop(); session.work = nil end
	end
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
		prompt.HoldDuration = WorkRules.duration[stage]
		prompt:SetAttribute("WorkStage", stage)
		prompt:SetAttribute("OwnerUserId", player.UserId)
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = stage == 3 and 8 or 6
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		table.insert(prompts, { prompt = prompt, stage = stage, id = id })
		prompt.PromptButtonHoldBegan:Connect(function(actor)
			if actor ~= player or session.busy then return end
			if stage == 3 then
				if state.stage < 3 then return end
			elseif state.stage ~= stage or state.used[id] then return end
			local root = actor.Character and actor.Character:FindFirstChild("HumanoidRootPart")
			if not root or (root.Position - anchor.WorldPosition).Magnitude > prompt.MaxActivationDistance + 1 then return end
			stopWork()
			local animation = WorkAnimation.start(actor, stage, anchor)
			if animation then session.work = { animation = animation, prompt = prompt, started = os.clock() } end
		end)
		prompt.PromptButtonHoldEnded:Connect(function(actor)
			if actor ~= player then return end
			local current = session.work
			task.delay(.2, function() if current and session.work == current then stopWork() end end)
		end)
		prompt.Triggered:Connect(function(actor)
			if actor ~= player or session.busy then return end
			local root = actor.Character and actor.Character:FindFirstChild("HumanoidRootPart")
			if not root or (root.Position - anchor.WorldPosition).Magnitude > prompt.MaxActivationDistance + 1 then return end
			local work = session.work
			if not work or work.prompt ~= prompt or work.animation.stopped or not WorkRules.canFinish(work.started, os.clock(), stage) then return end
			stopWork()
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
			for _, debris in trash:GetDescendants() do
				if debris:IsA("BasePart") then debris.Transparency = 1; debris.CanCollide = false end
			end
		end)
	end
	local positions = {Vector3.new(0, 1.3, 1), Vector3.new(1, 1.3, 0), Vector3.new(-1, 1.3, 0), Vector3.new(0, 1.3, -1)}
	for i, wall in walls do
		interactive(wall, 2, "wall" .. i, positions[i], function()
			wall.Color = Color3.fromRGB(218, 211, 196)
			local surfaces = model:FindFirstChild("PaintGroup" .. i)
			if surfaces then for _, surface in surfaces:GetChildren() do surface.Color = wall.Color end end
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
	player.CharacterRemoving:Connect(stopWork)
	player.CharacterAdded:Connect(spawnCharacter)
	if player.Character then task.spawn(spawnCharacter, player.Character) end
end
Players.PlayerAdded:Connect(createHouse)
for _, player in Players:GetPlayers() do task.spawn(createHouse, player) end
Players.PlayerRemoving:Connect(function(player)
	local session = sessions[player]
	if session then
		if session.work then session.work.animation.stop() end
		session.house:Destroy()
		local replacement = originals[session.slot]:Clone()
		replacement.Parent = lots
		available[session.slot] = replacement
		sessions[player] = nil
	end
end)

local counterPrompt = Instance.new("ProximityPrompt", store.Balcao)
counterPrompt.ActionText, counterPrompt.ObjectText = "Ver móveis e decorações", "Casa & Cia · Loja de decoração"
counterPrompt.HoldDuration, counterPrompt.MaxActivationDistance = .3, 10
counterPrompt.RequiresLineOfSight = false
counterPrompt.Triggered:Connect(function(player)
	if sessions[player] and atStore(player) then shop:FireClient(player, "Open") end
end)
