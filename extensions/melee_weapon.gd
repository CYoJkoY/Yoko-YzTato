extends "res://weapons/melee/melee_weapon.gd"

onready var node_collision: CollisionShape2D = $"Sprite/Hitbox/Collision"
onready var node_range: Area2D = $"Range"
onready var node_hit_box: Hitbox = $"Sprite/Hitbox"

var _cached_projectile_scene: PackedScene = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_projectile.tscn")
var _cached_base_stats: RangedWeaponStats = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_stats.tres")

# blade_storm
onready var YZ_is_blade_storm: bool = false

# flying_sword
var YZ_is_flying_sword: bool = false
var can_attack: bool = false
var can_array: bool = false

var idle_angle: float = 0.0
var has_attacked_target: bool = false
var _current_locked_target: Node = null

var sword_array_stats: RangedWeaponStats = null

# melee_bounce
var bounced_projectile_stats: RangedWeaponStats = null
var bounced_projectile_scene: PackedScene = null
var melee_bounce_args: WeaponServiceSpawnProjectileArgs = null
var bounced_projectile_shader: ShaderMaterial = load("res://resources/shaders/hue_shift_shadermat.tres")

# gain_stat_when_killed_single_scaling
var gain_stat_when_killed_single_scaling_killed_count: Dictionary = {}

# vine_trap
onready var _entity_spawner: Node = get_tree().current_scene.get_node("EntitySpawner")

# =========================== Extension =========================== #
func _ready() -> void:
    _yztato_melee_setup("erase")
    _yztato_melee_setup("bounce")
    _yztato_flying_sword_ready()
    _yztato_blade_storm_ready()

func _physics_process(_delta: float) -> void:
    if YZ_is_flying_sword: _yztato_flying_sword(player_index)

func _on_Hitbox_hit_something(thing_hit: Node, damage_dealt: int) -> void:
    ._on_Hitbox_hit_something(thing_hit, damage_dealt)
    _yztato_flying_sword_erase(thing_hit)

func on_weapon_hit_something(thing_hit: Node, damage_dealt: int, hitbox: Hitbox):
    .on_weapon_hit_something(thing_hit, damage_dealt, hitbox)
    if thing_hit._burning != null: WeaponService.yz_leave_fire(effects, thing_hit, player_index)
    WeaponService.yz_multi_hit(effects, weapon_pos, thing_hit, damage_dealt, player_index)
    WeaponService.yz_vine_trap(effects, weapon_pos, _entity_spawner, thing_hit, player_index)

func on_killed_something(_thing_killed: Node, hitbox: Hitbox) -> void:
    .on_killed_something(_thing_killed, hitbox)
    WeaponService.yz_gain_stat_when_killed_scaling_single(effects, gain_stat_when_killed_single_scaling_killed_count, _parent, player_index)
    WeaponService.yz_upgrade_when_killed_enemies(effects, _enemies_killed_this_wave_count, weapon_pos, player_index)

func update_sprite_flipv() -> void:
    if YZ_is_blade_storm: return

    .update_sprite_flipv()

func update_idle_angle() -> void:
    if YZ_is_blade_storm:
        _current_idle_angle = _idle_angle
        return

    .update_idle_angle()

func get_direction() -> float:
    var direction =.get_direction()
    if YZ_is_blade_storm: direction = _current_idle_angle

    return direction

func get_direction_and_calculate_target() -> float:
    var target =.get_direction_and_calculate_target()
    if YZ_is_blade_storm: target = _current_idle_angle

    return target

func shoot() -> void:
    if YZ_is_flying_sword or \
    YZ_is_blade_storm: return
    
    .shoot()

func should_shoot() -> bool:
    var should_shoot: bool =.should_shoot()
    should_shoot = WeaponService.yz_can_attack_while_moving(effects, _parent, should_shoot)
    
    return should_shoot

