extends "res://global/entity_spawner.gd"

# EFFECT : gain_stat_when_killed_single_scaling
var kill_count: Dictionary = {}
var effect_single_kill_count: Dictionary = {}

# EFFECT : gain_random_primary_stat
var primary_stats: Array = RunData.primary_stats_list
var kill_count_2: Dictionary = {}

### hellfire ###
var enemies_killed_is_burning: int = 0

# =========================== Extension =========================== #
func _on_enemy_died(enemy: Node2D, _args: Entity.DieArgs) -> void:
    ._on_enemy_died(enemy, _args)
    if !_cleaning_up:
        _yztato_gain_stat_when_killed_single_scaling_on_enemy_died()
        _yztato_blood_rage_on_enemy_died()
        _yztato_chal_on_enemy_died(enemy)

func on_enemy_charmed(enemy: Entity) -> void:
    .on_enemy_charmed(enemy)
    _yztato_chal_on_enemy_charmed(charmed_enemies)

# =========================== Custom =========================== #
func _yztato_gain_stat_when_killed_single_scaling_on_enemy_died() -> void:
    for player_index in RunData.players_data.size():
        var current_kill_count = kill_count.get(player_index, 0) + 1
        kill_count[player_index] = current_kill_count

        var effect_items: Array = RunData.get_player_effect(Utils.yztato_gain_stat_when_killed_single_scaling_hash, player_index)
        for effect_index in effect_items.size():
            var effect = effect_items[effect_index]
            
            if effect[0] != 0: continue

            var initial_count = current_kill_count - 1
            var current_effect_count = effect_single_kill_count.get(effect_index, initial_count) + 1
            effect_single_kill_count[effect_index] = current_effect_count

            var scaling_value = effect[1] + Utils.get_stat(effect[4], player_index) * effect[5]
            
            if scaling_value > 0 and current_effect_count % int(scaling_value) == 0:
                effect_single_kill_count[effect_index] = 0
                RunData.add_stat(effect[2], effect[3], player_index)
                RunData.yz_add_effect_tracking_value(effect[6], effect[3], player_index)

func _yztato_blood_rage_on_enemy_died() -> void:
    for player_index in RunData.players_data.size():
        if _players[player_index] and is_instance_valid(_players[player_index]):
            _players[player_index].yz_on_enemy_killed_reset_blood_rage()

func _yztato_chal_on_enemy_charmed(charmed_enemies: Array) -> void:
    ### dark_forest_rule ###
    ChallengeService.try_complete_challenge(Utils.chal_dark_forest_rule_hash, charmed_enemies.size())

func _yztato_chal_on_enemy_died(enemy: Entity) -> void:
    ### hellfire ###
    if enemy._is_burning: enemies_killed_is_burning += 1
    ChallengeService.try_complete_challenge(Utils.chal_hellfire_hash, enemies_killed_is_burning)
