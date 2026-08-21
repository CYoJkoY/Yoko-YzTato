extends "res://entities/units/player/weapons_container.gd"

# ══════════════════════════════════════════ Constants & Variables ══════════════════════════════════════════ #

const _LAYOUT_CONFIG: Dictionary = {
    1: {
        "node_pattern": "_one_weapon_attachment_%d",
        "plus_angle": 0.5 * PI,
        "reindex": {}
    },

    2: {
        "node_pattern": "_two_weapons_attachment_%d",
        "plus_angle": 0.0 * PI,
        "reindex": {}
    },

    3: {
        "node_pattern": "_three_weapons_attachment_%d",
        "plus_angle": 0.166666 * PI,
        "reindex": {}
    },

    4: {
        "node_pattern": "_four_weapons_attachment_%d",
        "plus_angle": 0.25 * PI,
        "reindex": {}
    },

    5: {
        "node_pattern": "_five_weapons_attachment_%d",
        "plus_angle": 0.0,
        "reindex": {3: 4, 4: 3}
    },

    6: {
        "node_pattern": "_six_weapons_attachment_%d",
        "plus_angle": 0.3333333 * PI,
        "reindex": {3: 5, 4: 3, 5: 4}
    },
}

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #

func update_weapons_positions(weapons: Array) -> void:
    if _yztato_blade_storm_positions(weapons):
        return

    .update_weapons_positions(weapons)

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #

func _yztato_blade_storm_positions(weapons: Array) -> bool:
    var has_blade_storm: bool = false
    for player_index in RunData.players_data.size():
        if RunData.get_player_effect_bool(Utils.yztato_blade_storm_hash, player_index):
            has_blade_storm = true
            break

    if not has_blade_storm:
        return false

    var count: int = weapons.size()
    if count == 0:
        return false

    var total_range: float = 0.0
    for weapon in weapons:
        total_range += weapon.current_stats.max_range
    var attack_range: float = max(total_range / (count * 100.0), 0.5)

    if count <= 6:
        var layout: Dictionary = _LAYOUT_CONFIG.get(count)
        if layout == null:
            return false

        var node_pattern: String = layout["node_pattern"]
        var plus_angle: float = layout["plus_angle"]
        var reindex: Dictionary = layout["reindex"]
        var angle_step: float = TAU / count

        for i in count:
            var node: Node = get_node(node_pattern % (i + 1))
            if node == null:
                continue

            var pos: Vector2 = node.position
            if count == 2:
                pos.y = 0

            var real_idx: int = reindex.get(i, i)
            weapons[i].attach(pos * attack_range, real_idx * angle_step + plus_angle)
            weapons[i].enable_hitbox()
        return true

    else:
        var radius: int = 50 + (count - 6) * 5
        var angle_step: float = TAU / count
        for i in count:
            var angle: float = i * angle_step
            var pos: Vector2 = Vector2(radius * cos(angle) * attack_range, radius * sin(angle) * attack_range)
            weapons[i].attach(pos, angle)
            weapons[i].enable_hitbox()
        return true
