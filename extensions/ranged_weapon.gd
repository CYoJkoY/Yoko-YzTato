extends RangedWeapon

# EFFECT: upgrade_killed_enemies
var effect_kill_count: Dictionary = {}
var connection_ids = {}
var old_projectiles: Array = []

# EFFECT: chimera_weapon_effect
var current_chimera_projs: Array = []
var current_chimera_projs_textures_paths: Array = []
var current_chimera_texture_sets: Array = []

# EFFECT: boomerang_weapon_effect
var active_boomerangs: Array = []
var max_damage_mul: float = 0.0
var is_boomerang: bool = false
var is_returning: bool = false
var knockback_only_back: bool = false
var wait_until_return: bool = true

# EFFECT: gain_stat_when_killed_single_scaling
var gain_stat_when_killed_single_scaling_killed_count: Dictionary = {}

# =========================== Extension =========================== #
func _ready():
    _yztato_boomerang_ready()

func shoot() -> void:
    if is_boomerang:
        _yztato_boomerang_shoot()
        return

    .shoot()

func init_stats(at_wave_begin: bool = true) -> void:
    .init_stats(at_wave_begin)
    _yztato_chimera_init_stats()

func on_projectile_shot(projectile: Node2D) -> void:
    .on_projectile_shot(projectile)
    _yztato_boomerang_on_projectile_shot(projectile)

func on_weapon_hit_something(thing_hit: Node, damage_dealt: int, hitbox: Hitbox) -> void:
    .on_weapon_hit_something(thing_hit, damage_dealt, hitbox)
    if thing_hit._burning != null: WeaponService.yz_leave_fire(effects, thing_hit, player_index)
    WeaponService.yz_multi_hit(effects, weapon_pos, thing_hit, damage_dealt, player_index)
    WeaponService.yz_vine_trap(effects, weapon_pos, thing_hit, player_index)
    WeaponService.yz_summon_lightning(effects, weapon_pos, thing_hit, player_index)
    _yztato_chal_on_weapon_hit_something(hitbox)

func on_killed_something(_thing_killed: Node, hitbox: Hitbox) -> void:
    .on_killed_something(_thing_killed, hitbox)
    WeaponService.yz_gain_stat_when_killed_scaling_single(effects, gain_stat_when_killed_single_scaling_killed_count, _parent, player_index)
    WeaponService.yz_upgrade_when_killed_enemies(effects, _enemies_killed_this_wave_count, weapon_pos, player_index)

func should_shoot() -> bool:
    var should_shoot: bool =.should_shoot()
    should_shoot = WeaponService.yz_can_attack_while_moving(effects, _parent, should_shoot)
    
    return should_shoot

# =========================== Custom =========================== #
func _yztato_chimera_init_stats() -> void:
    for effect in effects:
        if effect.get_id() != "yztato_chimera_weapon": continue

        for proj_stats in effect.chimera_projectile_stats:
            var projectile_instance = proj_stats.projectile_scene.instance()
            var sprite_node = projectile_instance.get_node_or_null("Sprite")
            current_chimera_projs_textures_paths.append(sprite_node.texture.resource_path)
            projectile_instance.queue_free()
            current_chimera_projs.append(WeaponService.init_ranged_stats(proj_stats, player_index))
        
        for proj_texture_set in effect.chimera_texture_sets:
            current_chimera_texture_sets.append(proj_texture_set)

func _yztato_boomerang_ready() -> void:
    for effect in effects:
        if effect.get_id() != "yztato_boomerang_weapon": continue

        is_boomerang = true
        max_damage_mul = effect.max_damage_mul
        knockback_only_back = effect.knockback_only_back
        wait_until_return = effect.boomerang_wait

func _yztato_boomerang_on_projectile_shot(projectile: Node2D) -> void:
    if !is_boomerang: return

    active_boomerangs.append(projectile)
    _hitbox.damage *= 1 + max_damage_mul
    if knockback_only_back: _hitbox.set_knockback(Vector2.ZERO, 0.0, 0.0)

    if !projectile.is_connected("returned_to_player", self, "yz_on_projectile_returned"):
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
    
    var target: float = 0.0
    if _manual_aim:
        target = current_stats.max_range
    else:
        if _current_target.size() == 0 or not is_instance_valid(_current_target[0]):
            target = current_stats.max_range
        else:
            target = _current_target[1]
    
    if wait_until_return and !is_returning:
        _shooting_behavior.shoot(target)
        _current_cooldown = Utils.LARGE_NUMBER
    else:
        _shooting_behavior.shoot(target)
        _current_cooldown = get_next_cooldown()

    is_returning = true

    if stats.custom_on_cooldown_sprite != null and (is_big_reload_active() or current_stats.additional_cooldown_every_x_shots == -1):
        update_sprite(stats.custom_on_cooldown_sprite)

    if original_stats:
        current_stats = original_stats

func _yztato_chal_on_weapon_hit_something(hitbox: Hitbox) -> void:
    ### sudden_misfortune ###
    if hitbox == null: return
    var attack_id := hitbox.player_attack_id
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
    if active_boomerangs.empty():
        is_returning = false

    if wait_until_return:
        _current_cooldown = get_next_cooldown()