# =========================== Custom =========================== #
func _yztato_melee_setup(effect_type: String) -> void:
    # Check Player Effects
    for player_index in RunData.players_data.size():
        var has_player_effect = RunData.get_player_effect(Keys.generate_hash("yztato_melee_" + effect_type + "_bullets"), player_index)
        if !has_player_effect: continue

        yz_connect_melee_signals(effect_type)
        return

    # Check Weapon Effects
    for effect in effects:
        if effect.get_id() != "yztato_melee_" + effect_type: continue

        yz_connect_melee_signals(effect_type)
        return

func _yztato_flying_sword_ready() -> void:
    var flying_sword: Dictionary = RunData.get_player_effect(Utils.yztato_flying_sword_hash, player_index)
    var Qi_value: float = flying_sword.get(0, NAN)
    var SwordArray_value: float = flying_sword.get(1, NAN)

    can_attack = Qi_value < current_stats.damage
    can_array = SwordArray_value < current_stats.damage
    YZ_is_flying_sword = can_attack or can_array

func _yztato_flying_sword(player_index: int) -> void:
    if !YZ_is_flying_sword: return

    match [can_attack, can_array]:
        [true, true]:
            var player_level: int = RunData.players_data[player_index].current_level
            yz_process_sword_array_mode(player_level)
            yz_process_attack_mode()
        [true, false]:
            yz_process_attack_mode()
        [false, true]:
            var player_level: int = RunData.players_data[player_index].current_level
            yz_process_sword_array_mode(player_level)

func _yztato_flying_sword_erase(thing_hit: Node) -> void:
    if !can_attack: return

    has_attacked_target = true
    _hitbox.ignored_objects.erase(thing_hit)

func _yztato_blade_storm_ready() -> void:
    YZ_is_blade_storm = RunData.get_player_effect_bool(Utils.yztato_blade_storm_hash, player_index)
    if !YZ_is_blade_storm: return

    var offset = node_collision.shape.extents.x * 0.5
    node_collision.shape.extents.x = offset
    node_collision.position.x *= 0.5
    node_collision.position.x += offset

    node_hit_box.monitoring = true
    node_hit_box.collision_mask = Utils.ENEMY_PROJECTILES_BIT
    if !node_hit_box.is_connected("area_entered", self , "yz_on_Hitbox_area_entered_erase"):
        node_hit_box.connect("area_entered", self , "yz_on_Hitbox_area_entered_erase")

func _yztato_can_attack_while_moving(should_shoot: bool) -> bool:
    if !should_shoot: return false

    for effect in effects:
        if effect.get_id() != "yztato_can_attack_while_moving": continue

        should_shoot = _parent._current_movement == Vector2.ZERO
        break

    return should_shoot

# =========================== Method =========================== #
func yz_connect_melee_signals(effect_type: String) -> void:
    node_range.collision_mask += Utils.ENEMY_PROJECTILES_BIT
    
    if !node_range.is_connected("area_entered", self , "yz_on_Range_area_entered"):
        node_range.connect("area_entered", self , "yz_on_Range_area_entered")
    if !node_range.is_connected("area_exited", self , "yz_on_Range_area_exited"):
        node_range.connect("area_exited", self , "yz_on_Range_area_exited")
    
    node_hit_box.monitoring = true
    node_hit_box.collision_mask += Utils.ENEMY_PROJECTILES_BIT
    
    match effect_type:
        "erase":
            if node_hit_box.is_connected("area_entered", self , "yz_on_Hitbox_area_entered_erase"): return

            node_hit_box.connect("area_entered", self , "yz_on_Hitbox_area_entered_erase")
        "bounce":
            bounced_projectile_shader.set_shader_param("hue", 0.55)
            bounced_projectile_shader.set_shader_param("desaturation", 0.0)

            if node_hit_box.is_connected("area_entered", self , "yz_on_Hitbox_area_entered_bounce"): return
            
            var tracking_key_hashes: Array = []
            var bounce_values: Array = []
            var melee_bounces: Array = RunData.get_player_effect(Utils.yztato_melee_bounce_bullets_hash, player_index)
            for melee_bounce in melee_bounces:
                tracking_key_hashes.append(melee_bounce[0])
                bounce_values.append(melee_bounce[1])

            for effect in effects:
                if effect.get_id() != "yztato_melee_bounce": continue

                tracking_key_hashes.append(effect.key_hash) # tracking_key_hash
                bounce_values.append(effect.value)

            node_hit_box.connect("area_entered", self , "yz_on_Hitbox_area_entered_bounce", [tracking_key_hashes, bounce_values, node_hit_box])

