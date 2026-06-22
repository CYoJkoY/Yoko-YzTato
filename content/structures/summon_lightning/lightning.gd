extends Node2D

onready var line = $"Line2D"
onready var tween = $"Tween"
onready var clear_timer = $"ClearTimer"

var displacement: float = 80.0
var detail: int = 25
var fade_duration: float = 0.3
var fade_delay: float = 0.1

# =========================== Extension =========================== #
func setup(start: Vector2, end: Vector2, dis: float = 80.0, det: int = 25, fade_time: float = 0.3) -> void:
    global_position = start
    var local_start = Vector2.ZERO
    var local_end = end - start

    displacement = dis
    detail = int(clamp(det, 3, 100))
    fade_duration = fade_time

    line.points = generate_lightning(local_start, local_end)

    line.modulate = Color(1, 1, 1, 1)

    tween.interpolate_property(
        line,
        "modulate",
        Color(1, 1, 1, 1),
        Color(1, 1, 1, 0),
        fade_duration,
        Tween.TRANS_LINEAR,
        Tween.EASE_IN,
        fade_delay
    )
    tween.start()

    clear_timer.wait_time = fade_duration + fade_delay + 0.1
    clear_timer.start()

# =========================== Custom =========================== #
func generate_lightning(start: Vector2, end: Vector2) -> PoolVector2Array:
    var points := PoolVector2Array([start])
    var total_points = detail
    var count = total_points - 1
    if count <= 0:
        points.append(end)
        return points

    var dir = (end - start).normalized()
    var perp = dir.rotated(PI / 2).normalized()

    var disp = displacement
    for i in range(1, count):
        var t = i / float(count)
        var base = start.linear_interpolate(end, t)
        var offset_magnitude = (randf() - 0.5) * 2 * disp * (1.0 - t * 0.8)
        var point = base + perp * offset_magnitude
        points.append(point)
        disp *= 0.65
        if disp < 0.5: disp = 0.5

    points.append(end)
    return points

# =========================== Method =========================== #
func _on_ClearTimer_timeout():
    if !is_queued_for_deletion(): queue_free()
