extends "res://global/entity_spawner.gd"

# EFFECT : gain_stat_when_killed_single_scaling
var gain_stat_when_killed_single_scaling_killed_count: Array = [ {}, {}, {}, {}]

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
        var effect_items: Array = RunData.get_player_effect(Utils.yztato_gain_stat_when_killed_single_scaling_hash, player_index)
        var player_killed_count: Dictionary = gain_stat_when_killed_single_scaling_killed_count[player_index]
        for effect_index in effect_items.size():
            player_killed_count[effect_index] = player_killed_count.get(effect_index, 0) + 1
            var effect = effect_items[effect_index]
            var value: int = effect[0]
            var stat: int = effect[1]
            var stat_nb: int = effect[2]
            var scaling_stat: int = effect[3]
            var scaling_percent: float = effect[4]
            var tracking_key: int = effect[5]

            var scaling_value = value + Utils.get_stat(scaling_stat, player_index) * scaling_percent
            if scaling_value <= 0 or player_killed_count[effect_index] % int(scaling_value) != 0: continue

            player_killed_count[effect_index] = 0 # For dynamic scaling_value
            RunData.add_stat(stat, stat_nb, player_index)
            RunData.ncl_add_effect_tracking_value(tracking_key, stat_nb, player_index)

            # Update when first add hit_protection
            if stat == Keys.hit_protection_hash:
                _main._players[player_index]._hit_protection += stat_nb

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
