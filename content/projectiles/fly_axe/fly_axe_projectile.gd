extends PlayerProjectile

signal returned_to_player

const DISTANCE_THRESHOLD_SQ: float = 900.0

var distance_sq: float = 0.0
var is_returning: bool = false
var player_node = null
var return_speed: float = 0.0
var min_range: float = 0.0
var max_damage_mul: float = 0.0
var min_damage_mul: float = 0.0
var lock_range: bool = false
var lock_speed: bool = false
var knockback_only_back: bool = false

# =========================== Extension =========================== #
func _physics_process(_delta: float):
    _yztato_boomerang_physics_process(_delta)

func stop() -> void:
    emit_signal("returned_to_player", self)
    .stop()

func _set_ticks_until_max_range() -> void:
    ._set_ticks_until_max_range()
    _yztato_boomerang_set_ticks_until_max_range(_hitbox.effects)
    

# =========================== Custom =========================== #
func _yztato_boomerang_set_ticks_until_max_range(effects: Array) -> void:
    for effect in effects:
        if effect.get_id() != "yztato_boomerang_weapon": continue

        _time_until_max_range = Utils.LARGE_NUMBER
        player_node = _hitbox.from
        return_speed = effect.return_speed
        min_range = effect.min_range
        max_damage_mul = effect.max_damage_mul
        min_damage_mul = effect.min_damage_mul
        lock_range = effect.lock_range
        lock_speed = effect.lock_speed
        knockback_only_back = effect.knockback_only_back

func _yztato_boomerang_physics_process(delta: float) -> void:
    var player_pos = player_node.global_position
    var self_pos = global_position
    
    var dx: float = player_pos.x - self_pos.x
    var dy: float = player_pos.y - self_pos.y
    distance_sq = pow(dx, 2) + pow(dy, 2)
    var distance: float = sqrt(distance_sq)
    var boomerang_range: float = min_range if lock_range else max(_weapon_stats.max_range, min_range)
    var range_factor: float = distance / boomerang_range if boomerang_range > 0.0 else 0.0
    
    var damage_diff: float = max_damage_mul - min_damage_mul
    var damage_mul: float = 1.0 + max_damage_mul - range_factor * damage_diff
    var base_damage: float = _weapon_stats.damage

    _hitbox.damage = base_damage * damage_mul

    if !is_returning:
        if knockback_only_back: _hitbox.set_knockback(Vector2.ZERO, 0.0, 0.0)

        is_returning = distance_sq > pow(boomerang_range, 2)

    else:
        var length = distance_sq
        if length > 0.0:
            length = 1.0 / distance
            dx *= length
            dy *= length
        
        if knockback_only_back: _hitbox.set_knockback(Vector2(dx, dy).normalized(),
                                                            -_weapon_stats.knockback, 
                                                            _weapon_stats.knockback_piercing)

        var speed = return_speed if lock_speed else _weapon_stats.projectile_speed
        
        position.x += (dx * speed - velocity.x) * delta
        position.y += (dy * speed - velocity.y) * delta
        
        if distance_sq <= DISTANCE_THRESHOLD_SQ:
            is_returning = false
            stop()
