"""Build native Roblox geometry without external assets or editor plugins."""
from pathlib import Path
import math
import random
import xml.etree.ElementTree as ET

random.seed(625)
ROOT = Path(__file__).resolve().parents[1]
xml = ET.Element('roblox', version='4')
counter = 0

def item(kind, name, parent):
    global counter
    counter += 1
    node = ET.SubElement(parent, 'Item', {'class': kind, 'referent': f'map{counter}'})
    props = ET.SubElement(node, 'Properties')
    ET.SubElement(props, 'string', name='Name').text = name
    return node, props

def prop(props, kind, name, value):
    ET.SubElement(props, kind, name=name).text = str(value)

def vector(props, name, values):
    n = ET.SubElement(props, 'Vector3', name=name)
    for axis, value in zip('XYZ', values): ET.SubElement(n, axis).text = str(value)

def part(parent, name, pos, size, color, material=256, rotation=0, shape=1, transparent=0, collide=True, roll=0):
    node, props = item('Part', name, parent)
    prop(props, 'bool', 'Anchored', 'true')
    prop(props, 'bool', 'CanCollide', str(collide).lower())
    prop(props, 'bool', 'CanTouch', 'false')
    prop(props, 'bool', 'CastShadow', str(collide and transparent < .5).lower())
    prop(props, 'float', 'Transparency', transparent)
    prop(props, 'token', 'Material', material)
    prop(props, 'token', 'shape', shape)
    prop(props, 'token', 'TopSurface', 0)
    prop(props, 'token', 'BottomSurface', 0)
    vector(props, 'size', size)
    c = ET.SubElement(props, 'Color3', name='Color')
    for axis, value in zip('RGB', color): ET.SubElement(c, axis).text = str(value / 255)
    cf = ET.SubElement(props, 'CoordinateFrame', name='CFrame')
    a = math.radians(rotation)
    b = math.radians(roll)
    for key, value in dict(X=pos[0], Y=pos[1], Z=pos[2], R00=math.cos(a)*math.cos(b), R01=-math.cos(a)*math.sin(b), R02=math.sin(a), R10=math.sin(b), R11=math.cos(b), R12=0, R20=-math.sin(a)*math.cos(b), R21=math.sin(a)*math.sin(b), R22=math.cos(a)).items():
        ET.SubElement(cf, key).text = str(value)
    return node

def sign(parent, name, text, pos, size, color=(240, 120, 198)):
    p = part(parent, name, pos, size, (32, 36, 47))
    gui, gp = item('SurfaceGui', 'Texto', p)
    prop(gp, 'token', 'Face', 5)  # +Z, faces the road
    prop(gp, 'float', 'PixelsPerStud', 45)
    prop(gp, 'token', 'SizingMode', 1)
    label, lp = item('TextLabel', 'Título', gui)
    prop(lp, 'string', 'Text', text)
    prop(lp, 'float', 'BackgroundTransparency', 1)
    prop(lp, 'bool', 'TextScaled', 'true')
    prop(lp, 'token', 'Font', 18)
    s = ET.SubElement(lp, 'UDim2', name='Size')
    for k, v in [('XS', 1), ('XO', 0), ('YS', 1), ('YO', 0)]: ET.SubElement(s, k).text = str(v)
    c = ET.SubElement(lp, 'Color3', name='TextColor3')
    for k, v in zip('RGB', color): ET.SubElement(c, k).text = str(v / 255)

world, _ = item('Model', 'BairroPrimavera', xml)
land, _ = item('Folder', 'Paisagismo', world)
part(land, 'Terreno', (135, -4.3, 50), (780, 8, 620), (95, 137, 86), 1280)
part(land, 'Rua das Acácias', (135, -0.15, 52), (440, .35, 22), (54, 59, 67), 1376)
for z in (37, 67):
    part(land, 'Calçada', (135, 0, z), (440, .65, 7), (189, 182, 167), 816)
    part(land, 'Meio-fio', (135, .15, z + (3.8 if z == 37 else -3.8)), (440, .9, .6), (222, 215, 196), 816)
