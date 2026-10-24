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
    assert marker.findtext("Properties/bool[@name='CanCollide']") == 'false'
    assert len(children['Telhado'].findall('Item')) == 5
    for p in house.iter('Item'):
        if p.attrib['class'] == 'Part':
            assert p.findtext("Properties/bool[@name='Anchored']") == 'true'
            sizes = p.find("Properties/Vector3[@name='size']")
            assert all(float(sizes.findtext(axis)) > 0 for axis in 'XYZ')
surreal = next(n for n in model.iter('Item') if name(n) == 'Surreal')
objects = {name(n): n for n in surreal.findall('Item')}
assert 'PortalOut' in objects and 'PortalReturn' in objects
assert 'Jardim lunar' in objects
crystals = objects['Cristais'].findall('Item')
assert {name(c) for c in crystals} == {f'Crystal{i}' for i in range(1, 13)}
for c in crystals:
    assert c.findtext("Properties/bool[@name='CanCollide']") == 'false'
floor = objects['Jardim lunar'].find("Properties/CoordinateFrame[@name='CFrame']")
# Server arrival (135, 31, -149) must be above the solid observatory platform.
assert abs(135 - float(floor.findtext('X'))) < 28
assert abs(-149 - float(floor.findtext('Z'))) < 28
assert float(floor.findtext('Y')) + .5 < 31
print('PASS: eight houses, mission objects, anchored geometry, twelve crystals, portals and observatory landing')
