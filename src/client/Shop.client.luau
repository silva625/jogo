local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Shared")
local Catalog = require(shared:WaitForChild("Catalog"))
local Furniture = require(shared:WaitForChild("Furniture"))
local remote = ReplicatedStorage:WaitForChild("DecorationShop")
local update = ReplicatedStorage:WaitForChild("RenovationUpdate")
local pink = Color3.fromRGB(241, 103, 205)
local white = Color3.fromRGB(242, 240, 247)
local snapshot = { inventory = {}, slots = {}, selected = "plant", color = "sage" }
local colorId, category, ownedOnly = "sage", "Todos", false
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "DecorShop", false, 5
local window = Instance.new("Frame", gui)
window.Name, window.Size, window.Position = "Window", UDim2.fromOffset(700, 540), UDim2.fromScale(.5, .5)
window.AnchorPoint, window.BackgroundColor3, window.Visible = Vector2.new(.5, .5), Color3.fromRGB(20, 22, 32), false
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 18)
local scale = Instance.new("UIScale", window)
local function text(parent, value, x, y, w, h, size, color)
	local label = Instance.new("TextLabel", parent)
	label.BackgroundTransparency = 1
	label.Position, label.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
	label.Text, label.TextSize, label.TextColor3 = value, size or 14, color or white
	label.Font, label.TextXAlignment, label.TextWrapped = Enum.Font.GothamMedium, Enum.TextXAlignment.Left, true
	return label
end
local function button(parent, value, x, y, w, h, callback)
	local b = Instance.new("TextButton", parent)
	b.Position, b.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
	b.Text, b.TextColor3, b.TextSize, b.Font = value, white, 13, Enum.Font.GothamBold
	b.BackgroundColor3 = Color3.fromRGB(51, 44, 65)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
	b.Activated:Connect(callback)
	return b
end
text(window, "LOJA & DECORAÇÃO", 22, 12, 420, 34, 23, pink)
local balance = text(window, "", 460, 14, 172, 30, 17, Color3.fromRGB(80, 224, 162))
button(window, "X", 648, 14, 32, 32, function() window.Visible = false end)
local feedback = text(window, "Escolha seu estilo. Compre, selecione e coloque nos pontos rosa da casa.", 22, 49, 655, 32)
local mode = button(window, "Ver: catálogo", 22, 87, 158, 30, function() end)
local chosen = text(window, "", 192, 86, 480, 32, 13, pink)
text(window, "Cor:", 22, 125, 48, 30)
local colorButtons = {}
local render
for i, color in Catalog.colors do
	local b = button(window, color.name, 70 + (i - 1) * 114, 125, 106, 30, function()
		colorId = color.id
		render()
	end)
	b.BackgroundColor3 = Color3.fromRGB(table.unpack(color.rgb))
	b.TextColor3 = Color3.fromRGB(24, 27, 34)
	colorButtons[color.id] = b
end
local filters = {}
for i, name in {"Todos", "Móveis", "Plantas", "Luzes", "Tapetes"} do
	filters[name] = button(window, name, 22 + (i - 1) * 131, 166, 123, 28, function()
		category = name
		render()
	end)
end
local list = Instance.new("ScrollingFrame", window)
list.Position, list.Size = UDim2.fromOffset(22, 206), UDim2.fromOffset(656, 262)
list.BackgroundTransparency, list.BorderSizePixel, list.ScrollBarThickness = 1, 0, 5
list.AutomaticCanvasSize, list.CanvasSize = Enum.AutomaticSize.Y, UDim2.new()
local grid = Instance.new("UIGridLayout", list)
grid.CellSize, grid.CellPadding = UDim2.fromOffset(320, 126), UDim2.fromOffset(10, 10)
grid.SortOrder = Enum.SortOrder.LayoutOrder
local footer = text(window, "3 plantas de presente! Colocação liberada após limpar e pintar.\nTrocar um móvel devolve o anterior à mochila. Progresso válido nesta sessão.", 22, 480, 656, 46, 13, Color3.fromRGB(181, 176, 193))
local function preview(parent, id)
	local viewport = Instance.new("ViewportFrame", parent)
	viewport.Position, viewport.Size = UDim2.fromOffset(8, 12), UDim2.fromOffset(86, 102)
	viewport.BackgroundColor3 = Color3.fromRGB(43, 46, 58)
	Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 10)
	viewport.Ambient, viewport.LightColor = Color3.fromRGB(190, 190, 200), Color3.fromRGB(255, 238, 220)
	local world = Instance.new("WorldModel", viewport)
	local furniture = Furniture.create(id, colorId, CFrame.new())
	furniture.Parent = world
	local cf, size = furniture:GetBoundingBox()
	local camera = Instance.new("Camera", viewport)
	camera.FieldOfView = 38
	local distance = math.max(size.X, size.Y, size.Z) * 2
	camera.CFrame = CFrame.lookAt(cf.Position + Vector3.new(distance * .7, distance * .45, distance), cf.Position)
	viewport.CurrentCamera = camera
