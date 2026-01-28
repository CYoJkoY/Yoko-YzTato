extends RangedWeapon

# EFFECT : upgrade_killed_enemies
var effect_kill_count: Dictionary = {}
var connection_ids = {}
var old_projectiles: Array = []

# EFFECT : chimera_weapon_effect
var current_chimera_projs: Array = []
var current_chimera_projs_textures_paths: Array = []
var current_chimera_texture_sets: Array = []

# EFFECT : boomerang_weapon_effect
var active_boomerangs: Array = []
var max_damage_mul: float = 0.0
var is_boomerang: bool = false
var is_returning: bool = false
var knockback_only_back: bool = false
var wait_until_return: bool = true

# EFFECT : leave_fire
var _burning_particles_manager = null

# EFFECT : gain_stat_when_killed_scaling_single
var kill_count: Dictionary = {}
var effect_single_kill_count: Dictionary = {}

# EFFECT : vine_trap
onready var _entity_spawner = get_tree().current_scene.get_node("EntitySpawner")

# =========================== Extention =========================== #
func _ready():
    _yztato_boomerang_ready()
    _yztato_leave_fire_ready()

func shoot() -> void:
    if is_boomerang:
        _yztato_boomerang_shoot()
        return

    .shoot()

func init_stats(at_wave_begin:bool = true)-> void :
    .init_stats(at_wave_begin)
    _yztato_chimera_init_stats()

func on_projectile_shot(projectile: Node2D) -> void :
    .on_projectile_shot(projectile)
    _yztato_boomerang_on_projectile_shot(projectile)
    _yztato_upgrade_on_projectile_shot(projectile)

func on_weapon_hit_something(thing_hit: Node, damage_dealt: int, hitbox: Hitbox) -> void:
    .on_weapon_hit_something(thing_hit, damage_dealt, hitbox)
    if thing_hit._burning != null: _yztato_leave_fire(thing_hit, player_index)
    _yztato_multi_hit(thing_hit, damage_dealt, player_index)
    _yztato_vine_trap(thing_hit, player_index)
    _yztato_chal_on_weapon_hit_something(hitbox)

func on_killed_something(_thing_killed: Node, hitbox: Hitbox) -> void:
    .on_killed_something(_thing_killed, hitbox)
    _yztato_gain_stat_when_killed_scaling_single()
    _yztato_upgrade_when_killed_enemies()

func should_shoot()->bool:
    var should_shoot: bool = .should_shoot()
    should_shoot = _yztato_can_attack_while_moving(should_shoot)
    
    return should_shoot

# =========================== Custom =========================== #
func _yztato_upgrade_when_killed_enemies() -> void:
    for effect in effects:
        if effect.custom_key_hash != Utils.yztato_upgrade_when_killed_enemies_hash: continue
        if _enemies_killed_this_wave_count % effect.value != 0: continue
    
        var target_weapon_id_hash: int = effect.key_hash

        if !old_projectiles.empty():
            for projectile in old_projectiles:
                if is_instance_valid(projectile):
                    projectile.queue_free()

        _parent.yz_change_weapon(weapon_pos, target_weapon_id_hash)
        break

func _yztato_upgrade_on_projectile_shot(projectile: Node2D)-> void:
    for effect in effects:
        if effect.custom_key_hash != Utils.yztato_upgrade_when_killed_enemies_hash: continue

        old_projectiles.push_back(projectile)

        if not projectile.is_connected("has_stopped", self, "yz_on_projectile_stopped"):
            projectile.connect("has_stopped", self, "yz_on_projectile_stopped")

    return

func _yztato_chimera_init_stats()-> void:
    for effect in effects:
        if effect.get_id() != "yztato_chimera_weapon": continue
        
        for proj_stats in effect.chimera_projectile_stats:
            var projectile_instance = proj_stats.projectile_scene.instance()
            var sprite_node = projectile_instance.get_node_or_null("Sprite")
            current_chimera_projs_textures_paths.push_back(sprite_node.texture.resource_path)
            projectile_instance.queue_free()
            current_chimera_projs.push_back(WeaponService.init_ranged_stats(proj_stats, player_index))
        
        for proj_texture_set in effect.chimera_texture_sets:
            current_chimera_texture_sets.append(proj_texture_set)

