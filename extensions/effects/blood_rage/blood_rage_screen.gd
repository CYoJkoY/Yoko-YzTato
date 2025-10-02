extends ColorRect

var distortion_intensity: float = 0.0
var target_intensity: float = 0.0
var fade_speed: float = 3.0
var active: bool = false

func _ready():
	material = ShaderMaterial.new()
	material.shader = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/blood_rage/blood_rage.gdshader")
	material.set_shader_param("blood_rage_color", Color(0.0, 0.5, 1.0, 1.0))
	material.set_shader_param("distortion_intensity", 0.0)
	material.set_shader_param("wave_speed", 2.0)
	material.set_shader_param("wave_amount", 0.1)
	
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = MOUSE_FILTER_IGNORE

func _process(delta):
	if active:
		distortion_intensity = lerp(distortion_intensity, target_intensity, fade_speed * delta)
		material.set_shader_param("distortion_intensity", distortion_intensity)
	else:
		distortion_intensity = lerp(distortion_intensity, 0.0, fade_speed * delta)
		material.set_shader_param("distortion_intensity", distortion_intensity)
		
		if distortion_intensity < 0.01:
			visible = false

func start_blood_rage(intensity: float = 0.5):
	active = true
	target_intensity = intensity
	visible = true

func stop_blood_rage():
	active = false
	target_intensity = 0.0
