extends "res://weapons/melee/melee_weapon.gd"

# ══════════════════════════════════════════ Variables ══════════════════════════════════════════ #

var _yztato_blade_storm_enabled: bool = false
var _yztato_flying_sword_enabled: bool = false
var _yztato_has_attacked_target: bool = false
var _yztato_idle_angle: float = 0.0
var _yztato_locked_target: Node = null
var _yztato_sword_array_stats: RangedWeaponStats = null
var _yztato_bounced_projectile_stats: RangedWeaponStats = null
var _yztato_bounced_projectile_scene: PackedScene = null
var _yztato_bounce_args: WeaponServiceSpawnProjectileArgs = null
var _yztato_bounced_projectile_shader: ShaderMaterial = null
var _yztato_kill_count_scaling: Dictionary = {}

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #

func _ready() -> void:
    _yztato_setup_melee_effects()
    _yztato_setup_flying_sword()
    _yztato_setup_blade_storm()

func _physics_process(_delta: float) -> void:
    if _yztato_flying_sword_enabled:
        _yztato_process_flying_sword(player_index)

func _on_Hitbox_hit_something(thing_hit: Node, damage_dealt: int) -> void:
    ._on_Hitbox_hit_something(thing_hit, damage_dealt)
    _yztato_flying_sword_on_hit(thing_hit)

func on_weapon_hit_something(thing_hit: Node, damage_dealt: int, hitbox: Hitbox) -> void:
    .on_weapon_hit_something(thing_hit, damage_dealt, hitbox)
    if thing_hit._burning != null:
        WeaponService.yz_leave_fire(effects, thing_hit, player_index)
    WeaponService.yz_multi_hit(effects, weapon_pos, thing_hit, damage_dealt, player_index)
    WeaponService.yz_vine_trap(effects, weapon_pos, thing_hit, player_index)
    WeaponService.yz_summon_lightning(effects, weapon_pos, thing_hit, player_index)

func on_killed_something(_thing_killed: Node, hitbox: Hitbox) -> void:
    .on_killed_something(_thing_killed, hitbox)
    WeaponService.yz_gain_stat_when_killed_scaling_single(effects, _yztato_kill_count_scaling, _parent, player_index)
    WeaponService.yz_upgrade_when_killed_enemies(effects, _enemies_killed_this_wave_count, weapon_pos, player_index)

func update_sprite_flipv() -> void:
    if _yztato_blade_storm_enabled:
        return

    .update_sprite_flipv()

func update_idle_angle() -> void:
    if _yztato_blade_storm_enabled:
        _current_idle_angle = _yztato_idle_angle
        return

    .update_idle_angle()

func get_direction() -> float:
    var direction: float = .get_direction()
    if _yztato_blade_storm_enabled:
        direction = _current_idle_angle

    return direction

func get_direction_and_calculate_target() -> float:
    var target: float = .get_direction_and_calculate_target()
    if _yztato_blade_storm_enabled:
        target = _current_idle_angle

    return target

func shoot() -> void:
    if _yztato_flying_sword_enabled or _yztato_blade_storm_enabled:
        return

    .shoot()

func should_shoot() -> bool:
    var should_shoot: bool = .should_shoot()
    should_shoot = WeaponService.yz_can_attack_while_moving(effects, _parent, should_shoot)

    return should_shoot

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #

func _yztato_setup_melee_effects() -> void:
    var effect_types = ["erase", "bounce"]
    for effect_type in effect_types:
        var found = false
        # Check player effects
        for pi in RunData.players_data.size():
            if RunData.get_player_effect(Keys.generate_hash("yztato_melee_" + effect_type + "_bullets"), pi):
                found = true
                break

        # Check weapon effects
        if not found:
            for effect in effects:
                if effect.get_id() == "yztato_melee_" + effect_type:
                    found = true
                    break

        if found:
            _yztato_connect_melee_signals(effect_type)
            if effect_type == "bounce":
                _yztato_init_bounce_resources()

func _yztato_setup_flying_sword() -> void:
    var flying_sword_dict: Dictionary = RunData.get_player_effect(Utils.yztato_flying_sword_hash, player_index)
    _yztato_flying_sword_enabled = not flying_sword_dict.empty()