func _yztato_boomerang_on_projectile_shot(projectile: Node2D)-> void:
    if is_boomerang:
        active_boomerangs.append(projectile)
        _hitbox.damage *= 1 + max_damage_mul
        if knockback_only_back: _hitbox.set_knockback(Vector2.ZERO, 0.0, 0.0)

        if not projectile.is_connected("returned_to_player", self, "yz_on_projectile_returned"):
            projectile.connect("returned_to_player", self, "yz_on_projectile_returned")

func _yztato_boomerang_shoot() -> void:
    _nb_shots_taken += 1
    var original_stats: RangedWeaponStats
    for projectile_count in _stats_every_x_shots:
        
        if _nb_shots_taken % projectile_count == 0:
            original_stats = current_stats
            current_stats = _stats_every_x_shots[projectile_count]

    for effect in effects:
        if effect.key_hash == Keys.reload_turrets_on_shoot_hash:
            emit_signal("wanted_to_reset_turrets_cooldown")

    update_current_spread()
    update_knockback()

    var target = current_stats.max_range if is_manual_aim() else _current_target[1]
    
    if wait_until_return and !is_returning:
        _shooting_behavior.shoot(target)
        is_returning = true
    elif !wait_until_return:
        _shooting_behavior.shoot(target)

    if wait_until_return:
        _current_cooldown = Utils.LARGE_NUMBER
    else:
        _current_cooldown = get_next_cooldown()

    if (is_big_reload_active() or current_stats.additional_cooldown_every_x_shots == - 1) and stats.custom_on_cooldown_sprite != null:
        update_sprite(stats.custom_on_cooldown_sprite)

    if original_stats:
        current_stats = original_stats

func _yztato_boomerang_ready() -> void:
    for effect in effects:
        if effect.get_id() == "yztato_boomerang_weapon":
            is_boomerang = true
            max_damage_mul = effect.max_damage_mul
            knockback_only_back = effect.knockback_only_back
            wait_until_return = effect.boomerang_wait

func _yztato_leave_fire_ready() -> void:
    _burning_particles_manager = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/burning_particles_manager.gd").new()
    get_tree().current_scene.call_deferred("add_child", _burning_particles_manager)

func _yztato_leave_fire(thing_hit: Node, player_index: int) -> void:
    for fire in effects:
        if fire.get_id() != "yztato_leave_fire": continue
        var new_fire = _burning_particles_manager.get_burning_particle()
        if new_fire == null: return
        call_deferred("yz_activate_burning_particle", new_fire,
        thing_hit.global_position, thing_hit._burning,
        fire.scale, fire.duration)
        return

    var effect_leave_fire: Array = RunData.get_player_effect(Utils.yztato_leave_fire_hash, player_index)
    if !effect_leave_fire.empty():
        for fire in effect_leave_fire:
            var new_fire = _burning_particles_manager.get_burning_particle()
            if new_fire != null:
                call_deferred("yz_activate_burning_particle", new_fire,
                thing_hit.global_position, thing_hit._burning,
                fire[3], fire[2])

func _yztato_gain_stat_when_killed_scaling_single() -> void:
    kill_count[weapon_id] = kill_count.get(weapon_id, 0) + 1
    for effect_index in effects.size():
        var effect = effects[effect_index]
        effect_single_kill_count[effect_index] = effect_single_kill_count.get(effect_index, kill_count[weapon_id] - 1) + 1
        
        if effect.get_id() == "yztato_gain_stat_when_killed_single_scaling" and \
           effect_single_kill_count[effect_index] % int(effect.value + Utils.get_stat(effect.scaling_stat, player_index) * effect.scaling_percent) == 0:
            RunData.add_stat(effect.stat, effect.stat_nb, player_index)
            RunData.yz_add_effect_tracking_value(effect.tracking_key, effect.stat_nb, player_index)

    RunData.emit_signal("stats_updated", player_index)