for x in range(-65, 350, 17):
    part(land, 'Faixa de trânsito', (x, .05, 52), (8, .06, .28), (245, 207, 103))
for x in range(-65, 350, 45):
    for z in (34, 70):
        part(land, 'Poste', (x, 7, z), (.45, 14, .45), (43, 53, 57), 1088)
        lamp = part(land, 'Luminária', (x, 14, z), (2, .6, 2), (255, 221, 159), 288)
        _, p = item('PointLight', 'Luz quente', lamp)
        prop(p, 'float', 'Brightness', 1.5)
        prop(p, 'float', 'Range', 23)

def tree(x, z, scale=1):
    part(land, 'Tronco', (x, 4 * scale, z), (8 * scale, 1.4 * scale, 1.4 * scale), (107, 79, 54), 512, shape=2, roll=90)
    for side in (-1, 1):
        part(land, 'Galho', (x + side * 1.2 * scale, 7 * scale, z), (4 * scale, .5 * scale, .5 * scale), (107, 79, 54), 512, shape=2, roll=side*48)
    for dx, dy, dz, width in [(0, 12, 0, 7), (-3, 9, 1, 6), (3, 9, -1, 5), (-1, 10, -3, 6), (1, 9, 3, 5), (0, 8, 0, 6)]:
        part(land, 'Copa', (x + dx * scale, dy * scale, z + dz * scale), (width * scale, width * .65 * scale, width * .85 * scale), random.choice([(61, 94, 59), (78, 112, 65), (94, 123, 72)]), 1284, shape=0, collide=False)

for x in range(-65, 355, 22):
    tree(x, -48, random.uniform(.8, 1.3))
    tree(x, 151, random.uniform(.8, 1.3))
for x in (-65, 365):
    for z in range(-24, 145, 25): tree(x, z)

