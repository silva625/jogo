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

def part(parent, name, pos, size, color, material=256, rotation=0, shape=1, transparent=0, collide=True):
    node, props = item('Part', name, parent)
    prop(props, 'bool', 'Anchored', 'true')
    prop(props, 'bool', 'CanCollide', str(collide).lower())
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
    for key, value in dict(X=pos[0], Y=pos[1], Z=pos[2], R00=math.cos(a), R01=0, R02=math.sin(a), R10=0, R11=1, R12=0, R20=-math.sin(a), R21=0, R22=math.cos(a)).items():
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
part(land, 'Terreno', (135, -1.3, 50), (440, 2, 250), (95, 137, 86), 1280)
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
    part(land, 'Tronco', (x, 4 * scale, z), (1.7 * scale, 8 * scale, 1.7 * scale), (107, 79, 54), 512)
    for dx, dy, dz, width in [(0, 11, 0, 10), (-3, 9, 1, 8), (3, 9, -1, 8)]:
        part(land, 'Copa', (x + dx * scale, dy * scale, z + dz * scale), (width * scale, width * scale, width * scale), random.choice([(67, 112, 72), (88, 133, 76), (113, 148, 82)]), 1280, shape=0)

for x in range(-65, 355, 22):
    tree(x, -48, random.uniform(.8, 1.3))
    tree(x, 151, random.uniform(.8, 1.3))
for x in (-65, 330):
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
    # Four paintable walls with openings: rear and side walls are kept accessible.
    hp('Paint1', (0, 6.9, -14), (35, 10.5, .65), dirt, 816)
    hp('Paint2', (-17.2, 6.9, 0), (.65, 10.5, 28), dirt, 816)
    hp('Paint3', (17.2, 6.9, 0), (.65, 10.5, 28), dirt, 816)
    hp('Paint4', (-10.8, 6.9, 14), (13, 10.5, .65), dirt, 816)
    hp('Fachada direita', (10.8, 6.9, 14), (13, 10.5, .65), cream, 816)
    hp('Lintel', (0, 11, 14), (8.5, 2.2, .65), cream)
    for x in (-4.6, 4.6): hp('Batente da porta', (x, 5.8, 14.4), (.4, 8.7, .5), wood, 512)
    for x in (-17.5, 17.5):
        for z in (-14.3, 14.3): hp('Pilar', (x, 6.7, z), (.6, 11.5, .6), cream, 512)
    for y in (2.1, 11.8): hp('Moldura fachada', (0, y, 14.6), (36, .4, .5), cream)
    for x in (-11, 11):
        hp('Vidro decorativo', (x, 7.5, 14.5), (5, 4.7, .15), (137, 178, 188), 1568, transparent=.25)
        for dx in (-2.65, 0, 2.65): hp('Caixilho', (x + dx, 7.5, 14.7), (.16, 5.2, .3), cream)
        for y in (4.9, 7.5, 10.1): hp('Caixilho', (x, y, 14.7), (5.5, .18, .3), cream)
        hp('Floreira', (x, 4.3, 15), (6, .8, 1.4), wood, 512)
        for dx in (-2, -1, 0, 1, 2): hp('Flores', (x + dx, 5, 15), (.65, .7, .65), (202, 120, 171), shape=0, collide=False)
    roof, _ = item('Folder', 'Telhado', house)
    # Single raised slab and stepped hip silhouette, avoiding collisions with indoor camera.
    for level in range(5):
        part(roof, 'Telhas', (x0, 12.5 + level * .8, z0), (39 - level * 5, .85, 33 - level * 4), (71 + level * 3, 79 + level * 2, 86 + level * 2), 800)
    hp('Chaminé', (11, 16, -5), (3, 7, 3), (143, 103, 89), 848)
    for x in (-16, 16): hp('Coluna varanda', (x, 6.5, 20.5), (.6, 11, .6), cream, 512)
    hp('Cobertura varanda', (0, 12, 18), (39, .6, 9), (71, 79, 86), 800)
    hp('Divisória cozinha', (6, 5.4, -7), (.5, 7.5, 13), cream)
    hp('Bancada', (11, 3.1, -11), (8, 3, 4), (146, 157, 141), 512)
    hp('Tampo', (11, 4.7, -11), (8.2, .3, 4.2), cream, 816)
    fabric = 1312
    hp('Sofá abandonado', (-10, 2.7, -7), (8, 2, 3.4), (115, 80, 75), fabric)
    hp('Encosto do sofá', (-10, 4.1, -8.4), (8, 2.2, .7), (115, 80, 75), fabric)
    for x in (-14.3, -5.7): hp('Braço do sofá', (x, 3.6, -7), (.7, 2.5, 3.5), (105, 72, 70), fabric)
    hp('Tapete gasto', (-9, 1.76, 0), (10, .07, 7), (126, 110, 100), fabric, collide=False)
    hp('Mesa de centro', (-9, 2.4, 0), (5, 1.3, 2.8), wood, 512)
    for i, (x, z) in enumerate([(-12, 6), (-7, 8), (1, 5), (10, 5), (12, -3), (1, -9), (-3, -5), (-12, -1)], 1):
        hp(f'Trash{i}', (x, 2.2, z), (1.5 + i % 2, 1.1, 1.7), (68 + i * 4, 64 + i * 3, 59), 800, rotation=i*29)
    for i, pos in enumerate([(-12, 2.7, 10), (12, 2.7, 9), (2, 2.7, -11)], 1):
        hp(f'Decor{i}', pos, (2.4, 2.4, 2.4), (232, 136, 202), transparent=.65, collide=False)
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
sign(park, 'Boas-vindas', 'ENTRE MUNDOS\nReforme o impossível', (-48, 9, 34), (24, 5, .6))
for x in (-58, -38): part(park, 'Coluna placa', (x, 4, 34), (.5, 8, .5), (97, 78, 61), 512)
for i in range(16):
    x = -85 + i * 30
    part(land, 'Colina distante', (x, 0, -82), (60, random.uniform(20, 38), 48), (103, 137, 104), 1280, shape=0)

