extends SceneTree

# Run from the Brotato project with the complete mod stack loaded:
# godot --no-window --path <Brotato> --script res://mods-unpacked/Yoko-YzTato/tests/check_item_set.gd
const CONTENT_ID = "Yoko-YzTato"
var failures = 0

func _init() -> void:
    call_deferred("_run")

func check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error(message)

func _run() -> void:
    var progress_data = get_root().get_node("ProgressData")
    var item_service = get_root().get_node("ItemService")
    var run_data = get_root().get_node("RunData")
    var content = progress_data.ncl_get_content(CONTENT_ID)
    if content == null:
        push_error("YzTato content must be registered; check Mod Loader and DLC availability.")
        quit(1)
        return
    var originally_selected = progress_data.is_update_data_selected(CONTENT_ID)
    var unlocked_characters = progress_data.characters_unlocked.duplicate()
    var unlocked_items = progress_data.items_unlocked.duplicate()
    var unlocked_weapons = progress_data.weapons_unlocked.duplicate()
    # Unlock only in memory to cover content regardless of the local save.
    for item in content.items:
        if not progress_data.items_unlocked.has(item.my_id_hash):
            progress_data.items_unlocked.append(item.my_id_hash)
    for weapon in content.weapons:
        if not progress_data.weapons_unlocked.has(weapon.weapon_id_hash):
            progress_data.weapons_unlocked.append(weapon.weapon_id_hash)
    for selected in [true, false, true]:
        if selected:
            progress_data.add_item_set(CONTENT_ID)
        else:
            progress_data.remove_item_set(CONTENT_ID)
        item_service.init_unlocked_pool()
        for character in content.characters:
            check(character.required_item_set == CONTENT_ID, character.my_id + " missing required item set")
            check((item_service.get_disabled_required_update(character) == null) == selected, character.my_id + " availability mismatch")
        for item in content.items + content.weapons:
            var update = item_service.get_update_data_by_item_id(item.duplicate())
            check(update != null and update.id == CONTENT_ID, item.my_id + " missing item set ownership")
            if update != null:
                check(progress_data.has_item_set(update.id) == selected, item.my_id + " starting equipment availability mismatch")
            var in_pool = false
            for tier in item_service._tiers_data:
                if tier[item_service.TierData.ALL_ITEMS].has(item):
                    in_pool = true
            if not selected:
                check(not in_pool, item.my_id + " leaked into disabled shop pool")
            elif item.can_be_looted:
                if content.weapons.has(item):
                    check(in_pool, item.my_id + " missing from enabled shop pool")
                elif item.max_nb != 0 and run_data.current_difficulty >= item.minimum_difficulty:
                    check(in_pool, item.my_id + " missing from enabled shop pool")
    progress_data.characters_unlocked = unlocked_characters
    progress_data.items_unlocked = unlocked_items
    progress_data.weapons_unlocked = unlocked_weapons
    if originally_selected:
        progress_data.add_item_set(CONTENT_ID)
    else:
        progress_data.remove_item_set(CONTENT_ID)
    item_service.init_unlocked_pool()
    print("YzTato item-set regression: %d failures; %d characters, %d items, %d weapons" % [failures, content.characters.size(), content.items.size(), content.weapons.size()])
    quit(0 if failures == 0 else 1)
