extends "res://main.gd"

var YzTimers: Array = []

# EFFECT : special_picked_up_change_stat
var special_picked_up_count: Dictionary = {}

# =========================== Extension =========================== #
func _ready() -> void:
    _yztato_init_trigger_subeffect_on_specific_stat_over_check_timer()

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

func clean_up_room() -> void:
	for timer in YzTimers: timer.stop()
	.clean_up_room()

# =========================== Custom =========================== #
func _yztato_init_trigger_subeffect_on_specific_stat_over_check_timer() -> void:
    for player_index in range(RunData.players_data.size()):
        var triggers: Array = RunData.get_player_effect(Utils.yztato_trigger_subeffect_on_specific_stat_over_hash, player_index)
        if triggers.empty(): continue

        var timer: Timer = Timer.new()
        timer.wait_time = 0.5
        timer.autostart = true
        timer.connect("timeout", self, "yz_trigger_subeffect_on_specific_stat_over", [triggers, player_index])
        add_child(timer)
        YzTimers.append(timer)

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

# =========================== Method =========================== #
func yz_trigger_subeffect_on_specific_stat_over(triggers: Array, player_index: int) -> void:
    var triggered_subeffects: Array = RunData.get_player_effect(Utils.yztato_triggered_subeffects, player_index)

    for trigger in triggers:
        var specific_stat: int = trigger.key_hash
        var stat_num: int = int(Utils.get_stat(specific_stat, player_index))
        var sub_effects: Array = trigger.sub_effects
        var over_types: Array = trigger.over_types
        var stat_over_values: Array = trigger.stat_over_values

        for i in range(stat_over_values.size()):
            var over_type: int = over_types[i]
            var stat_over_value: int = stat_over_values[i]
            var sub_effect: Effect = sub_effects[i]
            var sub_effect_unid: int = Utils.ncl_generate_composite_hash([
                trigger.key_hash,
                trigger.custom_key_hash,
                sub_effect.key_hash,
                sub_effect.custom_key_hash,
                Keys.generate_hash(sub_effect.get_id())
            ])

            match over_type:
                0: # Equal
                    match (stat_num == stat_over_value or stat_over_value == Utils.LARGE_NUMBER): 
                        true: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, true)
                        false: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, false)
                1: # Up_E
                    match stat_num >= stat_over_value: 
                        true: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, true)
                        false: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, false)
                2: # Down_E
                    match stat_num <= stat_over_value: 
                        true: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, true)
                        false: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, false)
                3: # Up
                    match stat_num > stat_over_value: 
                        true: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, true)
                        false: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, false)
                4: # Down
                    match stat_num < stat_over_value: 
                        true: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, true)
                        false: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, false)
                5: # Equal_Multi
                    match stat_num % stat_over_value == 0 or stat_over_value == Utils.LARGE_NUMBER: 
                        true: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, true)
                        false: yz_process_trigger_subeffect([sub_effect], player_index, triggered_subeffects, sub_effect_unid, false)

func yz_process_trigger_subeffect(
    sub_effect: Array, 
    player_index: int, 
    triggered_subeffects: Array, 
    sub_effect_unid: int, 
    is_append: bool
) -> void:
    match is_append:
        true:
            if !triggered_subeffects.has(sub_effect_unid): 
                RunData.apply_effects_array(sub_effect, player_index)
                triggered_subeffects.append(sub_effect_unid)
        false:
            if triggered_subeffects.has(sub_effect_unid): 
                RunData.unapply_effects_array(sub_effect, player_index)
                triggered_subeffects.erase(sub_effect_unid)