func _apply_multi_hit_effect(thing_hit: Node, damage_dealt: int, effect_data: Array, player_index: int) -> void:
    for _i in range(effect_data[0]):
        var args = TakeDamageArgs.new(player_index)
        var damage_taken: Array = thing_hit.take_damage(damage_dealt * effect_data[1] / 100, args)
        RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)

func _yztato_multi_hit(thing_hit: Node, damage_dealt: int, player_index: int) -> void:
    for effect in effects:
        if effect.get_id() == "yztato_multi_hit":
            _apply_multi_hit_effect(thing_hit, damage_dealt, [effect.value, effect[1]], player_index)
            return
    
    var effect_multi_hit: Array = RunData.get_player_effect(Utils.yztato_multi_hit_hash, player_index)
    if !effect_multi_hit.empty():
        for effect in effect_multi_hit:
            _apply_multi_hit_effect(thing_hit, damage_dealt, effect, player_index)

func _spawn_vine_traps(thing_hit: Node, trap_count: int, player_index: int, trap_data) -> void:
    for _i in range(trap_count):
        var pos = _entity_spawner.get_spawn_pos_in_area(thing_hit.global_position, 20)
        var queue = _entity_spawner.queues_to_spawn_structures[player_index]
        queue.push_back([EntityType.STRUCTURE, trap_data.scene, pos, trap_data])

func _yztato_vine_trap(thing_hit: Node, player_index: int) -> void:
    for effect in effects:
        if effect.get_id() == "yztato_vine_trap":
            var count: int = effect.trap_count
            var chance: float = effect.chance / 100.0

            if Utils.get_chance_success(chance):
                effect.weapon_pos = weapon_pos
                _spawn_vine_traps(thing_hit, count, player_index, effect)

            return

    var vine_trap_effects: Array = RunData.get_player_effect(Utils.yztato_vine_trap_hash, player_index)
    if !vine_trap_effects.empty():
        for effect_data in vine_trap_effects:
            var count: int = effect_data[0]
            var chance: float = effect_data[1] / 100.0
            
            if Utils.get_chance_success(chance):
                _spawn_vine_traps(thing_hit, count, player_index, effect_data[2])

func _yztato_can_attack_while_moving(should_shoot: bool) -> bool:
    if should_shoot: 
        for effect in effects:
            if effect.get_id() == "yztato_can_attack_while_moving":
                return _parent._current_movement == Vector2.ZERO

    return should_shoot

func _yztato_chal_on_weapon_hit_something(hitbox: Hitbox) -> void:
    ### sudden_misfortune ###
    if hitbox == null: return 
    var attack_id: = hitbox.player_attack_id
    if attack_id < 0: return 
    var attack_hit_count = _hit_count_by_attack_id.get(attack_id, 0)
    attack_hit_count += 1
    _hit_count_by_attack_id[attack_id] = attack_hit_count
    ChallengeService.try_complete_challenge(Utils.chal_sudden_misfortune_hash, attack_hit_count)

    ### one_force_subdue_ten ###
    ChallengeService.try_complete_challenge(Utils.chal_one_force_subdue_ten_hash, hitbox.damage)

# =========================== Method =========================== #
func yz_on_projectile_returned(projectile: Node2D) -> void:
    active_boomerangs.erase(projectile)
    is_returning = false

    if wait_until_return:
        _current_cooldown = get_next_cooldown()

func yz_activate_burning_particle(particle, position: Vector2, burning_data, scale: float, duration: float) -> void:
    if particle != null and particle.has_method("activate"):
        particle.activate(position, burning_data)
        particle.rescale(scale)
        particle.set_duration(duration)

func yz_on_projectile_stopped(projectile: Node2D) -> void:
    old_projectiles.erase(projectile)