houses, _ = item('Folder', 'Casas', world)
for index in range(8):
    x0, z0, angle = (index % 4) * 85, (0 if index < 4 else 104), (0 if index < 4 else 180)
    house, _ = item('Model', f'Casa{index + 1}', houses)
    def hp(name, pos, size, color, material=256, **kw):
        x, y, z = pos
        if angle: x, z = -x, -z
        return part(house, name, (x + x0, y, z + z0), size, color, material, rotation=kw.pop('rotation', 0) + angle, **kw)
    cream, wood, dirt = (228, 219, 200), (122, 87, 62), (140, 130, 112)
    hp('Fundação', (0, .5, 0), (36, 1.8, 30), (115, 112, 103), 800)
    hp('Piso', (0, 1.5, 0), (34, .4, 28), wood, 528)
    hp('Varanda', (0, .9, 18), (37, .8, 7), (177, 159, 135), 528)
    for z, y in [(22.5, .45), (24, .1)]: hp('Degrau', (0, y, z), (9, .7, 2), cream, 816)
    hp('Caminho', (0, -.1, 29), (8, .2, 10), (174, 170, 156), 880)
    # Real window openings: low wall strips, jambs and headers are separate geometry.
    wall_height = 10.5
    window_bottom, window_top = 4.9, 10.1
    groups = {}
    for wall_id in range(1, 5): groups[wall_id], _ = item('Folder', f'PaintGroup{wall_id}', house)
    def surface(group, name, pos, size):
        x, y, z = pos
        if angle: x, z = -x, -z
        return part(groups[group], name, (x+x0, y, z+z0), size, dirt, 816, rotation=angle)
    hp('Paint1', (0, 3.25, -14), (35, 3.3, .65), dirt, 816)
    surface(1, 'Verga traseira', (0, 11.15, -14), (35, 2.1, .65))
    for x, w in [(-14.6, 5.8), (0, 12.7), (14.6, 5.8)]: surface(1, 'Alvenaria traseira', (x, 7.5, -14), (w, 5.2, .65))
    for wall_id, x in [(2, -17.2), (3, 17.2)]:
        hp(f'Paint{wall_id}', (x, 3.25, 0), (.65, 3.3, 28), dirt, 816)
        surface(wall_id, 'Verga lateral', (x, 11.15, 0), (.65, 2.1, 28))
        for z in (-8.5, 8.5): surface(wall_id, 'Alvenaria lateral', (x, 7.5, z), (.65, 5.2, 11))
        hp('Janela lateral', (x, 7.5, 0), (.12, 5.2, 6), (179, 199, 204), 1568, transparent=.7)
        for z in (-3, 0, 3): hp('Caixilho lateral', (x, 7.5, z), (.4, 5.5, .16), cream)
    hp('Paint4', (-10.8, 3.25, 14), (13, 3.3, .65), dirt, 816)
    surface(4, 'Verga fachada', (-10.8, 11.15, 14), (13, 2.1, .65))
    for x, w in [(-15.5, 3.6), (-6.2, 3.6)]: surface(4, 'Alvenaria fachada', (x, 7.5, 14), (w, 5.2, .65))
    for x in (-9, 9):
        hp('Janela traseira', (x, 7.5, -14), (5.2, 5.2, .12), (179, 199, 204), 1568, transparent=.7)
        for dx in (-2.65, 0, 2.65): hp('Caixilho traseiro', (x+dx, 7.5, -13.7), (.16, 5.5, .3), cream)
    hp('Fachada direita', (10.8, 3.25, 14), (13, 3.3, .65), cream, 816)
    hp('Verga direita', (10.8, 11.15, 14), (13, 2.1, .65), cream, 816)
    for x in (6.2, 15.5): hp('Alvenaria direita', (x, 7.5, 14), (3.6, 5.2, .65), cream, 816)
    hp('Lintel', (0, 11, 14), (8.5, 2.2, .65), cream)
    for x in (-4.6, 4.6): hp('Batente da porta', (x, 5.8, 14.4), (.4, 8.7, .5), wood, 512)
    for x in (-17.5, 17.5):
        for z in (-14.3, 14.3): hp('Pilar', (x, 6.7, z), (.6, 11.5, .6), cream, 512)
    for y in (2.1, 11.8): hp('Moldura fachada', (0, y, 14.6), (36, .4, .5), cream)
    for x in (-11, 11):
        hp('Vidro decorativo', (x, 7.5, 14.5), (5, 4.7, .15), (137, 178, 188), 1568, transparent=.7)
        for dx in (-2.65, 0, 2.65): hp('Caixilho', (x + dx, 7.5, 14.7), (.16, 5.2, .3), cream)
        for y in (4.9, 7.5, 10.1): hp('Caixilho', (x, y, 14.7), (5.5, .18, .3), cream)
        hp('Floreira', (x, 4.3, 15), (6, .8, 1.4), wood, 512)
        for dx in (-2, -1, 0, 1, 2): hp('Flores', (x + dx, 5, 15), (.65, .7, .65), (202, 120, 171), shape=0, collide=False)
    roof, _ = item('Folder', 'Telhado', house)
    for side in (-1, 1):
        part(roof, 'Telhas', (x0 + side * 9.1, 15.8, z0), (20.3, .65, 33), (92, 82, 73), 800, roll=-side*24)
        for row in range(1, 9):
            x = side * row * 2.05
            part(roof, 'Junta das telhas', (x0+x, 20.25-abs(x)*math.tan(math.radians(24)), z0), (.07, .06, 33), (68, 61, 55), 800, collide=False)
    part(roof, 'Cumeeira', (x0, 20, z0), (.9, .7, 33.5), (112, 80, 63), 848)
    for side in (-1, 1): part(roof, 'Calha', (x0+side*18.5, 11.8, z0), (.4, .4, 33.5), (92, 94, 91), 1088)
    for z in (-14, 14):
        for level in range(13):
            part(roof, 'Fechamento do sótão', (x0, 12.4 + level * .6, z0 + z), (34 - level * 2.7, .61, .65), cream, 512)
    hp('Chaminé', (11, 18, -5), (3, 8, 3), (143, 103, 89), 848)
    for x in (-16, 16): hp('Coluna varanda', (x, 6.5, 20.5), (.6, 11, .6), cream, 512)
    hp('Cobertura varanda', (0, 12, 18), (39, .6, 9), (102, 75, 61), 848)
    hp('Divisória cozinha', (6, 5.4, -7), (.5, 7.5, 13), cream)
    hp('Bancada', (11, 3.1, -11), (8, 3, 4), (146, 157, 141), 512)
    hp('Tampo', (11, 4.7, -11), (8.2, .3, 4.2), cream, 816)
    for x in (8.3, 11, 13.7):
        hp('Porta do armário', (x, 3.1, -8.95), (2.5, 2.6, .15), (157, 166, 149), 512)
        hp('Puxador', (x+.7, 3.5, -8.8), (.12, .5, .12), (115, 114, 103), 1088)
    hp('Cuba da pia', (11, 4.87, -11), (2.4, .12, 1.7), (111, 119, 120), 1088)
    hp('Torneira', (11, 5.3, -11.9), (.14, .8, .14), (148, 153, 152), 1088)
    for x in (-15, 15):
        hp('Rodapé lateral', (x*1.12, 1.95, 0), (.2, .5, 27), cream, 512)
    hp('Rodapé traseiro', (0, 1.95, -13.6), (34, .5, .2), cream, 512)
    for x in (-11, 11):
        for dx in (-2.2, 2.2): hp('Cortina', (x+dx, 7.4, 13.8), (.8, 5, .18), (195, 187, 170), 1312, collide=False)
    lamp = hp('Luz da sala', (-6, 11.5, 0), (2, .2, 2), (232, 223, 201))
    _, lp = item('PointLight', 'Luz ambiente interior', lamp)
    prop(lp, 'float', 'Brightness', .6)
    prop(lp, 'float', 'Range', 18)
    fabric = 1312
    hp('Sofá abandonado', (-10, 2.7, -7), (8, 2, 3.4), (115, 80, 75), fabric)
    hp('Encosto do sofá', (-10, 4.1, -8.4), (8, 2.2, .7), (115, 80, 75), fabric)
    for x in (-14.3, -5.7): hp('Braço do sofá', (x, 3.6, -7), (.7, 2.5, 3.5), (105, 72, 70), fabric)
    hp('Tapete gasto', (-9, 1.76, 0), (10, .07, 7), (126, 110, 100), fabric, collide=False)
    hp('Mesa de centro', (-9, 2.4, 0), (5, 1.3, 2.8), wood, 512)
    for i, (x, z) in enumerate([(-12, 6), (-7, 8), (1, 5), (10, 5), (12, -3), (1, -9), (-3, -5), (-12, -1)], 1):
        trash = hp(f'Trash{i}', (x, 2.3, z), (1.5, 1.2, 1.5), (61, 65, 59) if i % 2 else (145, 116, 82), 256 if i % 2 else 512, rotation=i*29, shape=0 if i % 2 else 1)
        cf = trash.find("Properties/CoordinateFrame[@name='CFrame']")
        tx, tz = float(cf.findtext('X')), float(cf.findtext('Z'))
        part(trash, 'Papel amassado', (tx+.8, 1.8, tz+.5), (.8, .12, .6), (205, 196, 175), rotation=i*13, collide=False)
        if i % 2: part(trash, 'Nó do saco', (tx, 3, tz), (.35, .35, .35), (61, 65, 59), shape=0)
    for i, pos in enumerate([(-12, 2.7, 10), (12, 2.7, 9), (2, 2.7, -11)], 1):
        hp(f'Decor{i}', pos, (2.4, 2.4, 2.4), (151, 165, 146), transparent=.85, collide=False)
    hp('Caixa de correio', (7, 3.1, 27), (1.7, 1, 2), (74, 88, 83), 1088)
    hp('Poste da caixa', (7, 1.5, 27), (.3, 3, .3), wood, 512)
    hp('Lixeira', (-24, 1.5, 25), (2.5, 3, 2.5), (67, 83, 72))
    hp('Tampa da lixeira', (-24, 3.1, 25), (2.7, .3, 2.7), (47, 61, 52))
    hp('SpawnMarker', (0, 4, 28), (1, 1, 1), (255, 255, 255), transparent=1, collide=False)
    # Low picket fences leave a wide opening onto the sidewalk.
    for x in (-29, 29):
        for z in range(-23, 29, 3): hp('Estaca', (x, 1.8, z), (.5, 4, .7), cream, 512)
        for y in (1, 2.7): hp('Travessa cerca', (x, y, 2), (.35, .3, 54), cream, 512)
    for x in (-21, 21):
        hp('Canteiro', (x, .3, 18), (6, .8, 9), (82, 101, 68), 1280)
        hp('Arbusto', (x, 1.4, 18), (5, 2.4, 6), (75, 121, 76), 1280, shape=0)

