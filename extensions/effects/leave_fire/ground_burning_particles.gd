extends BurningParticles

onready var timer: Timer = $Timer
onready var refresh_timer: Timer = $RefreshTimer

var on_deactivate_callback: FuncRef = null
var wait_time: float = 1.0
var field_dmg: int = 1
var is_active: bool = false
var player_index: int = 0

# ══════════════════════════════════════════ Method ══════════════════════════════════════════ #
func rescale(p_scale: float = 1.0) -> void:
    var mat = get("process_material")
    if mat != null:
        mat = mat.duplicate()
        set("process_material", mat)

        if mat.has_method("set_emission_sphere_radius"):
            mat.set_emission_sphere_radius(mat.emission_sphere_radius * p_scale)
        elif mat.has_member("emission_sphere_radius"):
            mat.emission_sphere_radius *= p_scale

        var current_amount = get("amount")
        if current_amount != null:
            set("amount", round(current_amount * p_scale * p_scale))

func set_duration(duration: float = 1.0) -> void:
    wait_time = duration

func activate(position: Vector2, data: BurningData, owner_index: int = 0) -> void:
    bodies.clear()
    global_position = position
    player_index = owner_index
    burning_data = data.duplicate() if data != null else null

    if burning_data != null:
        field_dmg = int(max(1, burning_data.damage * 0.5))
    else:
        field_dmg = 1

    is_active = true
    emitting = true
    visible = true
    timer.start(wait_time)
    refresh_timer.start()

func deactivate() -> void:
    is_active = false
    emitting = false
    visible = false
    timer.stop()
    refresh_timer.stop()
    burning_data = null
    bodies.clear()
    if on_deactivate_callback and on_deactivate_callback.is_valid():
        on_deactivate_callback.call_func(self)

func _on_Timer_timeout() -> void:
    if emitting:
        emitting = false
        timer.start(lifetime * 0.75)
        refresh_timer.stop()
    else:
        deactivate()

func _on_RefreshTimer_timeout() -> void:
    if burning_data == null:
        return

    if burning_data.spread > 0:
        burning_data.spread = 0

    for body in bodies:
        if !is_instance_valid(body):
            continue

        # A field belongs to its creator. Replaying weapon hit callbacks here
        # would recursively spawn fields; damage must not scale with co-op size.
        var args = TakeDamageArgs.new(player_index)
        args.set_meta("custom_color", Color("#F94E34"))
        args.base_effect_scale = 0.3
        body.take_damage(field_dmg, args)
