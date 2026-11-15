extends "res://mods-unpacked/Yoko-NewContentLoader/NewContent.gd"

# Monster yarn balls are rolled in extensions/main.gd::spawn_consumables(), once
# per killed enemy, so the drop rate only depends on the suture stat.
#
# This NCL hook is called for every base consumable roll (also when that roll
# returns null), so it must stay a pass-through: rolling the yarn ball here as
# well would drop two yarn balls on the same kill and double the real chance.
func ncl_update_consumable_to_get(base_consumable_data: ConsumableData) -> ConsumableData:
    return base_consumable_data
