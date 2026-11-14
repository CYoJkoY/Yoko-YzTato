extends "res://entities/units/enemies/enemy.gd"

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _ready():
    _yztato_extrusion_attack_ready()

func take_damage(value: int, args: TakeDamageArgs) -> Array:
    var damage_taken =.take_damage(value, args)
    _yztato_one_shot_loot_take_damage(args)

    return damage_taken

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _yztato_extrusion_attack_ready() -> void:
    for player_index in RunData.get_player_count():
        if !RunData.get_player_effect_bool(Utils.yztato_extrusion_attack_hash, player_index):
            continue

        _hurtbox.collision_mask = Utils.ENEMIES_BIT + \
                                Utils.PLAYER_PROJECTILES_BIT + \
                                Utils.ENEMY_PROJECTILES_BIT + \
                                Utils.PET_PROJECTILES_BIT

func _yztato_one_shot_loot_take_damage(args: TakeDamageArgs) -> void:
    if dead:
        return

    if enemy_id == "evil_mob":
        return

    if not is_loot or not is_instance_valid(args.hitbox):
        return
    var owner_index: int = args.from_player_index
    if owner_index < 0 or owner_index >= RunData.get_player_count():
        return
    if not RunData.get_player_effect_bool(
        Utils.yztato_one_shot_loot_hash,
        owner_index
    ): return

    die()
