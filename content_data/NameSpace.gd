extends Node

# =========================== Custom =========================== #
class Chimera:
	const _Effect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/chimera_weapon/chimera_weapon_effect.gd")

class LeaveFire:
	const _Effect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/leave_fire_effect.gd")
	const Tscn: PackedScene = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/ground_burning_particles.tscn")

class GainStatWhenKilledSingleScaling:
	const _Effect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/gain_stat_when_killed_single_scaling/gain_stat_when_killed_single_scaling_effect.gd")

class MeleeEffect:
	const EraseEffect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/melee_effect/melee_erase_effect.gd")
	const BounceEffect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/melee_effect/melee_bounce_effect.gd")

class Boomerang:
	const _Effect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/boomerang_weapon/boomerang_weapon_effect.gd")

class MultiHit:
	const _Effect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/multi_hit/multi_hit_effect.gd")

class VineTrap:
	const _Effect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/vine_trap/vine_trap_effect.gd")

class CanAttackWhileMoving:
	const _Effect: Resource = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/can_attack_while_moving/can_attack_while_moving_effect.gd")

class YzProjectile:
	const Stats: Resource = preload("res://mods-unpacked/Yoko-YzTato/content/projectiles/default_stats.tres")
	const Tscn: PackedScene = preload("res://mods-unpacked/Yoko-YzTato/content/projectiles/default_projectile.tscn")
	const _Shader: ShaderMaterial = preload("res://resources/shaders/hue_shift_shadermat.tres")
	const SwordArray: StreamTexture = preload("res://mods-unpacked/Yoko-YzTato/content/projectiles/sword_array/sword_array.webp")