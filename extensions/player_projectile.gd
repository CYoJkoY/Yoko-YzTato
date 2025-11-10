extends "res://projectiles/player_projectile.gd"

# =========================== Extention =========================== #
func _get_player_index()->int:
	if _hitbox.from and is_instance_valid(_hitbox.from):
		return ._get_player_index()
	return player_index