func _yztato_setup_blade_storm() -> void:
    _yztato_blade_storm_enabled = RunData.get_player_effect_bool(Utils.yztato_blade_storm_hash, player_index)
    if not _yztato_blade_storm_enabled:
        return

    var node_collision: CollisionShape2D = $Sprite/Hitbox/Collision
    var offset: float = node_collision.shape.extents.x * 0.5
    node_collision.shape.extents.x = offset
    node_collision.position.x *= 0.5
    node_collision.position.x += offset

    var node_hit_box: Hitbox = $Sprite/Hitbox
    node_hit_box.monitoring = true
    node_hit_box.collision_mask = Utils.ENEMY_PROJECTILES_BIT
    if not node_hit_box.is_connected("area_entered", self, "_yztato_on_Hitbox_area_entered_erase"):
        node_hit_box.connect("area_entered", self, "_yztato_on_Hitbox_area_entered_erase")

func _yztato_process_flying_sword(player_index: int) -> void:
    var flying_sword_dict: Dictionary = RunData.get_player_effect(Utils.yztato_flying_sword_hash, player_index)
    if flying_sword_dict.empty():
        return

    var qi_value: float = flying_sword_dict.get(0, -1.0)
    var array_value: float = flying_sword_dict.get(1, -1.0)
    var current_damage = current_stats.damage
    var can_attack = qi_value >= 0 and qi_value < current_damage
    var can_array = array_value >= 0 and array_value < current_damage

    if can_attack:
        _yztato_process_attack_mode()
    if can_array:
        var player_level: int = RunData.players_data[player_index].current_level
        _yztato_process_sword_array_mode(player_level)

func _yztato_flying_sword_on_hit(thing_hit: Node) -> void:
    var flying_sword_dict: Dictionary = RunData.get_player_effect(Utils.yztato_flying_sword_hash, player_index)
    if flying_sword_dict.empty():
        return
    var qi_value: float = flying_sword_dict.get(0, -1.0)
    if qi_value >= 0 and qi_value < current_stats.damage:
        _yztato_has_attacked_target = true
        _hitbox.ignored_objects.erase(thing_hit)

func _yztato_init_bounce_resources() -> void:
    if _yztato_bounced_projectile_stats != null:
        return

    _yztato_bounced_projectile_stats = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_stats.tres").duplicate()
    _yztato_bounced_projectile_scene = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_projectile.tscn").duplicate()
    _yztato_bounced_projectile_stats.can_bounce = false
    _yztato_bounced_projectile_stats.piercing = 99
    _yztato_bounced_projectile_stats.max_range = Utils.LARGE_NUMBER
    _yztato_bounced_projectile_stats.projectile_speed = 2000
    _yztato_bounced_projectile_stats.projectile_scene = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_projectile.tscn")

    _yztato_bounce_args = WeaponServiceSpawnProjectileArgs.new()
    _yztato_bounce_args.from_player_index = player_index
    _yztato_bounce_args.deferred = true

    _yztato_bounced_projectile_shader = load("res://resources/shaders/hue_shift_shadermat.tres")
    _yztato_bounced_projectile_shader.set_shader_param("hue", 0.55)
    _yztato_bounced_projectile_shader.set_shader_param("desaturation", 0.0)

func _yztato_process_attack_mode() -> void:
    var target: Node = _yztato_select_target()
    var speed: float = 0.05
    _yztato_idle_angle = fmod(_yztato_idle_angle + speed, TAU)

    match [is_instance_valid(target), _yztato_has_attacked_target]:
        [false, _]:
            _hitbox.disable()
            global_position = _yztato_get_idle_position()
            rotation = _current_idle_angle
        [true, true]:
            _hitbox.disable()
            _yztato_return_to_player()
        [true, false]:
            _hitbox.enable()
            _yztato_move_to_target(target)

