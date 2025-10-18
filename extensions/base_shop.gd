extends "res://ui/menus/shop/base_shop.gd"

# =========================== Extention =========================== #
func _on_RerollButton_pressed(player_index: int) -> void :
	._on_RerollButton_pressed(player_index)
	apply_random_curse(player_index)

# =========================== Custom =========================== #
func apply_random_curse(player_index: int) -> void:
	var random_curse: Array = RunData.get_player_effect("yztato_random_curse_on_reroll", player_index)
	if !random_curse.empty(): for curse in random_curse:
		var count: int = curse[0]
		var chance: int = curse[1]
		
		if Utils.get_chance_success(chance / 100.0):
			var player_items: Array = RunData.get_player_items(player_index)
			var player_weapons: Array = RunData.get_player_weapons(player_index)
			
			var all_gears: Array = []
			if !player_items.empty(): all_gears.append_array(player_items)
			if !player_weapons.empty(): all_gears.append_array(player_weapons)
			for gear in all_gears: if gear.is_cursed: all_gears.erase(gear)

			var gear_to_curse = []
			var gear_count = min(count, all_gears.size())
			RunData.add_tracked_value(player_index, "character_yztato_fanatic" , gear_count)
			
			for _i in range(gear_count):
				if all_gears.size() <= 0: break
				var random_index = Utils.randi_range(0, all_gears.size() - 1)
				gear_to_curse.push_back(all_gears[random_index])
				all_gears.remove(random_index)
			
			for gear in gear_to_curse:
				for dlc_id in RunData.enabled_dlcs:
					var dlc_data: DLCData = ProgressData.get_dlc_data(dlc_id)
					if dlc_data and dlc_data.has_method("curse_item"):
						var new_gear = dlc_data.curse_item(gear, player_index)
						if new_gear is CharacterData: pass
						elif new_gear is ItemData:
							RunData.remove_item(gear, player_index)
							RunData.add_item(new_gear, player_index)
						else:
							RunData.remove_weapon(gear, player_index)
							RunData.add_weapon(new_gear, player_index)

			if gear_to_curse.size() > 0:
				_update_stats()
				var player_gear_container = _get_gear_container(player_index)
				player_gear_container.set_weapons_data(RunData.get_player_weapons(player_index))
				player_gear_container.set_items_data(RunData.get_player_items(player_index))
				
				var shop_items_container = _get_shop_items_container(player_index)
				shop_items_container.reload_shop_items()
