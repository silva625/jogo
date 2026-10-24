"""Validate the editable map and the objects consumed by the game server."""
from pathlib import Path
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
model = ET.parse(root / 'src/map/Neighborhood.rbxmx').getroot()

def name(node):
    return node.findtext("Properties/string[@name='Name']")

houses = next(n for n in model.iter('Item') if name(n) == 'Casas')
assert len(houses.findall('Item')) == 8
for house in houses.findall('Item'):
    children = {name(n): n for n in house.findall('Item')}
    for required in ['Piso', 'SpawnMarker', 'Telhado'] + [f'Trash{i}' for i in range(1, 9)] + [f'Paint{i}' for i in range(1, 5)] + [f'Decor{i}' for i in range(1, 4)]:
        assert required in children, (name(house), required)
    marker = children['SpawnMarker']
    assert marker.attrib['class'] == 'SpawnLocation'
    assert marker.findtext("Properties/bool[@name='Enabled']") == 'true'
    assert marker.findtext("Properties/bool[@name='CanCollide']") == 'false'
    spawn_cf = marker.find("Properties/CoordinateFrame[@name='CFrame']")
    floor_cf = children['Piso'].find("Properties/CoordinateFrame[@name='CFrame']")
    sx, sy, sz = (float(spawn_cf.findtext(axis)) for axis in 'XYZ')
    fx, fz = (float(floor_cf.findtext(axis)) for axis in 'XZ')
    assert sx == fx and sy < 1
    assert 41 < sz < 63, 'Spawn must be on the street, beyond the roofs and porches'
    assert (sz - fz) * float(spawn_cf.findtext('R22')) > 0, 'Spawn faces its assigned house'
    slopes = [p for p in children['Telhado'].findall('Item') if name(p) == 'Telhas']
    assert len(slopes) == 2
    assert all(abs(float(p.findtext("Properties/CoordinateFrame/R10"))) > .1 for p in slopes)
    for p in house.iter('Item'):
        if p.attrib['class'] == 'Part':
            assert p.findtext("Properties/bool[@name='Anchored']") == 'true'
            sizes = p.find("Properties/Vector3[@name='size']")
            assert all(float(sizes.findtext(axis)) > 0 for axis in 'XYZ')
names = {name(n) for n in model.iter('Item')}
for removed in ('Surreal', 'PortalOut', 'PortalReturn', 'Cristais', 'OrbeFlutuante', 'Lua gigante', 'Nuvem'):
    assert removed not in names, removed
shop = next(n for n in model.iter('Item') if name(n) == 'Loja')
shop_parts = {name(n): n for n in shop.findall('Item')}
for required in ('Piso', 'Balcao', 'Vitrine', 'Entrada', 'Passarela', 'Telhado', 'Letreiro', 'Caixa registradora'):
    assert required in shop_parts, required
floor = shop_parts['Piso'].find("Properties/CoordinateFrame[@name='CFrame']")
assert float(floor.findtext('X')) == 317 and float(floor.findtext('Z')) == -3
assert float(floor.findtext('Y')) == .6
# Doorway remains free: vitrines stop at x +/-5, leaving a ten-stud entrance.
for p in shop.findall('Item'):
    if name(p) == 'Vitrine':
        cf = p.find("Properties/CoordinateFrame[@name='CFrame']")
        size = p.find("Properties/Vector3[@name='size']")
        assert abs(float(cf.findtext('X')) - 317) - float(size.findtext('X')) / 2 >= 5
print('PASS: eight houses, work targets, physical shop with open doorway and no fantasy scenery')
