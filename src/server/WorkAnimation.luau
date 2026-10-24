-- Procedural work gestures. No uploaded animation IDs or asset permissions needed.
-- Animate C0 on the server so observers also see the working character.
local TweenService = game:GetService("TweenService")
local WorkAnimation = {}
function WorkAnimation.start(player, stage, target)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local hand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
	if not humanoid or humanoid.Health <= 0 or not hand then return nil end
	local handle = { stopped = false, joints = {}, tweens = {}, connections = {} }
	local speed = humanoid.WalkSpeed
	local autoRotate = humanoid.AutoRotate
	humanoid.WalkSpeed = math.min(speed, 5)
	humanoid.AutoRotate = false
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		local facing = Vector3.new(target.WorldPosition.X, root.Position.Y, target.WorldPosition.Z)
		if (facing - root.Position).Magnitude > .1 then root.CFrame = CFrame.lookAt(root.Position, facing) end
	end
	player:SetAttribute("WorkAction", stage)
	local tool = Instance.new("Model", character)
	tool.Name = "FerramentaDeTrabalho"
	local function piece(name, size, offset, color, material, cylinder)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Color = name, size, color
		p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.CanCollide, p.CanTouch, p.CanQuery, p.Massless = false, false, false, true
		p.CFrame = hand.CFrame * offset
		if cylinder then p.Shape = Enum.PartType.Cylinder end
		p.Parent = tool
		local weld = Instance.new("WeldConstraint", p)
		weld.Part0, weld.Part1 = hand, p
		return p
	end
	local wood = Color3.fromRGB(153, 112, 72)
	if stage == 1 then
		piece("Cabo da vassoura", Vector3.new(.13, 2.7, .13), CFrame.new(0, -.4, -.15), wood, Enum.Material.Wood)
		piece("Base da vassoura", Vector3.new(1.3, .18, .45), CFrame.new(0, -1.8, -.15), Color3.fromRGB(94, 107, 97))
		for i = 1, 7 do piece("Cerdas", Vector3.new(.12, .35, .4), CFrame.new(-.6 + i * .15, -2.05, -.15), Color3.fromRGB(189, 158, 105)) end
	elseif stage == 2 then
		piece("Cabo do rolo", Vector3.new(.18, .85, .18), CFrame.new(0, -.25, -.25), Color3.fromRGB(57, 100, 127))
		piece("Haste", Vector3.new(.08, .7, .08), CFrame.new(0, .5, -.25), Color3.fromRGB(153, 157, 160), Enum.Material.Metal)
		piece("Rolo de pintura", Vector3.new(1.4, .5, .5), CFrame.new(.5, .9, -.25), Color3.fromRGB(224, 219, 208), Enum.Material.Fabric, true)
	else
		piece("Caixa de decoração", Vector3.new(1.5, 1.2, 1.3), CFrame.new(0, -.2, -.65), Color3.fromRGB(174, 137, 96), Enum.Material.Wood)
		piece("Fita da caixa", Vector3.new(.2, .03, 1.32), CFrame.new(0, .42, -.65), Color3.fromRGB(215, 193, 152))
	end
	local function pose(motor, x, y, z, sway)
		local base = motor.C0
		table.insert(handle.joints, { motor = motor, base = base })
		local function rotation(ax, az)
			return CFrame.new(base.Position) * CFrame.Angles(math.rad(ax), math.rad(y), math.rad(az)) * base.Rotation
		end
		motor.C0 = rotation(x, z)
		local tween = TweenService:Create(motor, TweenInfo.new(stage == 1 and .3 or .45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { C0 = rotation(x + sway, z + sway * .35) })
		tween:Play()
		table.insert(handle.tweens, tween)
	end
	for _, motor in character:GetDescendants() do
		if motor:IsA("Motor6D") then
			if motor.Name == "RightShoulder" or motor.Name == "Right Shoulder" then
				pose(motor, stage == 2 and 80 or 30, 0, stage == 1 and 12 or -10, stage == 1 and 20 or 23)
			elseif motor.Name == "RightElbow" then pose(motor, 25, 0, 0, 20)
			elseif motor.Name == "Waist" then pose(motor, stage == 1 and -16 or -4, 0, 0, 4)
			elseif (motor.Name == "LeftShoulder" or motor.Name == "Left Shoulder") and stage == 3 then pose(motor, 45, 0, 15, 8) end
		end
	end
	function handle.stop()
		if handle.stopped then return end
		handle.stopped = true
		for _, tween in handle.tweens do tween:Cancel() end
		for _, saved in handle.joints do if saved.motor.Parent then saved.motor.C0 = saved.base end end
		for _, connection in handle.connections do connection:Disconnect() end
		if humanoid.Parent then humanoid.WalkSpeed = speed; humanoid.AutoRotate = autoRotate end
		player:SetAttribute("WorkAction", nil)
		tool:Destroy()
	end
	table.insert(handle.connections, humanoid.Died:Connect(handle.stop))
	task.spawn(function()
		local start = os.clock()
		while not handle.stopped do
			local root = character:FindFirstChild("HumanoidRootPart")
			if not target.Parent or not root or (root.Position - target.WorldPosition).Magnitude > 11 or os.clock() - start > 8 then handle.stop(); return end
			task.wait(.15)
		end
	end)
	return handle
end
return WorkAnimation
