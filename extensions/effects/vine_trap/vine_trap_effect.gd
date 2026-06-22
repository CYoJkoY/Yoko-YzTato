extends StructureEffect

const DotStructureWeaponStats = preload("res://mods-unpacked/Yoko-YzTato/content/structures/dot_structure_stats.gd")

export(int) var trap_count: int = 1
export(int) var chance: int = 100

var weapon_pos: int = -1

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_vine_trap"

func apply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].append([trap_count, chance, self])

func unapply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].erase([trap_count, chance, self])

func get_args(player_index: int) -> Array:
    var init_stats: RangedWeaponStats = WeaponService.init_structure_stats(stats, player_index, _init_stats_args_structure)
    var damage_text: String = Utils.ncl_get_dmg_text_with_scaling_stats(
        init_stats.damage, init_stats.scaling_stats,
        {
            "player_index": player_index
        }
    )

    return [
        str(trap_count),
        str(chance),
        str(round(init_stats.cooldown / 60.0 * 100.0) / 100.0),
        str(stats.speed_percent_modifier),
        damage_text
    ]

func serialize() -> Dictionary:
    var serialized =.serialize()
    serialized.trap_count = trap_count
    serialized.chance = chance
    
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    var struct_stats = DotStructureWeaponStats.new()
    struct_stats.deserialize_and_merge(serialized.stats)
    stats = struct_stats
    trap_count = serialized.trap_count as int
    chance = serialized.chance as int