# A floating neighborhood above clouds, connected to a small observatory island.
surreal, _ = item('Folder', 'Surreal', world)
part(surreal, 'Rocha da ilha principal', (135, -13, 50), (438, 25, 245), (64, 72, 91), 800)
for i in range(18):
    x, z = random.uniform(-110, 370), random.uniform(-100, 175)
    part(surreal, 'Nuvem', (x, random.uniform(-35, -25), z), (random.uniform(40, 75), 12, random.uniform(24, 45)), (210, 205, 232), shape=0, transparent=.15, collide=False)
part(surreal, 'Ilha do observatório', (135, 18, -160), (68, 16, 68), (78, 78, 113), 800, shape=0)
part(surreal, 'Jardim lunar', (135, 26, -160), (60, 1, 60), (122, 125, 160), 800)
for x in (105, 165): part(surreal, 'Guarda-corpo lunar', (x, 28, -160), (.5, 3, 60), (142, 114, 207), 288, transparent=.4)
part(surreal, 'Guarda-corpo lunar', (135, 28, -190), (60, 3, .5), (142, 114, 207), 288, transparent=.4)
part(surreal, 'Guarda-corpo lunar', (135, 28, -130), (60, 3, .5), (142, 114, 207), 288, transparent=.4)
part(surreal, 'Lua gigante', (135, 58, -182), (23, 23, 23), (255, 223, 181), 288, shape=0, collide=False)
for i in range(24):
    a = i * math.pi * 2 / 24
    part(surreal, 'Órbita da lua', (135 + math.cos(a) * 19, 58 + math.sin(a) * 19, -182), (1, 1, 1), (147, 222, 255), 288, shape=0, collide=False)
for name, pos, tint in [('PortalOut', (310, 0, 52), (163, 117, 255)), ('PortalReturn', (135, 27, -137), (98, 225, 218))]:
    x, y, z = pos
    part(surreal, name, (x, y + 2, z), (3, 4, 1), tint, 288, transparent=.65, collide=False)
    part(surreal, 'Base do portal', (x, y + .2, z), (9, .5, 5), (56, 47, 83), 800)
    for i in range(16):
        a = i * math.pi * 2 / 16
        part(surreal, 'Anel do portal', (x + math.cos(a) * 3.7, y + 4.5 + math.sin(a) * 3.7, z), (1.1, 1.1, .8), tint, 288, shape=0, collide=False)
    light, lp = item('PointLight', 'Brilho', part(surreal, 'Núcleo', (x, y + 4, z), (1, 1, 1), tint, 288, shape=0, transparent=.3, collide=False))
    prop(lp, 'float', 'Range', 18)
    prop(lp, 'float', 'Brightness', 1.5)
sign(surreal, 'Observatório', 'OBSERVATÓRIO DOS SONHOS\nExplore. Colecione. Transforme.', (135, 32, -185), (25, 5, .5), (151, 234, 255))
sign(surreal, 'Destino do portal', 'PORTAL DO OBSERVATÓRIO\nSegure E para viajar', (310, 11, 52), (18, 3, .5), (195, 165, 255))
crystals, _ = item('Folder', 'Cristais', surreal)
locations = [(x, 2.4, z) for z in (28, 76) for x in (0, 85, 170, 255)] + [(320, 2.4, 70), (120, 29, -151), (150, 29, -151), (135, 29, -175)]
for i, (x, y, z) in enumerate(locations, 1):
    part(crystals, f'Crystal{i}', (x, y, z), (1.1, 2.8, 1.1), (147, 224, 255) if i < 10 else (247, 141, 224), 288, rotation=45, collide=False)
    part(surreal, 'Pedestal de cristal', (x, y - 1.6, z), (2.4, .4, 2.4), (74, 65, 96), 800)
for i in range(14):
    part(surreal, 'OrbeFlutuante', (-50 + i * 29, 18 + (i % 3) * 4, 52), (1.5, 1.5, 1.5), (177, 145, 255), 288, shape=0, collide=False)

destination = ROOT / 'src/map/Neighborhood.rbxmx'
ET.indent(xml)
ET.ElementTree(xml).write(destination, encoding='utf-8', xml_declaration=True)
print(f'Generated {counter} instances: {destination}')
