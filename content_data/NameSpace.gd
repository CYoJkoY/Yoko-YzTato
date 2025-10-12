extends Node

# =========================== Custom =========================== #
class LeaveFire:
	const Tscn: PackedScene = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/ground_burning_particles.tscn")

class YzProjectile:
	const Stats: Resource = preload("res://mods-unpacked/Yoko-YzTato/content/projectiles/default_stats.tres")
	const Tscn: PackedScene = preload("res://mods-unpacked/Yoko-YzTato/content/projectiles/default_projectile.tscn")
	const _Shader: ShaderMaterial = preload("res://resources/shaders/hue_shift_shadermat.tres")
	const SwordArray: StreamTexture = preload("res://mods-unpacked/Yoko-YzTato/content/projectiles/sword_array/sword_array.webp")