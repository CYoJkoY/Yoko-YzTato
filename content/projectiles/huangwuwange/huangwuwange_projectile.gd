extends PlayerProjectile

# EFFECT : chimera_weapon_effect
onready var sprite_node: Sprite = $Sprite
signal has_stopped

# =========================== Extension =========================== #
func _on_Hitbox_hit_something(thing_hit: Node, damage_dealt: int) -> void:
    _yztato_chimera_on_Hitbox_hit_something(_hitbox.effects)
    ._on_Hitbox_hit_something(thing_hit, damage_dealt)

func stop() -> void:
    emit_signal("has_stopped", self)
    .stop()

# =========================== Custom =========================== #
func _yztato_chimera_on_Hitbox_hit_something(effects: Array) -> void:
    for effect in effects:
        if effect.get_id() != "yztato_chimera_weapon": continue
            
        var chimera_texture_sets = effect.chimera_texture_sets
        var texture = sprite_node.texture
        if texture == null: return
            
        for texture_data in chimera_texture_sets:
            if texture.resource_path != texture_data.texture.resource_path: continue
                
            _apply_texture_modifications(texture_data)
            break

# =========================== Methods =========================== #
func _apply_texture_modifications(texture_data) -> void:
    var enable_flags = texture_data.enable_flags
    
    if enable_flags["modify_damage"]:
        _hitbox.damage = texture_data.damage
        
    if enable_flags["modify_knockback"]:
        _hitbox.knockback_amount = texture_data.knockback
        
    if enable_flags["modify_knockback_piercing"]:
        _hitbox.knockback_piercing = texture_data.knockback_piercing
        
    if enable_flags["modify_piercing"]:
        _piercing = texture_data.piercing
        
    if enable_flags["modify_piercing_dmg_reduction"]:
        _weapon_stats.piercing_dmg_reduction = texture_data.piercing_dmg_reduction
    
    if texture_data.can_bounce:
        if enable_flags["modify_bounce"]:
            _bounce = texture_data.bounce
    else:
        _bounce = 0
            
    if enable_flags["modify_bounce_dmg_reduction"]:
        _weapon_stats.bounce_dmg_reduction = texture_data.bounce_dmg_reduction
