extends "res://singletons/weapon_service.gd"

# ══════════════════════════════════════════ Constants ══════════════════════════════════════════ #
const BURNING_PARTICLE_TSCN = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/ground_burning_particles.tscn")

# ══════════════════════════════════════════ Variables ══════════════════════════════════════════ #
var _burning_particle_pool_id: int = Keys.generate_hash(BURNING_PARTICLE_TSCN.resource_path)
var _yz_main_cache: Main = null
var _yz_entity_spawner_cache: EntitySpawner = null

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _apply_weapon_scaling_stat_effects(scaling_stats: Array, player_index: int) -> Array:
    var new_stats: Array = ._apply_weapon_scaling_stat_effects(scaling_stats, player_index)
    new_stats = _yztato_apply_damage_scaling(new_stats, player_index)
    return new_stats

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _yztato_apply_damage_scaling(new_stats: Array, player_index: int) -> Array:
    var damage_scaling_effects: Array = RunData.get_player_effect(Utils.yztato_damage_scaling_hash, player_index)
    if damage_scaling_effects.empty():
        return new_stats

    var result_stats: Array = new_stats.duplicate(true)
    for effect in damage_scaling_effects:
        var stat: float = Utils.get_stat(effect[0], player_index)
        var value: float = effect[1]
        var scaling_stats: Array = effect[2]
        var num: float = stat / value

        for scaling_stat in scaling_stats:
            var stat_hash: int = scaling_stat[0]
            var add_value: float = scaling_stat[1] * num
            var existing = _yztato_find_scaling_stat(stat_hash, result_stats)
            if existing != null:
                existing[1] += add_value
            else:
                result_stats.append([stat_hash, add_value])

    return result_stats

func _yztato_find_scaling_stat(stat_hash: int, stats_array: Array):
    for item in stats_array:
        if item[0] == stat_hash:
            return item
    return null

func _yztato_get_main() -> Main:
    if _yz_main_cache == null:
        _yz_main_cache = Utils.get_scene_node()
    return _yz_main_cache

func _yztato_get_entity_spawner() -> EntitySpawner:
    if _yz_entity_spawner_cache == null:
        var main: Main = _yztato_get_main()
        if main != null:
            _yz_entity_spawner_cache = main._entity_spawner
    return _yz_entity_spawner_cache

func _yztato_get_burning_particle(main: Main) -> CPUParticles2D:
    var particle: CPUParticles2D = main.get_node_from_pool(_burning_particle_pool_id, main._effects)
    if particle == null:
        particle = BURNING_PARTICLE_TSCN.instance()
        particle.visible = false
        particle.emitting = false
        main._effects.add_child(particle)
        particle.on_deactivate_callback = funcref(self, "_yztato_recycle_burning_particle")
    return particle

func _yztato_recycle_burning_particle(particle: CPUParticles2D) -> void:
    if particle == null:
        return
    particle.on_deactivate_callback = null
    particle.visible = false
    particle.emitting = false
    var main: Main = _yztato_get_main()
    if main != null:
        main.add_node_to_pool(particle, _burning_particle_pool_id)

# ══════════════════════════════════════════ Method ══════════════════════════════════════════ #
func yz_multi_hit(effects: Array, weapon_pos: int, thing_hit: Node, damage_dealt: int, player_index: int) -> void:
    if not thing_hit:
        return

    # Weapon effects
    for effect in effects:
        if effect.get_id() == "yztato_multi_hit":
            var dmg_percent: float = effect.damage_percent / 100.0
            for _i in effect.value:
                var args: TakeDamageArgs = TakeDamageArgs.new(player_index)
                var damage_taken: Array = thing_hit.take_damage(damage_dealt * dmg_percent, args)
                RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)
            return

    # Player effects
    var effect_multi_hit: Array = RunData.get_player_effect(Utils.yztato_multi_hit_hash, player_index)
    for effect in effect_multi_hit:
        var dmg_percent: float = effect[1] / 100.0
        for _i in effect[0]:
            var args: TakeDamageArgs = TakeDamageArgs.new(player_index)
            var damage_taken: Array = thing_hit.take_damage(damage_dealt * dmg_percent, args)
            RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)

func yz_vine_trap(effects: Array, weapon_pos: int, thing_hit: Node, player_index: int) -> void:
    if not thing_hit:
        return
    var spawner: EntitySpawner = _yztato_get_entity_spawner()
    if spawner == null:
        return

    var spawn_pos: Vector2 = thing_hit.global_position

    # Weapon effects
    for effect in effects:
        if effect.get_id() == "yztato_vine_trap":
            if Utils.get_chance_success(effect.chance / 100.0):
                var vine_trap: StructureEffect = effect
                var queue: Array = spawner.queues_to_spawn_structures[player_index]
                for _i in effect.trap_count:
                    var pos: Vector2 = spawner.get_spawn_pos_in_area(spawn_pos, 20)
                    vine_trap.weapon_pos = weapon_pos
                    queue.append([EntityType.STRUCTURE, vine_trap.scene, pos, vine_trap])
                break

    # Player effects
    var vine_trap_effects: Array = RunData.get_player_effect(Utils.yztato_vine_trap_hash, player_index)
    for effect_data in vine_trap_effects:
        if Utils.get_chance_success(effect_data[1] / 100.0):
            var vine_trap: StructureEffect = effect_data[2]
            var queue: Array = spawner.queues_to_spawn_structures[player_index]
            for _i in effect_data[0]:
                var pos: Vector2 = spawner.get_spawn_pos_in_area(spawn_pos, 20)
                queue.append([EntityType.STRUCTURE, vine_trap.scene, pos, vine_trap])

