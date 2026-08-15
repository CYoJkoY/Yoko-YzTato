class_name MeleeBounceService
extends Reference

var _stats_tpl: RangedWeaponStats = null
var _scene_tpl: PackedScene = null
var _shader: ShaderMaterial = null
var _args_tpl: WeaponServiceSpawnProjectileArgs = null

var _registry: Dictionary = {}

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func register_weapon(weapon: MeleeWeapon, player_index: int) -> void:
    if _registry.has(weapon):
        return
    yz_init_shared_resources()
    var hashes: Array = []
    var values: Array = []
    for bounce in RunData.get_player_effect(Utils.yztato_melee_bounce_bullets_hash, player_index):
        hashes.append(bounce[0])
        values.append(bounce[1])
    for effect in weapon.effects:
        if effect.get_id() != "yztato_melee_bounce":
            continue
        hashes.append(effect.key_hash)
        values.append(effect.value)
    _registry[weapon] = { "hashes": hashes, "values": values }
    if not weapon.node_hit_box.is_connected("area_entered", self, "_on_area_entered"):
        weapon.node_hit_box.connect("area_entered", self, "_on_area_entered", [weapon])

func unregister_weapon(weapon: MeleeWeapon) -> void:
    if not _registry.has(weapon):
        return
    if weapon.node_hit_box.is_connected("area_entered", self, "_on_area_entered"):
        weapon.node_hit_box.disconnect("area_entered", self, "_on_area_entered")
    _registry.erase(weapon)

func clear_all() -> void:
    for weapon in _registry.keys():
        unregister_weapon(weapon)

# ══════════════════════════════════════════ Method ══════════════════════════════════════════ #
func yz_init_shared_resources() -> void:
    if _stats_tpl != null:
        return
    _stats_tpl = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_stats.tres").duplicate()
    _stats_tpl.can_bounce = false
    _stats_tpl.piercing = 99
    _stats_tpl.max_range = Utils.LARGE_NUMBER
    _stats_tpl.projectile_speed = 2000
    _stats_tpl.projectile_scene = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_projectile.tscn")

    _scene_tpl = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/player/default_projectile.tscn").duplicate()

    _shader = load("res://resources/shaders/hue_shift_shadermat.tres")
    _shader.set_shader_param("hue", 0.55)
    _shader.set_shader_param("desaturation", 0.0)

    _args_tpl = WeaponServiceSpawnProjectileArgs.new()
    _args_tpl.from_player_index = 0
    _args_tpl.deferred = true

func yz_execute_bounce(area: Area2D, weapon: MeleeWeapon, hashes: Array, values: Array) -> void:
    var proj: EnemyProjectile = area.get_parent()
    var base_angle: float = proj.velocity.angle()
    var base_pos: Vector2 = proj.global_position
    var base_dmg: float = area.damage + weapon.current_stats.damage * 0.5
    var base_tex: Texture = proj._sprite.texture

    area.hit_something(weapon, 0)

    var projectiles: Array = []
    for i in values.size():
        var stats: RangedWeaponStats = _stats_tpl.duplicate()
        stats.damage = base_dmg * values[i] / 100.0
        var args: WeaponServiceSpawnProjectileArgs = _args_tpl.duplicate()
        args.damage_tracking_key_hash = hashes[i]
        var angle: float = base_angle + PI + cos(i * PI) * i * (PI / 12.0)
        var p = WeaponService.spawn_projectile(base_pos, stats, angle, weapon, args)
        projectiles.append(p)

    for p in projectiles:
        p.get_node("Sprite").texture = base_tex
        p.set_sprite_material(_shader)
        if not p.is_connected("hit_something", weapon, "on_weapon_hit_something"):
            p.connect("hit_something", weapon, "on_weapon_hit_something", [p._hitbox])

    yz_challenge_counterattack(area, weapon)

func yz_challenge_counterattack(area: Area2D, weapon: MeleeWeapon) -> void:
    var hitbox = area
    if hitbox == null:
        return
    var attack_id: int = hitbox.player_attack_id
    if attack_id < 0:
        return
    var hit_count: int = weapon._hit_count_by_attack_id.get(attack_id, 0) + 1
    weapon._hit_count_by_attack_id[attack_id] = hit_count
    ChallengeService.try_complete_challenge(Utils.chal_counterattack_hash, hit_count)

# ══════════════════════════════════════════ Signal ══════════════════════════════════════════ #
func _on_area_entered(area: Area2D, weapon: MeleeWeapon) -> void:
    if not (area.get_parent() is EnemyProjectile):
        return
    if not _registry.has(weapon):
        return
    var entry: Dictionary = _registry[weapon]
    yz_execute_bounce(area, weapon, entry["hashes"], entry["values"])
