extends "res://projectiles/player_explosion.gd"

# =========================== Extension =========================== #
func start_explosion() -> void:
    _yztato_explosion_erase(player_index)
    .start_explosion()

# =========================== Custom =========================== #
func _yztato_explosion_erase(player_index: int) -> void:
    if !is_inside_tree(): return
    var explosion_erase: int = RunData.get_player_effect(Utils.yztato_explosion_erase_bullets_hash, player_index)
    if explosion_erase != 0:
        _hitbox.monitoring = true
        _hitbox.collision_mask = Utils.ENEMY_PROJECTILES_BIT
        var _bullets_entered: int = _hitbox.connect("area_entered", self , "yz_on_Hitbox_area_entered")

# =========================== Custom =========================== #
func yz_on_Hitbox_area_entered(area: Area2D) -> void:
    if area.get_parent() is EnemyProjectile:
        Utils.yz_delete_projectile(area.get_parent())
