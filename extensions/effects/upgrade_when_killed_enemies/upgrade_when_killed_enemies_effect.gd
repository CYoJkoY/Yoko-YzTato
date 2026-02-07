extends GainStatEveryKilledEnemiesEffect

static func get_id() -> String:
    return "yztato_upgrade_when_killed_enemies"

func get_args(_player_index: int) -> Array:
    var displayed_key = key

    if custom_key == "starting_weapon":
        displayed_key = key.substr(0, key.length() - 2)

    return [str(value), tr(displayed_key.to_upper())]