func yz_leave_fire(effects: Array, thing_hit: Node, player_index: int) -> void:
    var main: Main = _yztato_get_main()
    if main == null:
        return

    # Weapon effects
    for fire in effects:
        if fire.get_id() == "yztato_leave_fire":
            var particle: CPUParticles2D = _yztato_get_burning_particle(main)
            if particle != null:
                particle.activate(thing_hit.global_position, thing_hit._burning)
                particle.rescale(fire.scale)
                particle.set_duration(fire.duration)
                main._on_emit_fire_particle(particle)
            return

    # Player effects
    var effect_leave_fire: Array = RunData.get_player_effect(Utils.yztato_leave_fire_hash, player_index)
    for fire in effect_leave_fire:
        var particle: CPUParticles2D = _yztato_get_burning_particle(main)
        if particle != null:
            particle.activate(thing_hit.global_position, thing_hit._burning)
            particle.rescale(fire[3])
            particle.set_duration(fire[2])
            main._on_emit_fire_particle(particle)

func yz_summon_lightning(effects: Array, weapon_pos: int, thing_hit: Node, player_index: int) -> void:
    if not thing_hit:
        return
    var spawner: EntitySpawner = _yztato_get_entity_spawner()
    if spawner == null:
        return

    var spawn_pos: Vector2 = thing_hit.global_position

    # Weapon effects
    for effect in effects:
        if effect.get_id() == "yztato_summon_lightning":
            if Utils.get_chance_success(effect.chance / 100.0):
                var lightning: StructureEffect = effect
                var queue: Array = spawner.queues_to_spawn_structures[player_index]
                for _i in effect.lightning_count:
                    var pos: Vector2 = spawner.get_spawn_pos_in_area(spawn_pos, 30)
                    lightning.weapon_pos = weapon_pos
                    queue.append([EntityType.STRUCTURE, lightning.scene, pos, lightning])
                break

    # Player effects
    var summon_lightning_effects: Array = RunData.get_player_effect(Utils.yztato_summon_lightning_hash, player_index)
    for effect_data in summon_lightning_effects:
        if Utils.get_chance_success(effect_data[1] / 100.0):
            var lightning: StructureEffect = effect_data[2]
            var queue: Array = spawner.queues_to_spawn_structures[player_index]
            for _i in effect_data[0]:
                var pos: Vector2 = spawner.get_spawn_pos_in_area(spawn_pos, 30)
                queue.append([EntityType.STRUCTURE, lightning.scene, pos, lightning])

func yz_gain_stat_when_killed_scaling_single(effects: Array, kill_count_dict: Dictionary, player: Player, player_index: int) -> void:
    for effect_index in range(effects.size()):
        var effect = effects[effect_index]
        if effect.get_id() != "yztato_gain_stat_when_killed_single_scaling":
            continue

        kill_count_dict[effect_index] = kill_count_dict.get(effect_index, 0) + 1
        var scaling_value: int = effect.value + Utils.get_stat(effect.scaling_stat_hash, player_index) * effect.scaling_percent as int
        if scaling_value <= 0 or kill_count_dict[effect_index] % scaling_value != 0:
            continue

        kill_count_dict[effect_index] = 0
        RunData.add_stat(effect.stat_hash, effect.stat_nb, player_index)
        RunData.ncl_add_effect_tracking_value(effect.tracking_key_hash, effect.stat_nb, player_index)
        if effect.stat_hash == Keys.hit_protection_hash:
            player._hit_protection += effect.stat_nb

func yz_upgrade_when_killed_enemies(effects: Array, enemies_killed_this_wave_count: int, weapon_pos: int, player_index: int) -> void:
    for effect in effects:
        if effect.custom_key_hash != Utils.yztato_upgrade_when_killed_enemies_hash:
            continue
        if enemies_killed_this_wave_count % effect.value == 0:
            Utils.ncl_change_weapon_within_run(weapon_pos, effect.key_hash, player_index)

func yz_can_attack_while_moving(effects: Array, player: Player, should_shoot: bool) -> bool:
    if not should_shoot:
        return false
    for effect in effects:
        if effect.get_id() == "yztato_cant_attack_while_moving":
            return player._current_movement == Vector2.ZERO
    return should_shoot
