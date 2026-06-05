extends "res://singletons/weapon_service.gd"

# EFFECT: leave_fire
var _burning_particles_manager: Node = null

# EFFECT: vine_trap
var entity_spawner: EntitySpawner = null

# =========================== Extension =========================== #
func _apply_weapon_scaling_stat_effects(scaling_stats: Array, player_index: int) -> Array:
    var new_stats: Array =._apply_weapon_scaling_stat_effects(scaling_stats, player_index)
    new_stats = _yztato_scaling_damage(new_stats, player_index)

    return new_stats

# =========================== Custom =========================== #
func _yztato_scaling_damage(new_stats: Array, player_index: int) -> Array:
    var damage_scaling_effects: Array = RunData.get_player_effect(Utils.yztato_damage_scaling_hash, player_index)
    if damage_scaling_effects.empty(): return new_stats

    for effect in damage_scaling_effects:
        var stat: float = Utils.get_stat(effect[0], player_index)
        var value: float = effect[1]
        var scaling_stats: Array = effect[2]
        var num: float = stat / value

        var new_scaling_stats = new_stats.duplicate(true)
        for scaling_stat in scaling_stats:
            var scaling_stat_hash: int = scaling_stat[0]
            var scaling_stat_value: float = scaling_stat[1]
            var existing_scaling_stat = find_scaling_stat(scaling_stat_hash, new_scaling_stats)
            if existing_scaling_stat != null: existing_scaling_stat[1] += scaling_stat_value * num
            else: new_scaling_stats.append([scaling_stat_hash, scaling_stat_value * num])

        return new_scaling_stats

    return new_stats

# =========================== Method =========================== #
func yz_multi_hit(effects: Array, weapon_pos: int, thing_hit: Node, damage_dealt: int, player_index: int) -> void:
    # Check weapon effects first
    for effect in effects:
        if effect.get_id() != "yztato_multi_hit": continue

        for _i in effect.value:
            var args = TakeDamageArgs.new(player_index)
            var damage_taken: Array = thing_hit.take_damage(damage_dealt * effect.damage_percent / 100, args)
            RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)
        return

    # Check player effects
    var effect_multi_hit = RunData.get_player_effect(Utils.yztato_multi_hit_hash, player_index)
    for effect in effect_multi_hit:
        for _i in effect[0]:
            var args = TakeDamageArgs.new(player_index)
            var damage_taken: Array = thing_hit.take_damage(damage_dealt * effect[1] / 100, args)
            RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)

func yz_vine_trap(effects: Array, weapon_pos: int, thing_hit: Node, player_index: int) -> void:
    if entity_spawner == null: entity_spawner = Utils.get_scene_node()._entity_spawner

    var spawn_pos: Vector2 = thing_hit.global_position

    # Check weapon effects first
    for effect in effects:
        if effect.get_id() != "yztato_vine_trap": continue

        var count: int = effect.trap_count
        var chance: float = effect.chance / 100.0

        if !Utils.get_chance_success(chance): continue

        var vine_trap: StructureEffect = effect
        for _i in count:
            var pos = entity_spawner.get_spawn_pos_in_area(spawn_pos, 20)
            var queue = entity_spawner.queues_to_spawn_structures[player_index]
            vine_trap.weapon_pos = weapon_pos
            queue.append([EntityType.STRUCTURE, vine_trap.scene, pos, vine_trap])

    # Check player effects
    var vine_trap_effects = RunData.get_player_effect(Utils.yztato_vine_trap_hash, player_index)
    for effect_data in vine_trap_effects:
        var count: int = effect_data[0]
        var chance: float = effect_data[1] / 100.0
        
        if !Utils.get_chance_success(chance): continue

        var vine_trap: StructureEffect = effect_data[2]
        for _i in count:
            var pos = entity_spawner.get_spawn_pos_in_area(spawn_pos, 20)
            var queue = entity_spawner.queues_to_spawn_structures[player_index]
            queue.append([EntityType.STRUCTURE, vine_trap.scene, pos, vine_trap])

func yz_leave_fire(effects: Array, thing_hit: Node, player_index: int) -> void:
    if _burning_particles_manager == null:
        _burning_particles_manager = load("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/burning_particles_manager.gd").new()
        get_tree().current_scene.call_deferred("add_child", _burning_particles_manager)

    # Check effects first
    for fire in effects:
        if fire.get_id() != "yztato_leave_fire": continue

        var new_fire = _burning_particles_manager.get_burning_particle()
        if !new_fire: continue
        
        call_deferred(
            "yz_activate_burning_particle", new_fire,
            thing_hit.global_position, thing_hit._burning,
            fire.scale, fire.duration
        )

    # Check player effects
    var effect_leave_fire = RunData.get_player_effect(Utils.yztato_leave_fire_hash, player_index)
    if !effect_leave_fire.empty():
        for fire in effect_leave_fire:
            var new_fire = _burning_particles_manager.get_burning_particle()
            if !new_fire: continue

            call_deferred(
                "yz_activate_burning_particle", new_fire,
                thing_hit.global_position, thing_hit._burning,
                fire[3], fire[2]
            )

func yz_gain_stat_when_killed_scaling_single(effects: Array, gain_stat_when_killed_single_scaling_killed_count: Dictionary, player: Player, player_index: int) -> void:
    for effect_index in effects.size():
        var effect = effects[effect_index]
        if effect.get_id() != "yztato_gain_stat_when_killed_single_scaling": continue

        gain_stat_when_killed_single_scaling_killed_count[effect_index] = gain_stat_when_killed_single_scaling_killed_count.get(effect_index, 0) + 1
        var scaling_value: int = effect.value + Utils.get_stat(effect.scaling_stat_hash, player_index) * effect.scaling_percent as int
        if scaling_value <= 0 or gain_stat_when_killed_single_scaling_killed_count[effect_index] % scaling_value != 0: continue

        gain_stat_when_killed_single_scaling_killed_count[effect_index] = 0 # For dynamic scaling_value
        RunData.add_stat(effect.stat_hash, effect.stat_nb, player_index)
        RunData.ncl_add_effect_tracking_value(effect.tracking_key_hash, effect.stat_nb, player_index)

        # Update when first add hit_protection
        if effect.stat_hash == Keys.hit_protection_hash: player._hit_protection += effect.stat_nb

func yz_upgrade_when_killed_enemies(effects: Array, _enemies_killed_this_wave_count: int, weapon_pos: int, player_index: int) -> void:
    for effect in effects:
        if effect.custom_key_hash != Utils.yztato_upgrade_when_killed_enemies_hash: continue
        if _enemies_killed_this_wave_count % effect.value != 0: return
        
        var target_weapon_id_hash: int = effect.key_hash

        Utils.ncl_change_weapon_within_run(weapon_pos, target_weapon_id_hash, player_index)

func yz_can_attack_while_moving(effects: Array, player: Player, should_shoot: bool) -> bool:
    if !should_shoot: return false

    for effect in effects:
        if effect.get_id() == "yztato_can_attack_while_moving":
            should_shoot = player._current_movement == Vector2.ZERO
            break

    return should_shoot
