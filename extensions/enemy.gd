extends "res://entities/units/enemies/enemy.gd"

onready var NodeHurbox = $Hurtbox

# =========================== Extension =========================== #
func _ready():
    _yztato_extrusion_attack_ready()

func take_damage(value: int, args: TakeDamageArgs) -> Array:
    var damage_taken = .take_damage(value, args)
    _yztato_one_shot_loot_take_damage(args)

    return damage_taken

# =========================== Custom =========================== #
func _yztato_extrusion_attack_ready() -> void:
    for player_index in RunData.get_player_count():
        var extrusion_attack: int = RunData.get_player_effect(Utils.yztato_extrusion_attack_hash, player_index)
        if extrusion_attack != 0:
            NodeHurbox.collision_mask = Utils.ENEMIES_BIT + \
                                        Utils.PLAYER_PROJECTILES_BIT + \
                                        Utils.ENEMY_PROJECTILES_BIT + \
                                        Utils.PET_PROJECTILES_BIT

func _yztato_one_shot_loot_take_damage(args: TakeDamageArgs) -> void:
    if dead: return
    
    if args.hitbox and \
    args.hitbox.from and \
    ( 
        not (args.hitbox.from is Object) or \
        (args.hitbox.from is Object and not "player_index" in args.hitbox.from)
    
    ): return
    
    if (args.hitbox and is_instance_valid(args.hitbox) and is_loot and \
    RunData.get_player_effect_bool(Utils.yztato_one_shot_loot_hash, args.hitbox.from.player_index)):
        die()
