extends "res://items/consumables/consumable.gd"

# =========================== Extension =========================== #
func _ready() -> void:
	_yztato_set_consumable_transparency(ProgressData.settings.yztato_set_consumable_transparency)

func _physics_process(delta: float)->void :
	_yztato_physics_process(delta)

# =========================== Custom =========================== #
func _yztato_set_consumable_transparency(alpha_value: float)->void:
	var clamped_alpha = clamp(alpha_value, 0.0, 1.0)
	modulate.a = clamped_alpha

func _yztato_physics_process(delta: float)->void :
	# Optimize Pick Up
	if ProgressData.settings.yztato_optimize_pickup:
		var current_pos: Vector2 = global_position

		if push_back and current_pos.distance_squared_to(push_back_destination) > 400:
			global_position = current_pos.linear_interpolate(push_back_destination, delta * _push_back_speed)
		elif idle_time_after_pushed_back > 0:
			if not monitorable:
				monitorable = true
			push_back = false
			idle_time_after_pushed_back -= Utils.physics_one(delta)
		elif attracted_by != null:
			if "dead" in attracted_by and attracted_by.dead:
				attracted_by = null
				_current_speed = INITIAL_ATTRACT_SPEED
			else :
				global_position = attracted_by.global_position
