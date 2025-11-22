extends Node

# =========================== Custom =========================== #
class LeaveFire:
    static func Tscn() -> Resource:
        return load("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/ground_burning_particles.tscn")

class YzProjectile:
    static func Stats() -> Resource:
        return load("res://mods-unpacked/Yoko-YzTato/content/projectiles/default_stats.tres")
        
    static func Tscn() -> Resource:
        return load("res://mods-unpacked/Yoko-YzTato/content/projectiles/default_projectile.tscn")
        
    static func Shader() -> Resource:
        return load("res://resources/shaders/hue_shift_shadermat.tres")
        
    static func SwordArray() -> Resource:
        return load("res://mods-unpacked/Yoko-YzTato/content/projectiles/sword_array/sword_array.webp")
