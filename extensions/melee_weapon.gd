extends "res://weapons/melee/melee_weapon.gd"

onready var node_collision: CollisionShape2D = $"Sprite/Hitbox/Collision"
onready var node_range: Area2D = $"Range"
onready var node_hit_box: Hitbox = $"Sprite/Hitbox"

# ── blade_storm ──
onready var YZ_is_blade_storm: bool = false

# ── flying_sword ──
var YZ_is_flying_sword: bool = false
var can_attack: bool = false
var can_array: bool = false
var idle_angle: float = 0.0
var has_attacked_target: bool = false
var _current_locked_target: Node = null
var sword_array_stats: RangedWeaponStats = null

# ── gain_stat_when_killed_single_scaling ──
var gain_stat_when_killed_single_scaling_killed_count: Dictionary = {}

# ══════════════════════════════════════════
#  EXTENSION
# ══════════════════════════════════════════
func _ready() -> void:
    _setup_erase()
    _setup_bounce()
    _setup_flying_sword()
    _setup_blade_storm()

func _physics_process(_delta: float) -> void:
    if YZ_is_flying_sword:
        _yztato_flying_sword(player_index)

func _on_Hitbox_hit_something(thing_hit: Node, damage_dealt: int) -> void:
    ._on_Hitbox_hit_something(thing_hit, damage_dealt)
    _flying_sword_erase(thing_hit)

func on_weapon_hit_something(thing_hit: Node, damage_dealt: int, hitbox: Hitbox):
    .on_weapon_hit_something(thing_hit, damage_dealt, hitbox)
    if thing_hit._burning != null:
        WeaponService.yz_leave_fire(effects, thing_hit, player_index)
    WeaponService.yz_multi_hit(effects, weapon_pos, thing_hit, damage_dealt, player_index)
    WeaponService.yz_vine_trap(effects, weapon_pos, thing_hit, player_index)
    WeaponService.yz_summon_lightning(effects, weapon_pos, thing_hit, player_index)

func on_killed_something(_thing_killed: Node, hitbox: Hitbox) -> void:
    .on_killed_something(_thing_killed, hitbox)
    WeaponService.yz_gain_stat_when_killed_scaling_single(effects, gain_stat_when_killed_single_scaling_killed_count, _parent, player_index)
    WeaponService.yz_upgrade_when_killed_enemies(effects, _enemies_killed_this_wave_count, weapon_pos, player_index)

func update_sprite_flipv() -> void:
    if YZ_is_blade_storm:
        return
    .update_sprite_flipv()

func update_idle_angle() -> void:
    if YZ_is_blade_storm:
        _current_idle_angle = _idle_angle
        return
    .update_idle_angle()

func get_direction() -> float:
    var direction = .get_direction()
    if YZ_is_blade_storm:
        direction = _current_idle_angle
    return direction

func get_direction_and_calculate_target() -> float:
    var target = .get_direction_and_calculate_target()
    if YZ_is_blade_storm:
        target = _current_idle_angle
    return target

func shoot() -> void:
    if YZ_is_flying_sword or YZ_is_blade_storm:
        return
    .shoot()

func should_shoot() -> bool:
    var should_shoot: bool = .should_shoot()
    should_shoot = WeaponService.yz_can_attack_while_moving(effects, _parent, should_shoot)
    return should_shoot

# ══════════════════════════════════════════
#  SETUP (flat, single-responsibility)
# ══════════════════════════════════════════

func _setup_erase() -> void:
    if not _has_effect("yztato_melee_erase"):
        return
    _connect_once(node_range, "area_entered", "_on_Range_area_entered")
    _connect_once(node_hit_box, "area_entered", "_on_Hitbox_area_entered_erase")
    node_range.collision_mask += Utils.ENEMY_PROJECTILES_BIT
    node_hit_box.monitoring = true
    node_hit_box.collision_mask += Utils.ENEMY_PROJECTILES_BIT

func _setup_bounce() -> void:
    if not _has_effect("yztato_melee_bounce"):
        return
    MeleeBounceService.new().register_weapon(self, player_index)
    _connect_once(node_range, "area_entered", "_on_Range_area_entered")
    node_range.collision_mask += Utils.ENEMY_PROJECTILES_BIT

func _setup_flying_sword() -> void:
    var fs: Dictionary = RunData.get_player_effect(Utils.yztato_flying_sword_hash, player_index)
    for key in fs:
        if fs[key] < 0:
            continue
        YZ_is_flying_sword = true
        can_attack = fs[0] >= 0 and fs[0] < current_stats.damage
        can_array   = fs[1] >= 0 and fs[1] < current_stats.damage

func _setup_blade_storm() -> void:
    YZ_is_blade_storm = RunData.get_player_effect_bool(Utils.yztato_blade_storm_hash, player_index)
    if not YZ_is_blade_storm:
        return
    var offset = node_collision.shape.extents.x * 0.5
    node_collision.shape.extents.x = offset
    node_collision.position.x = node_collision.position.x * 0.5 + offset
    node_hit_box.monitoring = true
    node_hit_box.collision_mask = Utils.ENEMY_PROJECTILES_BIT
    _connect_once(node_hit_box, "area_entered", "_on_Hitbox_area_entered_erase")