park, _ = item('Folder', 'Praça', world)
part(park, 'Piso da praça', (-48, -.1, 52), (26, .4, 26), (160, 157, 141), 880)
for z in (43, 61):
    part(park, 'Banco assento', (-48, 2, z), (12, .6, 2.4), (138, 96, 62), 512)
    part(park, 'Banco encosto', (-48, 3.2, z + 1), (12, 2, .4), (138, 96, 62), 512)
    for x in (-52, -44): part(park, 'Pés banco', (x, .9, z), (.6, 2, 2), (48, 58, 58), 1088)
sign(park, 'Boas-vindas', 'BAIRRO PRIMAVERA\nDe Casa em Casa', (-48, 9, 34), (24, 5, .6))
for x in (-58, -38): part(park, 'Coluna placa', (x, 4, 34), (.5, 8, .5), (97, 78, 61), 512)
for i in range(16):
    x = -85 + i * 30
    part(land, 'Colina distante', (x, 0, -82), (60, random.uniform(20, 38), 48), (103, 137, 104), 1280, shape=0)

# Grounded neighborhood with an accessible furniture showroom at the street end.
shop, _ = item('Model', 'Loja', world)
def sp(name, pos, size, color, material=256, **kw):
    return part(shop, name, (317 + pos[0], pos[1], -3 + pos[2]), size, color, material, **kw)
