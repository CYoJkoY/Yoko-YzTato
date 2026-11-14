"""Validate item-set ownership against the aggregate actually registered by NCL."""
import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT_ID = "Yoko-YzTato"


def catalog():
    source = (ROOT / "NewContentDataDLC1.tres").read_text(encoding="utf-8")
    resources = dict(
        (resource_id, path)
        for path, resource_id in re.findall(
            r'\[ext_resource path="([^"]+)" type="[^"]+" id=(\d+)\]', source
        )
    )
    result = {}
    for category in ("characters", "items", "weapons"):
        match = re.search(rf"^{category} = (.+)$", source, re.M)
        result[category] = [
            ROOT / resources[resource_id].split(CONTENT_ID + "/", 1)[1]
            for resource_id in re.findall(r"ExtResource\( (\d+) \)", match[1])
        ]
    return result


class ItemSetContract(unittest.TestCase):
    def test_manifest_identity_matches_requirement(self):
        manifest = json.loads((ROOT / "manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["namespace"] + "-" + manifest["name"], CONTENT_ID)

    def test_every_registered_character_requires_its_set(self):
        characters = catalog()["characters"]
        self.assertEqual(len(characters), 13)
        for character in characters:
            with self.subTest(character=character.name):
                source = character.read_text(encoding="utf-8")
                requirements = re.findall(r'^required_item_set = "([^"]*)"$', source, re.M)
                self.assertEqual(requirements, [CONTENT_ID])

    def test_shop_and_starting_equipment_have_unique_registered_ownership(self):
        content = catalog()
        self.assertTrue(content["items"])
        self.assertTrue(content["weapons"])
        for category in ("items", "weapons"):
            ids = []
            for path in content[category]:
                source = path.read_text(encoding="utf-8")
                ids.append(re.search(r'^my_id = "([^"]+)"$', source, re.M)[1])
            self.assertEqual(len(ids), len(set(ids)), category + " has ambiguous ownership")


if __name__ == "__main__":
    unittest.main(verbosity=2)
