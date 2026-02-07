extends "res://ui/menus/ingame/upgrades_ui.gd"

# =========================== Extension =========================== #
func _on_choose_button_pressed(upgrade_data: UpgradeData, player_index: int) -> void:
    _yztato_extra_upgrade(player_index)
    ._on_choose_button_pressed(upgrade_data, player_index)

# =========================== Custom =========================== #
func _yztato_extra_upgrade(player_index: int) -> void:
    var extra_upgrades: Array = RunData.get_player_effect(Utils.yztato_extra_upgrade_hash, player_index)
    if extra_upgrades.empty(): return

    for extra_upgrade in extra_upgrades:
        var tracking_key_hash: int = extra_upgrade[0]
        var extra_upgrade_chance: float = extra_upgrade[1] / 100.0
        
        if !Utils.get_chance_success(extra_upgrade_chance): continue

        RunData.add_tracked_value(player_index, tracking_key_hash, 1)

        var level = RunData.get_player_level(player_index)
        var main = Utils.get_scene_node()
        var upgrades: BoxContainer = main._things_to_process_player_containers[player_index].upgrades

        upgrades.add_element(ItemService.get_icon(Keys.icon_upgrade_to_process_hash), level)
        
        var upgrade_to_process = UpgradeToProcess.new()
        upgrade_to_process.level = level
        upgrade_to_process.player_index = player_index
        _upgrades_to_process[player_index].push_front(upgrade_to_process)

        main._players_ui[player_index].update_level_label()

        var floating_text_manager = main._floating_text_manager
        var rect_size = main._hud.rect_size
        var center_top_pos = Vector2(rect_size.x * 0.5, rect_size.y * 0.3)
        var popup_text: String = tr("YZTATO_EXTRA_UPGRADE_CHANCE")
        floating_text_manager.display(
            popup_text,
            center_top_pos,
            Color.gold,
            null,
            2.0,
            true,
            Vector2(0, -50),
            true
        )