func yz_on_Range_area_entered(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile: _targets_in_range.append(area)

func yz_on_Range_area_exited(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile: _targets_in_range.erase(area)

func yz_on_Hitbox_area_entered_erase(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile: area.hit_something(self , 0)

func yz_on_Hitbox_area_entered_bounce(area: Area2D, tracking_key_hashes: Array, melee_bounces: Array, hitbox: Hitbox) -> void:
    if area.get_parent() is EnemyProjectile:
        var enemy_projectile: Projectile = area.get_parent()
        
        var original_angle: float = enemy_projectile.velocity.angle()
        var original_position: Vector2 = enemy_projectile.global_position
        var original_texture: Texture = enemy_projectile._sprite.texture
        var base_damage: float = area.damage + current_stats.damage / 2.0
        var num: int = melee_bounces.size()

        if bounced_projectile_stats == null:
            bounced_projectile_stats = _cached_base_stats.duplicate()
            bounced_projectile_scene = _cached_projectile_scene.duplicate()
            bounced_projectile_stats.can_bounce = false
            bounced_projectile_stats.piercing = 99
            bounced_projectile_stats.max_range = Utils.LARGE_NUMBER
            bounced_projectile_stats.projectile_speed = 2000
            bounced_projectile_stats.projectile_scene = _cached_projectile_scene

            melee_bounce_args = WeaponServiceSpawnProjectileArgs.new()
            melee_bounce_args.from_player_index = player_index
            melee_bounce_args.deferred = true

        bounced_projectile_scene._bundled["variants"][2] = original_texture
        bounced_projectile_stats.projectile_scene = bounced_projectile_scene
        area.hit_something(self , 0)

        var new_projectiles: Array = []

        for i in num:
            bounced_projectile_stats.damage = base_damage * melee_bounces[i] / 100.0
            melee_bounce_args.damage_tracking_key_hash = tracking_key_hashes[i]
            var direction: float = original_angle + PI + cos(i * PI) * i * (PI / 12.0)
            var new_projectile: Node = WeaponService.spawn_projectile(
                original_position,
                bounced_projectile_stats,
                direction,
                self ,
                melee_bounce_args
            )
            
            new_projectiles.append(new_projectile)

        for projectile in new_projectiles:
            projectile.call_deferred("set_sprite_material", bounced_projectile_shader)

            if !projectile.is_connected("hit_something", self , "on_weapon_hit_something"):
                projectile.connect("hit_something", self , "on_weapon_hit_something", [projectile._hitbox])

        ### counterattack ###
        if hitbox == null: return

        var attack_id := hitbox.player_attack_id
        if attack_id < 0: return

        var attack_hit_count = _hit_count_by_attack_id.get(attack_id, 0)
        attack_hit_count += 1
        _hit_count_by_attack_id[attack_id] = attack_hit_count
        
        ChallengeService.try_complete_challenge(Utils.chal_counterattack_hash, attack_hit_count)

func yz_process_attack_mode() -> void:
    var target: Node = yz_select_target()
    var speed: float = 0.05
    idle_angle = fmod(idle_angle + speed, TAU)
    
    match [is_instance_valid(target), has_attacked_target]:
        [false, _]:
            _hitbox.disable()
            global_position = yz_get_idle_position()
            rotation = _current_idle_angle
        [true, true]:
            _hitbox.disable()
            yz_return_to_player()
        [true, false]:
            _hitbox.enable()
            yz_move_to_target(target)

func yz_process_sword_array_mode(player_level: int) -> void:
    if _current_cooldown > 0 or _targets_in_range.empty(): return

    _targets_in_range.shuffle()
    var sword_count: int = int(clamp(player_level / 2, 1, 16))
    var target_count: int = _targets_in_range.size()

    for i in sword_count: yz_create_sword_projectile(_targets_in_range[i % target_count])

    _current_cooldown = get_next_cooldown() * 2.5
    _is_shooting = false

func yz_select_target() -> Node:
    if is_instance_valid(_current_locked_target) and _targets_in_range.has(_current_locked_target): return _current_locked_target

    if !_targets_in_range.empty(): return Utils.get_nearest_no_max_no_dist(_targets_in_range, _parent.global_position, 100)

    _current_locked_target = null
    return null

func yz_create_sword_projectile(target: Node) -> void:
    var offset_x = Utils._rng.randi_range(-200, 200)
    var offset_y = Utils._rng.randi_range(-200, 200)
    var project_position: Vector2 = target.global_position - Vector2(offset_x, offset_y)
    var direction_to_target: float = (target.global_position - project_position).angle()

    if sword_array_stats == null:
        sword_array_stats = _cached_base_stats.duplicate()
        sword_array_stats.damage = current_stats.damage
        sword_array_stats.crit_chance = current_stats.crit_chance
        sword_array_stats.crit_damage = current_stats.crit_damage
        sword_array_stats.lifesteal = current_stats.lifesteal
        sword_array_stats.piercing = 99
        sword_array_stats.max_range = 300
        sword_array_stats.can_bounce = false

        var modified_scene: PackedScene = _cached_projectile_scene.duplicate()
        modified_scene._bundled["variants"][2] = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/sword_array/sword_array.webp")
        sword_array_stats.projectile_scene = modified_scene

    var sword_array_projectile: Node = WeaponService.spawn_projectile(
        project_position,
        sword_array_stats,
        direction_to_target,
        self ,
        WeaponServiceSpawnProjectileArgs.new()
    )

    if !sword_array_projectile.is_connected("hit_something", self , "on_weapon_hit_something"):
        sword_array_projectile.connect("hit_something", self , "on_weapon_hit_something", [sword_array_projectile._hitbox])

func yz_move_to_target(target: Node) -> void:
    var dist_to_player: float = global_position.distance_squared_to(target.global_position)
    var direction: float = global_position.direction_to(target.global_position).angle()
    var max_range_sq: float = current_stats.max_range * current_stats.max_range * 4

    if dist_to_player > max_range_sq:
        has_attacked_target = true
        return

    global_position = global_position.move_toward(target.global_position, 10.0)
    rotation = lerp(rotation, direction, 0.2)

func yz_return_to_player() -> void:
    var target_idle_pos: Vector2 = yz_get_idle_position()
    var dist_to_orbit: float = global_position.distance_squared_to(target_idle_pos)
    var direction: float = global_position.direction_to(_parent.global_position).angle()

    if dist_to_orbit > 10000:
        global_position = global_position.move_toward(target_idle_pos, 20.0)
        rotation = lerp(rotation, direction, 0.2)
        return

    has_attacked_target = false

func yz_get_idle_position() -> Vector2:
    var weapon_count: int = int(max(1, _parent.get_nb_weapons()))
    var radius: int = 100 if weapon_count <= 6 else 100 + (weapon_count - 6) * 10
    var angel_per_weapon: float = TAU / weapon_count
    var weapon_offset_angle: float = weapon_pos * angel_per_weapon
    
    var offset_x: float = cos(idle_angle + weapon_offset_angle) * radius
    var offset_y: float = sin(idle_angle + weapon_offset_angle) * radius
    return Vector2(_parent.global_position.x + offset_x, _parent.global_position.y + offset_y - 24)

func yz_activate_burning_particle(particle, position: Vector2, burning_data, scale: float, duration: float) -> void:
    if particle != null and particle.has_method("activate"):
        particle.activate(position, burning_data)
        particle.rescale(scale)
        particle.set_duration(duration)