# ══════════════════════════════════════════
#  HELPERS
# ══════════════════════════════════════════

func _has_effect(effect_id: String) -> bool:
    for effect in effects:
        if effect.get_id() == effect_id:
            return true
    var bullet_hash = Utils.get("yztato_" + effect_id.trim_prefix("yztato_") + "_bullets_hash")
    if bullet_hash != null:
        for val in RunData.get_player_effect(bullet_hash, player_index):
            if val != 0:
                return true
    return false

func _connect_once(node: Object, signal_name: String, method: String) -> void:
    if not node.is_connected(signal_name, self, method):
        node.connect(signal_name, self, method)

# ══════════════════════════════════════════
#  ERASE
# ══════════════════════════════════════════

func _on_Hitbox_area_entered_erase(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile:
        area.hit_something(self, 0)

func _flying_sword_erase(thing_hit: Node) -> void:
    if not can_attack:
        return
    has_attacked_target = true
    _hitbox.ignored_objects.erase(thing_hit)

# ══════════════════════════════════════════
#  FLYING SWORD
# ══════════════════════════════════════════

func _yztato_flying_sword(_p_idx: int) -> void:
    if can_attack:
        _fs_process_attack()
    if can_array:
        _fs_process_sword_array()

func _fs_process_attack() -> void:
    var target = _fs_select_target()
    idle_angle = fmod(idle_angle + 0.05, TAU)
    if target == null or has_attacked_target:
        _hitbox.disable()
        if has_attacked_target and target != null:
            _fs_return_to_player()
        else:
            global_position = _fs_get_idle_position()
            rotation = _current_idle_angle
    else:
        var dist_sq = global_position.distance_squared_to(target.global_position)
        if dist_sq > current_stats.max_range * current_stats.max_range * 4:
            has_attacked_target = true
            return
        _hitbox.enable()
        global_position = global_position.move_toward(target.global_position, 10.0)
        rotation = lerp(rotation, global_position.direction_to(target.global_position).angle(), 0.2)

func _fs_process_sword_array() -> void:
    if _current_cooldown > 0 or _targets_in_range.empty():
        return
    _targets_in_range.shuffle()
    var sword_count: int = int(clamp(RunData.players_data[player_index].current_level / 2, 1, 16))
    var target_count: int = _targets_in_range.size()
    for i in sword_count:
        _spawn_sword_projectile(_targets_in_range[i % target_count])
    _current_cooldown = get_next_cooldown() * 2.5
    _is_shooting = false

func _fs_select_target() -> Node:
    if is_instance_valid(_current_locked_target) and _targets_in_range.has(_current_locked_target):
        return _current_locked_target
    if not _targets_in_range.empty():
        return Utils.get_nearest_no_max_no_dist(_targets_in_range, _parent.global_position, 100)
    _current_locked_target = null
    return null

func _fs_return_to_player() -> void:
    var target_idle = _fs_get_idle_position()
    if global_position.distance_squared_to(target_idle) > 10000:
        global_position = global_position.move_toward(target_idle, 20.0)
        rotation = lerp(rotation, global_position.direction_to(_parent.global_position).angle(), 0.2)
        return
    has_attacked_target = false

func _fs_get_idle_position() -> Vector2:
    var weapon_count: int = int(max(1, _parent.get_nb_weapons()))
    var radius: int = 100 if weapon_count <= 6 else 100 + (weapon_count - 6) * 10
    var angle_step: float = TAU / weapon_count
    var offset_angle: float = weapon_pos * angle_step
    return _parent.global_position + Vector2(
        cos(idle_angle + offset_angle) * radius,
        sin(idle_angle + offset_angle) * radius - 24
    )

# ══════════════════════════════════════════
#  SWORD ARRAY PROJECTILE
# ══════════════════════════════════════════

func _spawn_sword_projectile(target: Node) -> void:
    if sword_array_stats == null:
        sword_array_stats = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_stats.tres").duplicate()
        sword_array_stats.damage = current_stats.damage
        sword_array_stats.crit_chance = current_stats.crit_chance
        sword_array_stats.crit_damage = current_stats.crit_damage
        sword_array_stats.lifesteal = current_stats.lifesteal
        sword_array_stats.piercing = 99
        sword_array_stats.max_range = 300
        sword_array_stats.can_bounce = false
        var scene = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_projectile.tscn").duplicate()
        scene._bundled["variants"][2] = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/sword_array/sword_array.webp")
        sword_array_stats.projectile_scene = scene

    var offset = Vector2(Utils._rng.randi_range(-200, 200), Utils._rng.randi_range(-200, 200))
    var proj = WeaponService.spawn_projectile(
        target.global_position - offset,
        sword_array_stats,
        (target.global_position - (target.global_position - offset)).angle(),
        self,
        WeaponServiceSpawnProjectileArgs.new()
    )
    if not proj.is_connected("hit_something", self, "on_weapon_hit_something"):
        proj.connect("hit_something", self, "on_weapon_hit_something", [proj._hitbox])

# ══════════════════════════════════════════
#  RANGE SIGNALS
# ══════════════════════════════════════════

func _on_Range_area_entered(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile:
        _targets_in_range.append(area)

func _on_Range_area_exited(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile:
        _targets_in_range.erase(area)
