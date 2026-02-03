extends Resource

export(Resource) var texture = null
export(int) var damage = 1
export(int, -10000, 10000) var knockback = 0
export(float, 0.0, 1.0, 0.05) var knockback_piercing = 0.0
export(int) var piercing = 0
export(float, 0, 1, 0.05) var piercing_dmg_reduction = 0.5
export(int) var bounce = 0
export(float, 0, 1, 0.05) var bounce_dmg_reduction = 0.5
export(bool) var can_bounce = true
export(Array, Resource) var effects = []

export(Dictionary) var enable_flags = {
    "modify_damage": false,
    "modify_knockback": false,
    "modify_knockback_piercing": false,
    "modify_projectile_speed": false,
    "modify_piercing": true,
    "modify_piercing_dmg_reduction": true,
    "modify_bounce": true,
    "modify_bounce_dmg_reduction": true,
    "modify_effects": false,
}

func serialize() -> Dictionary:
    var effects_paths: Array = []
    for effect in effects:
        effects_paths.append(effect.resource_path)

    var serialized: Dictionary = {
        "damage": damage,
        "knockback": knockback,
        "knockback_piercing": knockback_piercing,
        "piercing": piercing,
        "piercing_dmg_reduction": piercing_dmg_reduction,
        "bounce": bounce,
        "bounce_dmg_reduction": bounce_dmg_reduction,
        "can_bounce": can_bounce,
        "effects": effects_paths,
        "enable_flags": enable_flags.duplicate(true)
    }

    if texture != null:
        serialized.texture = texture.resource_path
    
    return serialized

func deserialize_and_merge(serialized: Dictionary):
    effects = []
    for effect_path in serialized.effects:
        var effect: Effect = load(effect_path)
        if effect != null:
            effects.append(effect)

    damage = serialized.damage
    knockback = serialized.knockback
    knockback_piercing = serialized.knockback_piercing
    piercing = serialized.piercing
    piercing_dmg_reduction = serialized.piercing_dmg_reduction
    bounce = serialized.bounce
    bounce_dmg_reduction = serialized.bounce_dmg_reduction
    can_bounce = serialized.can_bounce
    enable_flags = serialized.enable_flags

    if serialized.has("texture"):
        texture = load(serialized.texture)
