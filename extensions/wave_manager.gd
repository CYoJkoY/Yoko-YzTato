extends "res://zones/wave_manager.gd"

# =========================== Extention =========================== #
func init(p_wave_timer: Timer, zone_data: ZoneData, wave_data: Resource)->void :
    .init(p_wave_timer, zone_data, wave_data)
    _yztato_extra_enemies_next_waves_init(wave_data)

# =========================== Custom =========================== #
func _yztato_extra_enemies_next_waves_init(current_wave_data: Resource):
    for player_index in RunData.get_player_count():
        var effects: Array = RunData.get_player_effect(Utils.yztato_extra_enemies_next_waves_hash, player_index)
        var remaining_effects = []
        for effect in effects:
            var group_data = load(effect[0])
            var group_count = effect[1]
            var waves_remaining = effect[2]
            
            for _i in range(group_count):
                var new_group = group_data
                if group_data.is_boss:
                    new_group = init_elite_group([effect[2]])
                current_wave_data.groups_data.push_back(new_group)
            
            waves_remaining -= 1
            if waves_remaining > 0:
                var new_effect = [effect[0], group_count, waves_remaining]
                remaining_effects.push_back(new_effect)
        
        effects = remaining_effects
