extends "res://singletons/run_data.gd"

var yz_init_tracked_effects: Dictionary = {

    "item_ghost_tree": 0,
    "character_xiake_1": 0,
    "character_xiake_2": 0,

}

var yz_tracked_effects: Array= [{}, {}, {}, {}]

# =========================== Extention =========================== #
func _init() -> void:
    init_tracked_items = init_tracked_effects()

func _ready():
    _yztato_unlock_all_challenges()

func manage_life_steal(weapon_stats:WeaponStats, player_index:int)->void :
    if _yztato_life_steal(weapon_stats, player_index): return
    .manage_life_steal(weapon_stats, player_index)

func init_tracked_effects()->Dictionary:
    var vanilla_tracked: Dictionary = .init_tracked_effects()

    var new_tracked: Dictionary = {
        
        "item_yztato_cursed_box": [0, 0],

    }

    new_tracked.merge(vanilla_tracked)

    return new_tracked

func reset(restart: bool = false)->void :
    .reset(restart)
    for player_index in yz_tracked_effects.size():
        yz_tracked_effects[player_index] = yz_init_tracking_effects()

func get_state()->Dictionary:
    var state: Dictionary = .get_state()
    state.yz_tracked_effects = yz_tracked_effects.duplicate(true)

    return state

func resume_from_state(state: Dictionary)->void :
    .resume_from_state(state)
    yz_tracked_effects = state.yz_tracked_effects.duplicate()

# =========================== Custom =========================== #
func _yztato_life_steal(weapon_stats:WeaponStats, player_index:int)-> bool:
    var life_steal = RunData.get_player_effect("yztato_life_steal",player_index)
    if life_steal.size() > 0 :
        for steal in life_steal :
            if steal[0] == "better":
                var weapon_lifesteal_chance : float = weapon_stats.lifesteal
                var true_lifesteal : float = max(weapon_lifesteal_chance, 1.0)
                if randf() < weapon_stats.lifesteal:
                    emit_signal("lifesteal_effect", true_lifesteal, player_index)

            elif steal[0] == "val":
                var true_lifesteal : float = max(weapon_stats.damage * (steal[1] / 100), 1.0)
                if randf() < weapon_stats.lifesteal:
                    emit_signal("lifesteal_effect", true_lifesteal, player_index)
        return true
    return false

func _yztato_unlock_all_challenges() -> void:
    if ProgressData.settings.yztato_unlock_all_challenges:
        for chal in ChallengeService.challenges:
            ChallengeService.complete_challenge(chal.my_id)

# =========================== Methods =========================== #
func yz_init_tracking_effects()->Dictionary:
    return yz_init_tracked_effects.duplicate(true)

func yz_add_effect_tracking_value(tracking_key: String, value: float, player_index: int) -> void:
    if not yz_tracked_effects[player_index].has(tracking_key):
        print("yz tracking key %s does not exist" % tracking_key)
        return 

    yz_tracked_effects[player_index][tracking_key] += value as int

func yz_get_effect_tracking_value(tracking_key: String, player_index: int) -> float:
    if not yz_tracked_effects[player_index].has(tracking_key):
        print("yz tracking key %s does not exist" % tracking_key)
        return 0.0

    return yz_tracked_effects[player_index][tracking_key]

func yz_set_tracking_value(tracking_key: String, value: float, player_index: int) -> void :
    if not yz_tracked_effects[player_index].has(tracking_key):
        print("yz tracking key %s does not exist" % tracking_key)
        return 

    yz_tracked_effects[player_index][tracking_key] = value as int
