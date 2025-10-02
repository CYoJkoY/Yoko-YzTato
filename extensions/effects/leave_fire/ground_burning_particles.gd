extends BurningParticles

onready var timer: Timer = $Timer
onready var refresh_timer: Timer = $RefreshTimer

var wait_time: float = 1.0
var field_dmg: int = 1
var is_active: bool = false

# =========================== Method =========================== #
func rescale(p_scale:float = 1.0)-> void:
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

func set_duration(duration:float = 1.0)-> void:
	wait_time = duration

func activate(position: Vector2, data: BurningData)-> void:
	global_position = position
	burning_data = data

	if burning_data != null:
		field_dmg = int(max(1, burning_data.damage * 0.5))
	else:
		field_dmg = 1

	is_active = true
	emitting = true
	visible = true
	timer.start(wait_time)
	refresh_timer.start()

func deactivate()-> void:
	is_active = false
	emitting = false
	visible = false
	timer.stop()
	refresh_timer.stop()
	burning_data = null
	bodies.clear()

func _on_Timer_timeout()-> void:
	if emitting:
		emitting = false
		timer.start(lifetime * 0.75)
		refresh_timer.stop()
	else:
		deactivate()

func _on_RefreshTimer_timeout()-> void:
	if burning_data == null:
		return
	if burning_data.spread > 0:
		burning_data.spread = 0
	for body in bodies:
		if body != null and is_instance_valid(body) and body.has_method("take_damage"):
			for player_index in RunData.players_data.size():
				var args = TakeDamageArgs.new(player_index)
				args.base_effect_scale = 0.3
				var dmg_dealt = body.take_damage(field_dmg, args)[1]
				if burning_data.from != null and is_instance_valid(burning_data.from):
					burning_data.from._on_Hitbox_hit_something(body, dmg_dealt)
