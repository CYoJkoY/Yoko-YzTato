extends MovementBehavior

var spiral_angle: float = 0.0
var spiral_radius: float = 0.0
var center_position: Vector2 = Vector2.ZERO
var initial_distance: float = 0.0
var rotation_direction: int = 1
var phase: int = 0

func _init() -> void:
	randomize()
	rotation_direction = 1 if randf() > 0.5 else -1


func get_movement() -> Vector2:
	var target = get_target_position()
	if target == null:
		return Vector2.ZERO
	
	return target - _parent.global_position


func get_target_position():
	if center_position == Vector2.ZERO:
		center_position = ZoneService.get_map_center()
		initial_distance = _parent.global_position.distance_to(center_position)
		spiral_radius = initial_distance
	
	if phase == 0:
		spiral_angle += 0.05 * rotation_direction
		spiral_radius = max(0, spiral_radius - 0.5)
		
		if spiral_radius < 5:
			phase = 1
			spiral_radius = 0
	else:
		spiral_angle += 0.05 * rotation_direction
		spiral_radius = min(initial_distance, spiral_radius + 0.5)
		
		if spiral_radius >= initial_distance:
			phase = 0
			spiral_radius = initial_distance
	
	var offset = Vector2(
		cos(spiral_angle) * spiral_radius,
		sin(spiral_angle) * spiral_radius
	)
	
	return center_position + offset