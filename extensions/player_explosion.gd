extends "res://projectiles/player_explosion.gd"

# =========================== Extention =========================== #
func _ready()-> void:
	_yztato_explosion_erase(player_index)

# =========================== Custom =========================== #
func _yztato_explosion_erase(player_index : int)-> void:
	var explosion_erase = RunData.get_player_effect("yztato_explosion_erase_bullets", player_index)
	if explosion_erase and explosion_erase != 0:
		_hitbox.monitoring = true
		_hitbox.collision_mask = Utils.ENEMY_PROJECTILES_BIT
		var _bullets_entered: int = _hitbox.connect("area_entered", self, "yz_on_Hitbox_area_entered")

# =========================== Custom =========================== #
func yz_on_Hitbox_area_entered(area: Area2D)-> void:
	if area.get_parent() is EnemyProjectile:
		yz_delete_projectile(area.get_parent())

# Avoid Assertion failed Caused By Function Stop
func yz_delete_projectile(proj: Projectile)->void :
	proj.hide()
	proj.velocity = Vector2.ZERO
	proj._hitbox.collision_layer = proj._original_collision_layer
	proj._enable_stop_delay = false
	proj._elapsed_delay = 0
	proj._sprite.material = null
	proj._animation_player.stop()
	proj.set_physics_process(false)

	Utils.disconnect_all_signal_connections(proj, "hit_something")
	Utils.disconnect_all_signal_connections(proj._hitbox, "killed_something")

	if is_instance_valid(proj._hitbox.from) and proj._hitbox.from.has_signal("died") and proj._hitbox.from.is_connected("died", proj, "on_entity_died"):
		proj._hitbox.from.disconnect("died", proj, "on_entity_died")
	
	proj.queue_free()
