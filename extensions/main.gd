extends "res://main.gd"

# EFFECT : special_picked_up_change_stat
var special_picked_up_count: Dictionary = {}

# =========================== Extention =========================== #
# When the wave ends
func _on_WaveTimer_timeout()->void:
	._on_WaveTimer_timeout()
	_yztato_gain_items_end_of_wave()
	_yztato_destory_weapons()
	_yztato_set_stat()

func _on_EndWaveTimer_timeout()->void:
	_yztato_blood_rage_clean()
	._on_EndWaveTimer_timeout()

func on_consumable_picked_up(consumable: Node, player_index: int)->void :
	.on_consumable_picked_up(consumable, player_index)
	_yztato_special_picked_up_change_stat(consumable, player_index)

func on_levelled_up(player_index: int)->void :
	.on_levelled_up(player_index)
	_yztato_stats_chance_on_level_up(player_index)

# =========================== Custom =========================== #
func _yztato_gain_items_end_of_wave()-> void:
	for player_index in RunData.players_data.size():
		var gain_item = RunData.get_player_effect("yztato_gain_items_end_of_wave",player_index)
		if gain_item.size() > 0:
			for item_id in gain_item:
				for i in item_id[1]:
					var item = ItemService.get_element(ItemService.items, item_id[0])
					RunData.add_item(item, player_index)

func _yztato_destory_weapons()-> void:
	for player_index in RunData.players_data.size():
		var yztato_destory_weapon = RunData.get_player_effect("yztato_destory_weapons",player_index)
		if yztato_destory_weapon.size() > 0:
			for weapon_id in yztato_destory_weapon:
				for i in weapon_id[1]:
					var old_weapons: Array = RunData.get_player_weapons(player_index)
					var new_weapons: Array = []
					for new_weapon in old_weapons:
						if new_weapon.weapon_id == weapon_id[0]:
							new_weapons.append(new_weapon)
					RunData.remove_all_weapons(player_index)
					for new_weapon in new_weapons:
						RunData.apply_item_effects(new_weapon,player_index)
					RunData.players_data[player_index].weapons = new_weapons

func _yztato_set_stat()-> void:
	for player_index in RunData.players_data.size():
		var set_stat = RunData.get_player_effect("yztato_set_stat",player_index)
		if set_stat.size() > 0:
			for stat_id in set_stat:
				RunData.players_data[player_index].effects[stat_id[0]] = stat_id[1]

func _yztato_special_picked_up_change_stat(consumable: Node, player_index: int)-> void:
	var special_picked_up_change_stat = RunData.get_player_effect("yztato_special_picked_up_change_stat",player_index)
	if special_picked_up_change_stat.size() > 0:
		# key, value, stat, stat_nb
		for change in special_picked_up_change_stat:
			if consumable.consumable_data.my_id == change[0]:
				special_picked_up_count[change[0]] = special_picked_up_count.get(change[0], 0) + 1
				if special_picked_up_count[change[0]] % int(change[1]) == 0:
					RunData.add_stat(change[2], change[3], player_index)

func _yztato_blood_rage_clean() -> void:
	for player_index in RunData.players_data.size():
		var blood_rage_effects = RunData.get_player_effect("yztato_blood_rage", player_index)
		if blood_rage_effects.size() > 0 and \
		_players[player_index] and is_instance_valid(_players[player_index]):
			_players[player_index]._clean_up_blood_rage_effects()

func _yztato_stats_chance_on_level_up(player_index: int) -> void:
	for chance_effect in RunData.get_player_effect("yztato_stats_chance_on_level_up", player_index):
		var stat: String = chance_effect[0]
		var stat_increase: int = chance_effect[1]
		var chance: int = chance_effect[2]
		
		if Utils.get_chance_success(chance / 100.0):
			RunData.add_stat(stat, stat_increase, player_index)

			if stat_increase > 0:
				RunData.add_tracked_value(player_index, "item_yztato_cursed_box", stat_increase, 0)
			elif stat_increase < 0:
				RunData.add_tracked_value(player_index, "item_yztato_cursed_box", abs(stat_increase) as int, 1)