end
render = function()
	balance.Text = "$ " .. (player:GetAttribute("Cash") or 250)
	local selection = Catalog.find(snapshot.selected)
	chosen.Text = "Ativo: " .. (selection and selection.name or "Planta") .. " · " .. (Catalog.color(snapshot.color) or Catalog.colors[1]).name
	mode.Text = ownedOnly and "Ver: minha mochila" or "Ver: catálogo"
	for name, b in filters do b.BackgroundColor3 = name == category and Color3.fromRGB(137, 61, 124) or Color3.fromRGB(51, 44, 65) end
	for id, b in colorButtons do b.Text = (id == colorId and "✓ " or "") .. Catalog.color(id).name end
	for _, child in list:GetChildren() do if child:IsA("Frame") then child:Destroy() end end
	local visible = 0
	for index, item in Catalog.items do
		local count = snapshot.inventory[item.id] or 0
		local placed = 0
		for _, slot in snapshot.slots do if slot.id == item.id then placed += 1 end end
		if category ~= "Todos" and category ~= item.category then continue end
		if ownedOnly and count == 0 and placed == 0 then continue end
		visible += 1
		local card = Instance.new("Frame", list)
		card.LayoutOrder, card.BackgroundColor3 = index, Color3.fromRGB(30, 33, 46)
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
		preview(card, item.id)
		text(card, item.name, 104, 8, 208, 31, 14)
		text(card, item.category .. " · $ " .. item.price, 104, 39, 208, 20, 13, pink)
		text(card, "Mochila: " .. count .. " · Na casa: " .. placed, 104, 62, 208, 20, 12)
		local buy = button(card, "Comprar", 104, 89, 96, 28, function() remote:FireServer("Buy", item.id) end)
		buy.BackgroundColor3 = (player:GetAttribute("Cash") or 0) >= item.price and Color3.fromRGB(49, 104, 86) or Color3.fromRGB(63, 62, 69)
		local selectButton = button(card, "Escolher", 208, 89, 103, 28, function() remote:FireServer("Select", item.id, colorId) end)
		selectButton.BackgroundColor3 = snapshot.selected == item.id and Color3.fromRGB(137, 61, 124) or Color3.fromRGB(51, 44, 65)
	end
	footer.Text = visible == 0 and "Nenhum item neste filtro. Abra o catálogo ou escolha outra categoria." or "3 plantas de presente! Após limpar e pintar, segure E nos pontos rosa.\nTrocas devolvem o móvel anterior à mochila. Itens e moedas duram esta sessão."
end
mode.Activated:Connect(function() ownedOnly = not ownedOnly; render() end)
local open = button(gui, "Loja [L]", 0, 0, 140, 38, function() window.Visible = not window.Visible end)
open.Position = UDim2.new(1, -158, 0, 128)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.L then window.Visible = not window.Visible end
end)
update.OnClientEvent:Connect(function(message, decor)
	if decor then snapshot = decor; render() end
	if message and message ~= "" then feedback.Text = message end
end)
player:GetAttributeChangedSignal("Cash"):Connect(function() if window.Visible then render() end end)
window:GetPropertyChangedSignal("Visible"):Connect(function() if window.Visible then render(); remote:FireServer("Sync") end end)
local function resize()
	local camera = workspace.CurrentCamera
	if camera then scale.Scale = math.min(1, (camera.ViewportSize.X - 20) / 700, (camera.ViewportSize.Y - 20) / 540) end
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
resize()
render()
remote:FireServer("Sync")
