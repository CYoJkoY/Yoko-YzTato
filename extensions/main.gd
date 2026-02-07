extends "res://main.gd"

# EFFECT : special_picked_up_change_stat
var special_picked_up_count: Dictionary = {}

# =========================== Extension =========================== #
func _on_EndWaveTimer_timeout() -> void:
    ._on_EndWaveTimer_timeout()
    _yztato_destory_weapons()
    _yztato_set_stat()

func on_consumable_picked_up(consumable: Node, player_index: int) -> void:
    .on_consumable_picked_up(consumable, player_index)
    _yztato_special_picked_up_change_stat(consumable, player_index)

func on_levelled_up(player_index: int) -> void:
    .on_levelled_up(player_index)
    _yztato_stats_chance_on_level_up(player_index)

# =========================== Custom =========================== #
func _yztato_destory_weapons() -> void:
    for player_index in RunData.players_data.size():
        var yztato_destory_weapon: Array = RunData.get_player_effect(Utils.yztato_destory_weapons_hash, player_index)
        if yztato_destory_weapon.size() > 0:
            for weapon_id in yztato_destory_weapon:
                for i in weapon_id[1]:
                    var old_weapons: Array = RunData.get_player_weapons(player_index)
                    var new_weapons: Array = []
                    for new_weapon in old_weapons:
                        if new_weapon.weapon_id_hash == weapon_id[0]:
                            new_weapons.append(new_weapon)
                    RunData.remove_all_weapons(player_index)
                    for new_weapon in new_weapons:
                        RunData.apply_item_effects(new_weapon, player_index)
                    RunData.players_data[player_index].weapons = new_weapons

func _yztato_set_stat() -> void:
    for player_index in RunData.players_data.size():
        var set_stat: Array = RunData.get_player_effect(Utils.yztato_set_stat_hash, player_index)
        if set_stat.size() > 0:
            for stat_id in set_stat:
                RunData.players_data[player_index].effects[stat_id[0]] = stat_id[1]

func _yztato_special_picked_up_change_stat(consumable: Node, player_index: int) -> void:
    var special_picked_up_change_stat: Array = RunData.get_player_effect(Utils.yztato_special_picked_up_change_stat_hash, player_index)
    if special_picked_up_change_stat.size() > 0:
        for change in special_picked_up_change_stat:
            if consumable.consumable_data.my_id_hash == change[0]:
                special_picked_up_count[change[0]] = special_picked_up_count.get(change[0], 0) + 1
                if special_picked_up_count[change[0]] % int(change[1]) == 0:
                    RunData.add_stat(change[2], change[3], player_index)

func _yztato_stats_chance_on_level_up(player_index: int) -> void:
    for chance_effect in RunData.get_player_effect(Utils.yztato_stats_chance_on_level_up_hash, player_index):
        var stat_hash: int = chance_effect[0]
        var stat_increase: int = chance_effect[1]
        var chance: int = chance_effect[2]
        var tracking_key_hash: int = chance_effect[3]
        
        if Utils.get_chance_success(chance / 100.0):
            RunData.add_stat(stat_hash, stat_increase, player_index)
            RunData.ncl_add_effect_tracking_value(tracking_key_hash, stat_increase, player_index)