func _yztato_process_sword_array_mode(player_level: int) -> void:
    if _current_cooldown > 0 or _targets_in_range.empty():
        return

    _targets_in_range.shuffle()
    var sword_count: int = int(clamp(player_level / 2, 1, 16))
    var target_count: int = _targets_in_range.size()
    for i in sword_count:
        _yztato_create_sword_projectile(_targets_in_range[i % target_count])
    _current_cooldown = get_next_cooldown() * 2.5
    _is_shooting = false

func _yztato_select_target() -> Node:
    if is_instance_valid(_yztato_locked_target) and _targets_in_range.has(_yztato_locked_target):
        return _yztato_locked_target

    if not _targets_in_range.empty():
        return Utils.get_nearest_no_max_no_dist(_targets_in_range, _parent.global_position, 100)

    _yztato_locked_target = null
    return null

func _yztato_create_sword_projectile(target: Node) -> void:
    var offset_x = Utils._rng.randi_range(-200, 200)
    var offset_y = Utils._rng.randi_range(-200, 200)
    var project_position: Vector2 = target.global_position - Vector2(offset_x, offset_y)
    var direction_to_target: float = (target.global_position - project_position).angle()

    if _yztato_sword_array_stats == null:
        _yztato_sword_array_stats = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_stats.tres").duplicate()
        _yztato_sword_array_stats.damage = current_stats.damage
        _yztato_sword_array_stats.crit_chance = current_stats.crit_chance
        _yztato_sword_array_stats.crit_damage = current_stats.crit_damage
        _yztato_sword_array_stats.lifesteal = current_stats.lifesteal
        _yztato_sword_array_stats.piercing = 99
        _yztato_sword_array_stats.max_range = 300
        _yztato_sword_array_stats.can_bounce = false

    var modified_scene: PackedScene = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_projectile.tscn").duplicate()
    modified_scene._bundled["variants"][2] = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/sword_array/sword_array.webp")
    _yztato_sword_array_stats.projectile_scene = modified_scene

    var sword_array_projectile: Node = WeaponService.spawn_projectile(
        project_position,
        _yztato_sword_array_stats,
        direction_to_target,
        self,
        WeaponServiceSpawnProjectileArgs.new()
    )
    if not sword_array_projectile.is_connected("hit_something", self, "on_weapon_hit_something"):
        sword_array_projectile.connect("hit_something", self, "on_weapon_hit_something", [sword_array_projectile._hitbox])

func _yztato_move_to_target(target: Node) -> void:
    var dist_to_player: float = global_position.distance_squared_to(target.global_position)
    var direction: float = global_position.direction_to(target.global_position).angle()
    var max_range_sq: float = current_stats.max_range * current_stats.max_range * 4

    if dist_to_player > max_range_sq:
        _yztato_has_attacked_target = true
        return

    global_position = global_position.move_toward(target.global_position, 10.0)
    rotation = lerp(rotation, direction, 0.2)

func _yztato_return_to_player() -> void:
    var target_idle_pos: Vector2 = _yztato_get_idle_position()
    var dist_to_orbit: float = global_position.distance_squared_to(target_idle_pos)
    var direction: float = global_position.direction_to(_parent.global_position).angle()

    if dist_to_orbit > 10000:
        global_position = global_position.move_toward(target_idle_pos, 20.0)
        rotation = lerp(rotation, direction, 0.2)
        return

    _yztato_has_attacked_target = false

func _yztato_get_idle_position() -> Vector2:
    var weapon_count: int = int(max(1, _parent.get_nb_weapons()))
    var radius: int = 100 if weapon_count <= 6 else 100 + (weapon_count - 6) * 10
    var angel_per_weapon: float = TAU / weapon_count
    var weapon_offset_angle: float = weapon_pos * angel_per_weapon
    var offset_x: float = cos(_yztato_idle_angle + weapon_offset_angle) * radius
    var offset_y: float = sin(_yztato_idle_angle + weapon_offset_angle) * radius

    return Vector2(_parent.global_position.x + offset_x, _parent.global_position.y + offset_y - 24)

# ══════════════════════════════════════════ Method ══════════════════════════════════════════ #

