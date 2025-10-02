extends "res://entities/units/enemies/attack_behaviors/shooting_attack_behavior.gd"

# =========================== Extension =========================== #
func spawn_projectile(rot: float, pos: Vector2, spd: int)->Node:
	var projectile: Node = .spawn_projectile(rot, pos, spd)
	projectile = _yztato_set_enemy_proj_transparency(projectile, ProgressData.settings.yztato_set_enemy_proj_transparency)
	
	return projectile
	
# =========================== Custom =========================== #
func _yztato_set_enemy_proj_transparency(projectile: Node, alpha_value: float) -> Node:
	var clamped_alpha = clamp(alpha_value, 0.0, 1.0)
	projectile.modulate.a = clamped_alpha
	
	return projectile
