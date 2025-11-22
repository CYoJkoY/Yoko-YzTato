extends "res://ui/menus/ingame/upgrades_ui.gd"

# =========================== Extention =========================== #
func _on_choose_button_pressed(upgrade_data: UpgradeData, player_index: int)->void :
    ._on_choose_button_pressed(upgrade_data, player_index)
    _yztato_extra_upgrade(player_index)

# =========================== Custom =========================== #
func _yztato_extra_upgrade(player_index: int)->void :
    var extra_upgrade_chance: float = RunData.get_player_effect("yztato_extra_upgrade", player_index)
    if extra_upgrade_chance > 0 \
    and randf() <= clamp(extra_upgrade_chance, 0.0, 95.0) / 100:
            var current_option = _showing_option[player_index]
            if current_option != null:
                _upgrades_to_process[player_index].push_front(current_option)
                var popup_text = tr("YZTATO_EXTRA_UPGRADE_CHANCE")
                var main = Utils.get_scene_node()
                if main.has_node("FloatingTextManager"):
                    var floating_text_manager = main.get_node("FloatingTextManager")
                    var player_position = floating_text_manager.players[player_index].global_position
                    floating_text_manager.display(popup_text,
                                                player_position,
                                                Color.gold, null, 2.0, true,
                                                Vector2(0, -100), true)
                _show_next_player_options()
