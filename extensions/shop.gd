extends "res://ui/menus/shop/shop.gd"

# =========================== Extension =========================== #
func _on_RerollButton_pressed(player_index: int) -> void:
    ._on_RerollButton_pressed(player_index)
    
    if RunData.get_player_gold(player_index) >= _reroll_price[player_index]:
        _yztato_apply_random_curse(player_index)

# =========================== Custom =========================== #
func _yztato_apply_random_curse(player_index: int) -> void:
    var random_curse: Array = RunData.get_player_effect(Utils.yztato_random_curse_on_reroll_hash, player_index)
    
    for curse in random_curse:
        if !Utils.get_chance_success(curse[1] / 100.0): continue
        
        var dlc_data: DLCData = ProgressData.available_dlcs[0]
        var player_items: Array = RunData.get_player_items(player_index)
        var player_weapons: Array = RunData.get_player_weapons(player_index)
        
        var all_gears: Array = []
        for item in player_items:
            if !item.is_cursed and \
            !(item is CharacterData):
                all_gears.append(item)
                
        for weapon in player_weapons:
            if !weapon.is_cursed:
                all_gears.append(weapon)
        
        var gear_count := min(curse[0], all_gears.size())
        if gear_count <= 0: continue
        
        RunData.add_tracked_value(player_index, Utils.character_yztato_fanatic_hash, gear_count)
        var gears_to_curse = []
        for _i in gear_count:
            var random_index = Utils.randi_range(0, all_gears.size() - 1)
            gears_to_curse.append(all_gears[random_index])
            all_gears.remove(random_index)
        
        var updated_any_gear := false
        for gear in gears_to_curse:
            var new_gear = dlc_data.curse_item(gear, player_index)

            if new_gear is WeaponData:
                RunData.remove_weapon(gear, player_index)
                RunData.add_weapon(new_gear, player_index)
                updated_any_gear = true
            
            elif new_gear is ItemData:
                RunData.remove_item(gear, player_index)
                if gear.replaced_by: RunData.remove_item(gear.replaced_by, player_index)
                RunData.add_item(new_gear, player_index)
                updated_any_gear = true

        if updated_any_gear:
            _update_stats()
            var player_gear_container = _get_gear_container(player_index)
            player_gear_container.set_weapons_data(RunData.get_player_weapons(player_index))
            player_gear_container.set_items_data(RunData.get_player_items(player_index))
            
            var shop_items_container = _get_shop_items_container(player_index)
            shop_items_container.reload_shop_items()
