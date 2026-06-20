extends Node2D

onready var line = $Line2D

var start_point: Vector2 = Vector2.ZERO
var end_point: Vector2 = Vector2.ZERO
var displacement: float = 50.0
var detail: int = 10

# =========================== Extension =========================== #
func setup(start: Vector2, end: Vector2, dis: float = 50.0, det: int = 10) -> void:
	global_position = Vector2.ZERO
	start_point = start
	end_point = end
	displacement = dis
	detail = det
	line.points = generate_lightning(start_point, end_point)

func generate_lightning(start: Vector2, end: Vector2) -> PoolVector2Array:
	var points := PoolVector2Array([start])
	var perpendicular: Vector2 = (end - start).rotated(PI / 2).normalized()
	
	_generate_segment(start, end, displacement, perpendicular, points)
	points.append(end)
	return points

# =========================== Method =========================== #
func _generate_segment(
	start: Vector2,
	end: Vector2,
	disp: float,
	perp: Vector2,
	points: PoolVector2Array
):
	if points.size() >= detail: return

	var mid: Vector2 = (start + end) / 2
	var offset: float = (randf() - 0.5) * 2 * disp
	var new_point: Vector2 = mid + perp * offset
	points.append(new_point)
	
	var new_disp: float = disp * 0.5
	_generate_segment(start, new_point, new_disp, perp, points)
	_generate_segment(new_point, end, new_disp, perp, points)
