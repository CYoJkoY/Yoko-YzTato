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

class Methods:
    # Avoid Assertion failed Caused By Function Stop
    static func yz_delete_projectile(proj: Projectile)->void :
        proj.hide()
        proj.velocity = Vector2.ZERO
        proj._hitbox.collision_layer = proj._original_collision_layer
        proj._enable_stop_delay = false
        proj._elapsed_delay = 0
        proj._sprite.material = null
        proj._animation_player.stop()
        proj.set_physics_process(false)

        Utils.disconnect_all_signal_connections(proj, "hit_something")
        Utils.disconnect_all_signal_connections(proj._hitbox, "killed_something")

        if is_instance_valid(proj._hitbox.from) and \
        proj._hitbox.from.has_signal("died") and \
        proj._hitbox.from.is_connected("died", proj, "on_entity_died"):
            proj._hitbox.from.disconnect("died", proj, "on_entity_died")
        
        proj.queue_free()
