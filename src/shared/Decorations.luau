local Catalog = if script then require(script.Parent.Catalog) else require("./Catalog")
local Decorations = {}
function Decorations.new()
	return { inventory = { plant = 3 }, selected = "plant", color = "sage", slots = {} }
end
function Decorations.buy(state, decor, id)
	local item = Catalog.find(id)
	if not item then return false, "Item inválido." end
	local total = 0
	for _, count in decor.inventory do total += count end
	if total >= 30 then return false, "Mochila cheia (30 itens). Coloque alguns na casa." end
	if state.cash < item.price then return false, "Dinheiro insuficiente. Continue a reforma!" end
	state.cash -= item.price
	decor.inventory[id] = (decor.inventory[id] or 0) + 1
	return true, "Compra realizada: " .. item.name
end
function Decorations.select(decor, id, color)
	if not Catalog.find(id) or not Catalog.color(color) then return false, "Escolha inválida." end
	if (decor.inventory[id] or 0) == 0 then
		-- Allow recoloring an item already installed without buying another copy.
		local installed = false
		for _, slot in decor.slots do if slot.id == id then installed = true end end
		if not installed then return false, "Compre esse item primeiro." end
	end
	decor.selected, decor.color = id, color
	return true, "Selecionado! Segure E em um ponto rosa da sua casa."
end
function Decorations.place(state, decor, slot)
	if state.stage < 3 then return false, "Termine a limpeza e a pintura primeiro." end
	if type(slot) ~= "number" or slot % 1 ~= 0 or slot < 1 or slot > 3 then return false, "Ponto inválido." end
	local old = decor.slots[slot]
	local id = decor.selected
	if not Catalog.find(id) or not Catalog.color(decor.color) then return false, "Escolha inválida." end
	if not old or old.id ~= id then
		if (decor.inventory[id] or 0) < 1 then return false, "Sem unidades na mochila. Escolha outro item ou compre na loja." end
		decor.inventory[id] -= 1
		if old then decor.inventory[old.id] = (decor.inventory[old.id] or 0) + 1 end
	end
	decor.slots[slot] = { id = id, color = decor.color }
	return true, old and "Decoração atualizada. O item anterior voltou à mochila." or "Decoração colocada!"
end
return Decorations