func _yztato_connect_melee_signals(effect_type: String) -> void:
    var node_range: Area2D = $Range
    node_range.collision_mask += Utils.ENEMY_PROJECTILES_BIT
    if not node_range.is_connected("area_entered", self, "_yztato_on_Range_area_entered"):
        node_range.connect("area_entered", self, "_yztato_on_Range_area_entered")
    if not node_range.is_connected("area_exited", self, "_yztato_on_Range_area_exited"):
        node_range.connect("area_exited", self, "_yztato_on_Range_area_exited")

    var node_hit_box: Hitbox = $Sprite/Hitbox
    node_hit_box.monitoring = true
    node_hit_box.collision_mask += Utils.ENEMY_PROJECTILES_BIT

    match effect_type:
        "erase":
            if not node_hit_box.is_connected("area_entered", self, "_yztato_on_Hitbox_area_entered_erase"):
                node_hit_box.connect("area_entered", self, "_yztato_on_Hitbox_area_entered_erase")
        "bounce":
            var tracking_key_hashes: Array = []
            var bounce_values: Array = []
            var melee_bounces: Array = RunData.get_player_effect(Utils.yztato_melee_bounce_bullets_hash, player_index)
            for melee_bounce in melee_bounces:
                tracking_key_hashes.append(melee_bounce[0])
                bounce_values.append(melee_bounce[1])
            for effect in effects:
                if effect.get_id() == "yztato_melee_bounce":
                    tracking_key_hashes.append(effect.key_hash)
                    bounce_values.append(effect.value)
            if not node_hit_box.is_connected("area_entered", self, "_yztato_on_Hitbox_area_entered_bounce"):
                node_hit_box.connect("area_entered", self, "_yztato_on_Hitbox_area_entered_bounce", [tracking_key_hashes, bounce_values, node_hit_box])

func _yztato_on_Range_area_entered(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile:
        _targets_in_range.append(area)

func _yztato_on_Range_area_exited(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile:
        _targets_in_range.erase(area)

func _yztato_on_Hitbox_area_entered_erase(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile:
        area.hit_something(self, 0)

func _yztato_on_Hitbox_area_entered_bounce(area: Area2D, tracking_key_hashes: Array, bounce_values: Array, hitbox: Hitbox) -> void:
    if not (area.get_parent() is EnemyProjectile):
        return

    var enemy_projectile: Projectile = area.get_parent()
    var original_angle: float = enemy_projectile.velocity.angle()
    var original_position: Vector2 = enemy_projectile.global_position
    var original_texture: Texture = enemy_projectile._sprite.texture
    var base_damage: float = area.damage + current_stats.damage / 2.0
    var num: int = bounce_values.size()

    if _yztato_bounced_projectile_stats == null:
        _yztato_init_bounce_resources()

    _yztato_bounced_projectile_scene._bundled["variants"][2] = original_texture
    _yztato_bounced_projectile_stats.projectile_scene = _yztato_bounced_projectile_scene
    area.hit_something(self, 0)

    var new_projectiles: Array = []
    for i in num:
        var stats_copy = _yztato_bounced_projectile_stats.duplicate()
        stats_copy.damage = base_damage * bounce_values[i] / 100.0
        _yztato_bounce_args.damage_tracking_key_hash = tracking_key_hashes[i]
        var direction: float = original_angle + PI + cos(i * PI) * i * (PI / 12.0)
        var new_projectile: Node = WeaponService.spawn_projectile(
            original_position,
            stats_copy,
            direction,
            self,
            _yztato_bounce_args
        )
        new_projectiles.append(new_projectile)

    for projectile in new_projectiles:
        projectile.call_deferred("set_sprite_material", _yztato_bounced_projectile_shader)
        if not projectile.is_connected("hit_something", self, "on_weapon_hit_something"):
            projectile.connect("hit_something", self, "on_weapon_hit_something", [projectile._hitbox])

    if hitbox == null:
        return

    var attack_id := hitbox.player_attack_id
    if attack_id < 0:
        return

    var attack_hit_count = _hit_count_by_attack_id.get(attack_id, 0) + 1
    _hit_count_by_attack_id[attack_id] = attack_hit_count
    ChallengeService.try_complete_challenge(Utils.chal_counterattack_hash, attack_hit_count)
