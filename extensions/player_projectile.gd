extends "res://projectiles/player_projectile.gd"

# EFFECT : chimera_weapon_effect
onready var sprite_node: Sprite = $Sprite

# EFFECT : boomerang_weapon_effect
signal returned_to_player
const DISTANCE_THRESHOLD_SQ: float = 900.0
var distance_sq: float = 0.0
var is_returning: bool = false
var player_node = null
var return_speed: float = 0.0
var min_range: float = 0.0
var max_damage_mul: float = 0.0
var min_damage_mul: float = 0.0
var is_boomerang: bool = false
var lock_range: bool = false
var lock_speed: bool = false
var knockback_only_back: bool = false

# =========================== Extension =========================== #
func _physics_process(_delta: float):
	_yztato_boomerang_physics_process(_delta)

func _on_Hitbox_hit_something(thing_hit: Node, damage_dealt: int) -> void:
	_yztato_chimera_on_Hitbox_hit_something(_hitbox.effects)
	._on_Hitbox_hit_something(thing_hit, damage_dealt)

func stop() -> void:
	if is_boomerang:
		emit_signal("returned_to_player", self)
	.stop()

func _set_ticks_until_max_range() -> void:
	._set_ticks_until_max_range()
	is_boomerang = _yztato_boomerang_set_ticks_until_max_range(_hitbox.effects)

# =========================== Custom =========================== #
func _yztato_chimera_on_Hitbox_hit_something(effects: Array) -> void:
	for effect in effects:
		if !(effect is ProgressData.Yztato.Chimera._Effect): continue
			
		var chimera_texture_sets = effect.chimera_texture_sets
		var texture = sprite_node.texture
		if not texture: continue
			
		for texture_data in chimera_texture_sets:
			if texture.resource_path != texture_data.texture.resource_path: continue
				
			_apply_texture_modifications(texture_data)
			break

func _yztato_boomerang_set_ticks_until_max_range(effects: Array) -> bool:
	for effect in effects:
		if !(effect is ProgressData.Yztato.Boomerang._Effect): continue

		_time_until_max_range = Utils.LARGE_NUMBER
		player_node = _hitbox.from
		return_speed = effect.return_speed
		min_range = effect.min_range
		max_damage_mul = effect.max_damage_mul
		min_damage_mul = effect.min_damage_mul
		lock_range = effect.lock_range
		lock_speed = effect.lock_speed
		knockback_only_back = effect.knockback_only_back

		# Only Ranged Shoot Can `return true`
		return true
	return false

func _yztato_boomerang_physics_process(delta: float) -> void:
	if !is_boomerang: return

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

# =========================== Methods =========================== #
func _apply_texture_modifications(texture_data) -> void:
	var enable_flags = texture_data.enable_flags
	
	if enable_flags["modify_damage"]:
		_weapon_stats.damage = texture_data.damage
		
	if enable_flags["modify_accuracy"]:
		_weapon_stats.accuracy = texture_data.accuracy
		
	if enable_flags["modify_knockback"]:
		_weapon_stats.knockback = texture_data.knockback
		
	if enable_flags["modify_knockback_piercing"]:
		_weapon_stats.knockback_piercing = texture_data.knockback_piercing
		
	if enable_flags["modify_lifesteal"]:
		_weapon_stats.lifesteal = texture_data.lifesteal
		
	if enable_flags["modify_piercing"]:
		_weapon_stats.piercing = texture_data.piercing
		
	if enable_flags["modify_piercing_dmg_reduction"]:
		_weapon_stats.piercing_dmg_reduction = texture_data.piercing_dmg_reduction
		
	if enable_flags["modify_bounce"]:
		_weapon_stats.bounce = texture_data.bounce
		
	if enable_flags["modify_bounce_dmg_reduction"]:
		_weapon_stats.bounce_dmg_reduction = texture_data.bounce_dmg_reduction
	
	_weapon_stats.can_have_positive_knockback = texture_data.can_have_positive_knockback
	_weapon_stats.can_have_negative_knockback = texture_data.can_have_negative_knockback
	_weapon_stats.increase_projectile_speed_with_range = texture_data.increase_projectile_speed_with_range
	_weapon_stats.can_bounce = texture_data.can_bounce