sp('Piso', (0, .6, 0), (54, 1.2, 38), (191, 180, 161), 816)
sp('Parede traseira', (0, 7.6, -19), (54, 14, .6), (220, 216, 204), 816)
for x in (-27, 27): sp('Parede lateral', (x, 7.6, 0), (.6, 14, 38), (220, 216, 204), 816)
for x in (-16, 16):
    sp('Peitoril da vitrine', (x, 1.8, 19), (22, 1.5, .6), (124, 118, 105), 816)
    sp('Vitrine', (x, 7.2, 19), (21, 9, .15), (170, 192, 195), 1568, transparent=.8)
    for dx in (-10.7, 10.7): sp('Caixilho vitrine', (x+dx, 7.2, 19), (.25, 9.5, .4), (59, 70, 67))
sp('Verga da entrada', (0, 13.3, 19), (54, 2.5, .8), (87, 104, 94), 512)
roof, _ = item('Folder', 'Telhado', shop)
part(roof, 'Cobertura loja', (317, 15, -3), (57, .8, 42), (88, 93, 86), 800)
sp('Marquise', (0, 11.7, 22), (56, .5, 7), (98, 119, 102))
sp('Entrada', (0, .35, 25), (10, .7, 12), (183, 177, 160), 880)
sp('Passarela', (0, -.03, 32), (10, .3, 6), (183, 177, 160), 880)
sp('Balcao', (15, 2.7, -7), (14, 3, 3.2), (147, 112, 82), 512)
sp('Tampo balcão', (15, 4.3, -7), (14.5, .3, 3.6), (220, 216, 204), 816)
sp('Caixa registradora', (12, 4.8, -7), (1.7, .8, 1.6), (58, 63, 64))
sign(shop, 'Letreiro', 'CASA & CIA\nMóveis • Iluminação • Decoração', (317, 13.7, 17), (32, 2.3, .5), (238, 231, 211))
for x in (-19, -8, 3):
    sp('Estante da loja', (x, 4.5, -16.5), (.3, 6.7, 2.5), (151, 118, 86), 512)
