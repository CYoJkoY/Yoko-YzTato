extends "res://singletons/run_data.gd"

var yz_init_tracked_effects: Dictionary = {

    Utils.yztato_item_ghost_tree_hash: 0,
    Utils.yztato_character_xiake_1_hash: 0,
    Utils.yztato_character_xiake_2_hash: 0,

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
        
        Utils.item_yztato_cursed_box_hash: [0, 0],

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
    var life_steal: int = RunData.get_player_effect(Utils.yztato_life_steal_hash, player_index)
    if life_steal != 0:
        var true_lifesteal : float = max(weapon_stats.damage * (life_steal / 100), 1.0)
        if Utils.get_chance_success(weapon_stats.lifesteal):
            emit_signal("lifesteal_effect", true_lifesteal, player_index)
        return true
    return false

func _yztato_unlock_all_challenges() -> void:
    if ProgressData.settings.yztato_unlock_all_challenges:
        for chal in ChallengeService.challenges:
            ChallengeService.complete_challenge(chal.my_id_hash)

# =========================== Methods =========================== #
func yz_init_tracking_effects()->Dictionary:
    return yz_init_tracked_effects.duplicate(true)

func yz_add_effect_tracking_value(tracking_key_hash: int, value: float, player_index: int) -> void:
    if !yz_tracked_effects[player_index].has(tracking_key_hash):
        return 

    yz_tracked_effects[player_index][tracking_key_hash] += value as int

func yz_get_effect_tracking_value(tracking_key_hash: int, player_index: int) -> float:
    if !yz_tracked_effects[player_index].has(tracking_key_hash):
        return 0.0

    return yz_tracked_effects[player_index][tracking_key_hash]

func yz_set_tracking_value(tracking_key_hash: int, value: float, player_index: int) -> void :
    if !yz_tracked_effects[player_index].has(tracking_key_hash):
        return 

    yz_tracked_effects[player_index][tracking_key_hash] = value as int
