extends PlayerProjectile

signal returned_to_player(projectile)

var distance_sq: float = 0.0
var is_returning: bool = false
var weapon_node = null
var return_speed: float = 0.0
var min_range: float = 0.0
var max_damage_mul: float = 0.0
var min_damage_mul: float = 0.0
var lock_range: bool = false
var lock_speed: bool = false
var knockback_only_back: bool = false

# =========================== Extension =========================== #
func _physics_process(_delta: float):
    _yztato_boomerang_physics_process()

func stop() -> void:
    emit_signal("returned_to_player", self)
    is_returning = false
    .stop()

func _set_time_until_max_range() -> void:
    ._set_time_until_max_range()
    _yztato_boomerang_set_time_until_max_range(_hitbox.effects)
    
# =========================== Custom =========================== #
func _yztato_boomerang_set_time_until_max_range(effects: Array) -> void:
    for effect in effects:
        if effect.get_id() != "yztato_boomerang_weapon": continue

        _time_until_max_range = Utils.LARGE_NUMBER
        weapon_node = _hitbox.from
        return_speed = effect.return_speed
        min_range = effect.min_range
        max_damage_mul = effect.max_damage_mul
        min_damage_mul = effect.min_damage_mul
        lock_range = effect.lock_range
        lock_speed = effect.lock_speed
        knockback_only_back = effect.knockback_only_back

func _yztato_boomerang_physics_process() -> void:
    var weapon_pos = weapon_node.global_position
    var self_pos = global_position
    
    var direction_to_weapon = weapon_pos - self_pos
    var distance = direction_to_weapon.length()
    var direction_normalized = Vector2.ZERO
    if distance > 0:
        direction_normalized = direction_to_weapon / distance

    var boomerang_range: float = min_range if lock_range else max(_weapon_stats.max_range, min_range)
    var range_factor: float = distance / boomerang_range if boomerang_range > 0.0 else 0.0
    
    var damage_diff: float = max_damage_mul - min_damage_mul
    var damage_mul: float = 1.0 + max_damage_mul - range_factor * damage_diff
    var base_damage: float = _weapon_stats.damage

    _hitbox.damage = base_damage * damage_mul

    if !is_returning:
        if knockback_only_back: _hitbox.set_knockback(Vector2.ZERO, 0.0, 0.0)

        is_returning = distance > boomerang_range

    else:
        if knockback_only_back:
            _hitbox.set_knockback(direction_normalized,
                                -_weapon_stats.knockback, 
                                _weapon_stats.knockback_piercing)

        var speed = return_speed if lock_speed else _weapon_stats.projectile_speed
        
        var target_velocity = direction_normalized * speed
        velocity = target_velocity
        
        if distance < 30: 
            _time_until_max_range = 0
