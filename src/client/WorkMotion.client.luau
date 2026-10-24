-- Animator evaluates between PreAnimation and PreSimulation. Compose our local
-- action after it, and restore that offset before the following animation step.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Motion = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("WorkMotion"))
local characters, bindings = {}, {}
local names = {
	RightShoulder = "right", ["Right Shoulder"] = "right", RightElbow = "elbow",
	Waist = "waist", LeftShoulder = "left", ["Left Shoulder"] = "left",
}
local function restore(state)
	for motor, base in state.applied do if motor.Parent then motor.Transform = base end end
	table.clear(state.applied)
end
local function remove(character)
	local state = characters[character]
	if not state then return end
	restore(state)
	state.connection:Disconnect()
	characters[character] = nil
end
local function add(character)
	if characters[character] then return end
	local state = { motors = {}, applied = {}, weight = 0, stage = 1, started = 0 }
	local function joint(descendant)
		if descendant:IsA("Motor6D") and names[descendant.Name] then state.motors[descendant] = names[descendant.Name] end
	end
	state.connection = character.DescendantAdded:Connect(joint)
	characters[character] = state
	for _, descendant in character:GetDescendants() do joint(descendant) end
end
local function watch(player)
	bindings[player] = { player.CharacterAdded:Connect(add), player.CharacterRemoving:Connect(remove) }
	if player.Character then add(player.Character) end
end
for _, player in Players:GetPlayers() do watch(player) end
Players.PlayerAdded:Connect(watch)
Players.PlayerRemoving:Connect(function(player)
	if player.Character then remove(player.Character) end
	for _, connection in bindings[player] or {} do connection:Disconnect() end
	bindings[player] = nil
end)
RunService.PreAnimation:Connect(function()
	for _, state in characters do restore(state) end
end)
RunService.PreSimulation:Connect(function(dt)
	local now = workspace:GetServerTimeNow()
	for character, state in characters do
		local stage = character:GetAttribute("WorkStage")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local active = stage ~= nil and humanoid and humanoid.Health > 0
		if active then state.stage, state.started = stage, character:GetAttribute("WorkStarted") or now end
		state.weight += ((active and 1 or 0) - state.weight) * Motion.alpha(dt)
		if state.weight < .001 then state.weight = 0; continue end
		local pose = Motion.sample(state.stage, now - state.started)
		for motor, kind in state.motors do
			if not motor.Parent then state.motors[motor] = nil; continue end
			local x, z = 0, 0
			if kind == "right" then x, z = pose.shoulder, pose.side
			elseif kind == "elbow" then x = pose.elbow
			elseif kind == "waist" then x = pose.waist
			elseif kind == "left" then x = pose.left end
			local base = motor.Transform
			state.applied[motor] = base
			local axes = motor.C0.Rotation
			motor.Transform = base * axes:Inverse() * CFrame.Angles(math.rad(x * state.weight), 0, math.rad(z * state.weight)) * axes
		end
	end
end)
