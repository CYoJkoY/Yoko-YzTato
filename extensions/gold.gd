extends "res://items/materials/gold.gd"

# =========================== Extension =========================== #
func _ready() -> void:
	_yztato_rainbow_gold()
	_yztato_set_gold_transparency(ProgressData.settings.yztato_set_gold_transparency)

func _physics_process(delta: float)->void :
	_yztato_physics_process(delta)

# =========================== Custom =========================== #
func _yztato_rainbow_gold() -> void:
	var color_name: String = ProgressData.settings.yztato_rainbow_gold
	var yz_colors: Dictionary = ProgressData.yz_colors
	if color_name != "YZ_EMPTY":
		var yz_color = yz_colors.get(color_name)
		var random_index = randi() % yz_color.size()
		modulate = Color(yz_color[random_index])

func _yztato_set_gold_transparency(alpha_value: float)->void:
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
