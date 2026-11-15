extends "res://main.gd"

# EFFECT : special_picked_up_change_stat
var special_picked_up_count: Dictionary = {}

# EFFECT : monster_yarn_ball drops
const YZTATO_MONSTER_YARN_BALL_PATH: String = "res://mods-unpacked/Yoko-YzTato/content/consumables/monster_yarn_ball/monster_yarn_ball_data.tres"

# Rolled once per enemy killed by a player, independently of the base game's
# consumable/fruit drop chance, so the yarn ball rate only depends on suture.
const YZTATO_YARN_BALL_BASE_DROP_CHANCE: float = 0.02
const YZTATO_YARN_BALL_DROP_CHANCE_PER_SUTURE: float = 0.003
const YZTATO_YARN_BALL_MAX_DROP_CHANCE: float = 0.12

var _yztato_yarn_ball_data: ConsumableData = null

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _on_EndWaveTimer_timeout() -> void:
    ._on_EndWaveTimer_timeout()
    _yztato_destory_weapons()
    _yztato_set_stat()

func on_consumable_picked_up(consumable: Node, player_index: int) -> void:
    if consumable.already_picked_up:
        return

    .on_consumable_picked_up(consumable, player_index)
    _yztato_dispatch_consumable_pickup_effects(consumable, player_index)
    _yztato_special_picked_up_change_stat(consumable, player_index)

func on_levelled_up(player_index: int) -> void:
    .on_levelled_up(player_index)
    _yztato_stats_chance_on_level_up(player_index)

func spawn_consumables(unit: Unit) -> void:
    _yztato_spawn_monster_yarn_ball(unit)
    .spawn_consumables(unit)

func _on_EntitySpawner_players_spawned(players: Array) -> void:
    ._on_EntitySpawner_players_spawned(players)

func _yztato_destory_weapons() -> void:
    for player_index in RunData.players_data.size():
        var yztato_destory_weapon: Array = RunData.get_player_effect(
            Utils.yztato_destory_weapons_hash,
            player_index
        )
        if yztato_destory_weapon.size() > 0:
            for weapon_id in yztato_destory_weapon:
                for i in weapon_id[1]:
                    var old_weapons: Array = RunData.get_player_weapons(player_index)
                    var new_weapons: Array = []
                    for new_weapon in old_weapons:
                        if new_weapon.weapon_id_hash == weapon_id[0]:
                            new_weapons.append(new_weapon)
                    RunData.remove_all_weapons(player_index)
                    for new_weapon in new_weapons:
                        RunData.apply_item_effects(new_weapon, player_index)
                    RunData.players_data[player_index].weapons = new_weapons

func _yztato_set_stat() -> void:
    for player_index in RunData.players_data.size():
        var set_stat: Array = RunData.get_player_effect(Utils.yztato_set_stat_hash, player_index)
        if set_stat.size() > 0:
            for stat_id in set_stat:
                RunData.players_data[player_index].effects[stat_id[0]] = stat_id[1]

func _yztato_special_picked_up_change_stat(consumable: Node, player_index: int) -> void:
    var special_picked_up_change_stat: Array = RunData.get_player_effect(
        Utils.yztato_special_picked_up_change_stat_hash,
        player_index
    )
    if special_picked_up_change_stat.size() > 0:
        for change in special_picked_up_change_stat:
            if consumable.consumable_data.my_id_hash == change[0]:
                if int(change[1]) <= 0:
                    continue
                if not special_picked_up_count.has(player_index):
                    special_picked_up_count[player_index] = {}
                var counts: Dictionary = special_picked_up_count[player_index]
                counts[change[0]] = counts.get(change[0], 0) + 1
                if counts[change[0]] % int(change[1]) == 0:
                    RunData.add_stat(change[2], change[3], player_index)

func _yztato_dispatch_consumable_pickup_effects(consumable: Node, player_index: int) -> void:
    for effect in RunData.get_player_effect(Utils.yztato_pickup_consumable_spawn_pet_hash, player_index).duplicate():
        effect.on_consumable_picked_up(consumable, player_index)

func _yztato_spawn_monster_yarn_ball(unit: Unit) -> void:
    if _cleaning_up or not (unit is Enemy):
        return

    if not unit.can_drop_loot:
        return

    var suture: float = _yztato_get_max_suture()
    if suture <= 0.0:
        return

    if not Utils.get_chance_success(_yztato_get_yarn_ball_drop_chance(suture)):
        return

    var yarn_ball: ConsumableData = _yztato_get_yarn_ball_data()
    if yarn_ball == null:
        return

    var pos: Vector2 = ZoneService.get_rand_pos_in_area(
        unit.global_position, rand_range(50, 100 + unit.stats.gold_spread), 0
    )
    spawn_consumable(yarn_ball.duplicate() as ConsumableData, pos, unit.global_position)

func _yztato_get_yarn_ball_data() -> ConsumableData:
    if _yztato_yarn_ball_data == null:
        _yztato_yarn_ball_data = load(YZTATO_MONSTER_YARN_BALL_PATH) as ConsumableData

    return _yztato_yarn_ball_data

func _yztato_get_max_suture() -> float:
    var suture: float = 0.0
    for player_index in RunData.get_player_count():
        suture = max(suture, Utils.get_stat(Utils.stat_yztato_suture_hash, player_index))

    return suture

func _yztato_get_yarn_ball_drop_chance(suture: float) -> float:
    var chance: float = (
        YZTATO_YARN_BALL_BASE_DROP_CHANCE + suture * YZTATO_YARN_BALL_DROP_CHANCE_PER_SUTURE
    )

    return clamp(chance, 0.0, YZTATO_YARN_BALL_MAX_DROP_CHANCE)

func _yztato_stats_chance_on_level_up(player_index: int) -> void:
    for chance_effect in RunData.get_player_effect(Utils.yztato_stats_chance_on_level_up_hash, player_index):
        var stat_hash: int = chance_effect[0]
        var stat_increase: int = chance_effect[1]
        var chance: int = chance_effect[2]
        var tracking_key_hash: int = chance_effect[3]

        if Utils.get_chance_success(chance / 100.0):
            RunData.add_stat(stat_hash, stat_increase, player_index)
            RunData.ncl_add_effect_tracking_value(tracking_key_hash, stat_increase, player_index)
