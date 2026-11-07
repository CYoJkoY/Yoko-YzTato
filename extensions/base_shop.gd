extends "res://ui/menus/shop/base_shop.gd"

const YZTATO_BASE_SHOP_SERVICE = preload("res://mods-unpacked/Yoko-YzTato/extensions/services/shop_service.gd")

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _on_RerollButton_pressed(player_index: int) -> void:
    if RunData.get_player_locked_shop_items(player_index).size() >= ItemService.NB_SHOP_ITEMS:
        ._on_RerollButton_pressed(player_index)
        return

    if RunData.get_player_gold(player_index) < _reroll_price[player_index]:
        ._on_RerollButton_pressed(player_index)
        return

    ._on_RerollButton_pressed(player_index)
    var update_stats_func: FuncRef = funcref(self, "_update_stats")
    var get_gear_container_func: FuncRef = funcref(self, "_get_gear_container")
    YZTATO_BASE_SHOP_SERVICE._yztato_apply_random_curse(update_stats_func, get_gear_container_func, player_index)
