extends "res://singletons/run_data.gd"

var yz_init_tracked_effects: Dictionary = {}

var yz_tracked_effects: Array= [{}, {}, {}, {}]

# =========================== Extension =========================== #
func _ready():
    _yztato_unlock_all_challenges()

func manage_life_steal(weapon_stats:WeaponStats, player_index:int)->void :
    if _yztato_life_steal(weapon_stats, player_index): return
    .manage_life_steal(weapon_stats, player_index)

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
    yz_tracked_effects = Utils.convert_to_hash_array(state.yz_tracked_effects.duplicate())

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

func yz_add_effect_tracking_value(yz_tracking_key_hash: int, value: float, player_index: int, index: int = 0) -> void:
    if !yz_tracked_effects[player_index].has(yz_tracking_key_hash):
        print("yz tracking key %s does not exist" % yz_tracking_key_hash)
        return

    if yz_tracked_effects[player_index][yz_tracking_key_hash] is Array:
        yz_tracked_effects[player_index][yz_tracking_key_hash][index] += value as int
    else: 
        yz_tracked_effects[player_index][yz_tracking_key_hash] += value as int

func yz_set_effect_tracking_value(yz_tracking_key_hash: int, value: float, player_index: int, index: int = 0) -> void :
    if !yz_tracked_effects[player_index].has(yz_tracking_key_hash):
        print("yz tracking key %s does not exist" % yz_tracking_key_hash)
        return

    if yz_tracked_effects[player_index][yz_tracking_key_hash] is Array:
        yz_tracked_effects[player_index][yz_tracking_key_hash][index] = value as int
    else: 
        yz_tracked_effects[player_index][yz_tracking_key_hash] = value as int

func yz_get_effect_tracking_value(yz_tracking_key_hash: int, player_index: int, index: int = 0) -> float:
    if !yz_tracked_effects[player_index].has(yz_tracking_key_hash):
        print("yz tracking key %s does not exist" % yz_tracking_key_hash)
        return 0.0
    
    if yz_tracked_effects[player_index][yz_tracking_key_hash] is Array:
        return yz_tracked_effects[player_index][yz_tracking_key_hash][index]
    else:
        return yz_tracked_effects[player_index][yz_tracking_key_hash]
