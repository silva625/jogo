-- Server owns tools and action state; clients render joint motion every frame.
local WorkAnimation = {}
function WorkAnimation.start(player, stage, target)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local hand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
	if not humanoid or humanoid.Health <= 0 or not hand then return nil end
	local handle = { stopped = false, connections = {} }
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
	character:SetAttribute("WorkStarted", workspace:GetServerTimeNow())
	character:SetAttribute("WorkStage", stage)
	function handle.stop()
		if handle.stopped then return end
		handle.stopped = true
		for _, connection in handle.connections do connection:Disconnect() end
		character:SetAttribute("WorkStage", nil)
		character:SetAttribute("WorkStarted", nil)
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
