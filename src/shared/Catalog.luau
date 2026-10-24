local Catalog = {}
Catalog.colors = {
	{ id = "rose", name = "Rosa", rgb = {220, 145, 179} },
	{ id = "sage", name = "Verde", rgb = {128, 162, 132} },
	{ id = "sand", name = "Areia", rgb = {205, 183, 146} },
	{ id = "ocean", name = "Azul", rgb = {107, 150, 185} },
}
Catalog.items = {
	{ id = "plant", name = "Planta de interior", category = "Plantas", price = 75, description = "Um toque de verde para a casa." },
	{ id = "lamp", name = "Luminária de piso", category = "Luzes", price = 120, description = "Luz quente e ambiente acolhedor." },
	{ id = "rug", name = "Tapete redondo", category = "Tapetes", price = 100, description = "Cor e conforto em cada cantinho." },
	{ id = "table", name = "Mesa lateral", category = "Móveis", price = 150, description = "Madeira natural e linhas simples." },
	{ id = "chair", name = "Poltrona aconchego", category = "Móveis", price = 200, description = "Seu novo lugar favorito." },
	{ id = "shelf", name = "Estante de livros", category = "Móveis", price = 180, description = "Livros, objetos e personalidade." },
	{ id = "galaxy", name = "Aquário de galáxia", category = "Surreais", price = 450, description = "Uma pequena galáxia flutuando na sua sala." },
	{ id = "star_tree", name = "Árvore de estrelas", category = "Surreais", price = 320, description = "Cristais luminosos no lugar de folhas." },
	{ id = "moon", name = "Lua de cabeceira", category = "Surreais", price = 240, description = "Um pedacinho do céu para chamar de seu." },
}
function Catalog.find(id)
	for _, item in Catalog.items do if item.id == id then return item end end
	return nil
end
function Catalog.color(id)
	for _, color in Catalog.colors do if color.id == id then return color end end
	return nil
end
return Catalog