for y in (1.5, 4, 6.5):
    sp('Prateleira', (-8, y, -16), (26, .25, 3), (151, 118, 86), 512)
    for x in (-18, -13, -8, -3):
        sp('Lata de tinta', (x, y+.75, -16), (1.2, 1.3, 1.2), (162, 169, 150))
for x, z in [(-17, 7), (-6, 7), (12, 7)]:
    sp('Pedestal de exposição', (x, 1.4, z), (7, .4, 7), (169, 156, 134), 512)
# Sample poltrona, plant and table remain visible before Play.
sp('Poltrona da vitrine', (-17, 2.8, 7), (4, 1, 3.8), (151, 164, 145), 1312)
sp('Encosto da poltrona', (-17, 4, 5.4), (4, 2, .7), (151, 164, 145), 1312)
for x in (-19, -15): sp('Braço poltrona', (x, 3.5, 7), (.5, 1.7, 3.8), (151, 164, 145), 1312)
sp('Vaso da vitrine', (-6, 2.7, 7), (2, 2, 2), (186, 160, 133))
sp('Planta da vitrine', (-6, 4.5, 7), (3, 2.6, 3), (76, 112, 73), 1280, shape=0)
sp('Mesa da vitrine', (12, 4, 7), (4.5, .35, 3.6), (162, 129, 94), 512)
for x in (10.3, 13.7):
    for z in (5.7, 8.3): sp('Pé da mesa', (x, 2.7, z), (.3, 2.6, .3), (121, 93, 64), 512)
for x in (-23, 0, 23):
    lamp = sp('Luz do showroom', (x, 13.4, 0), (5, .2, 1.4), (245, 235, 211), 288, collide=False)
    _, lp = item('PointLight', 'Luz interior', lamp)
    prop(lp, 'float', 'Brightness', 1.2)
    prop(lp, 'float', 'Range', 24)
# Parking bay and a stationary delivery van.
sp('Estacionamento', (0, -.05, -32), (56, .3, 18), (91, 94, 91), 1376)
for x in (-20, -7, 7, 20): sp('Faixa estacionamento', (x, .13, -32), (.2, .05, 15), (228, 223, 204))
sp('Furgão de entregas', (15, 3.5, -33), (6, 5, 11), (221, 215, 199), 1088)
sp('Cabine', (15, 3, -26), (6, 4, 4), (122, 142, 127), 1088)
sp('Para-brisa', (15, 4, -23.9), (5, 1.6, .1), (133, 160, 167), 1568, transparent=.25)
for x in (11.7, 18.3):
    for z in (-36, -27): sp('Roda do furgão', (x, 1.3, z), (.8, 2.4, 2.4), (44, 45, 43), shape=2)

destination = ROOT / 'src/map/Neighborhood.rbxmx'
ET.indent(xml)
ET.ElementTree(xml).write(destination, encoding='utf-8', xml_declaration=True)
print(f'Generated {counter} instances: {destination}')
