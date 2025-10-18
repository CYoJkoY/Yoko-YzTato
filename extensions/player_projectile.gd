extends "res://projectiles/player_projectile.gd"

# =========================== Extention =========================== #
func _get_player_index()->int:
	if is_instance_valid(_hitbox.from) and _hitbox.from.has_method("_get_player_index"):
		return ._get_player_index()
	else:
		return RunData.DUMMY_PLAYER_INDEX

# =========================== Custom =========================== #
