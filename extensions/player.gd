extends "res://entities/units/player/player.gd"

# blood_rage
var blood_rage_effects: Array = []
var blood_rage_timeout: int = 0
onready var _blood_rage_screen: ColorRect = null
onready var _blood_rage_particles: CPUParticles2D = null

# heal_on_damage_taken
var _last_damage_taken: int = 0

# chal_on_consumable_picked_up
### only_in ###
var consumables_picked_up_last_wave: int = 0
var consumables_picked_up_this_wave: int = 0

# delayed_death
var _is_dying: bool = false
var _death_delay: float = 0.0
var _death_delay_duration: float = 0.0
var _pending_die_args: Entity.DieArgs = null

# =========================== Extension =========================== #
func _ready() -> void:
    _yztato_blood_rage_ready()
    _yztato_chal_ready()

func _process(delta: float) -> void:
    _yztato_delayed_death_process(delta)

func _physics_process(delta: float) -> void:
    _yztato_blade_storm_attack_speed(delta)

func on_lifesteal_effect(value: int) -> void:
    var life_steal: int = RunData.get_player_effect(Utils.yztato_life_steal_hash, player_index)
    if life_steal != 0:
        on_healing_effect(value)
        return

    .on_lifesteal_effect(value)

func take_damage(value: int, args: TakeDamageArgs) -> Array:
    var result =.take_damage(value, args)
    _yztato_heal_on_damage_taken(result)
    _yztato_temp_stats_per_interval_reset_on_hit(result)
    _yztato_projectiles_on_hurt(result)

    return result

func die(args := Utils.default_die_args) -> void:
    if _is_dying: return

    var delay: int = _yztato_delayed_death()
    if delay >= 0:
        _yztato_start_delayed_death(delay, args)
        return

    .die(args)

func heal(value: int, is_from_torture: bool = false) -> int:
    var healed: int =.heal(value, is_from_torture)
    if _is_dying and current_stats.health > 0 and !dead: _yztato_cancel_delayed_death()

    return healed

func _on_LoseHealthTimer_timeout() -> void:
    if _yztato_lose_hp_per_second_min_hp(): return

    ._on_LoseHealthTimer_timeout()

func _on_OneSecondTimer_timeout() -> void:
    ._on_OneSecondTimer_timeout()
    _yztato_temp_stats_per_interval()

func on_consumable_picked_up(consumable_data: ConsumableData) -> void:
    .on_consumable_picked_up(consumable_data)
    _yztato_chal_on_consumable_picked_up()

# =========================== Custom =========================== #
func _yztato_blade_storm_attack_speed(delta: float) -> void:
    if dead: return

    var blade_storm: int = RunData.get_player_effect(Utils.yztato_blade_storm_hash, player_index)
    if blade_storm != 0:
        var _storm_duration = 0.0
        for weapon in current_weapons: _storm_duration += weapon.current_stats.cooldown

        _storm_duration *= max(0.1, current_stats.health * 1.0 / max_stats.health) * 0.07 / current_weapons.size()
        _storm_duration /= max(0.01, 1.0 + Utils.get_stat(Keys.stat_attack_speed_hash, player_index) / 100.0)
        _storm_duration = max(_storm_duration, 0.04)
        _weapons_container.rotation += delta / _storm_duration * TAU

        for weapon in current_weapons:
            if _weapons_container.rotation > TAU:
                weapon.disable_hitbox()
                weapon.enable_hitbox()
            weapon._hitbox.set_knockback(-Vector2(cos(weapon.global_rotation), sin(weapon.global_rotation)), weapon.current_stats.knockback, player_index)

        if _weapons_container.rotation > TAU: _weapons_container.rotation -= TAU

func _yztato_blood_rage_ready() -> void:
    blood_rage_effects = RunData.get_player_effect(Utils.yztato_blood_rage_hash, player_index)

    if !has_node("BloodRageScreen"):
        _blood_rage_screen = ColorRect.new()
        _blood_rage_screen.name = "BloodRageScreen"
        _blood_rage_screen.set_script(preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/blood_rage/blood_rage_screen.gd"))
        add_child(_blood_rage_screen)
    else: _blood_rage_screen = $BloodRageScreen

    if !has_node("BloodRageParticles"):
        var particles_scene = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/blood_rage/blood_rage_particles.tscn")
        _blood_rage_particles = particles_scene.instance()
        _blood_rage_particles.name = "BloodRageParticles"
        add_child(_blood_rage_particles)
    else:  _blood_rage_particles = $BloodRageParticles

    if _blood_rage_screen: _blood_rage_screen.visible = false
    if _blood_rage_particles: _blood_rage_particles.emitting = false

    if !blood_rage_effects.empty():
        for i in blood_rage_effects.size():
            var effect = blood_rage_effects[i]
            var blood_rage_timer = Timer.new()
            blood_rage_timer.one_shot = false
            blood_rage_timer.autostart = false
            add_child(blood_rage_timer)
            blood_rage_timer.connect("timeout", self, "yz_on_blood_rage_timer_timeout")

            var interval = effect[0]
            blood_rage_timer.wait_time = interval
            blood_rage_timer.start()

func _yztato_temp_stats_per_interval() -> void:
    # Extra process for hit_protection
    var effect: Array = RunData.get_player_effect(Keys.temp_stats_per_interval_hash, player_index)
    for sub_effect in effect:
        var stat_key_hash: int = sub_effect[0]
        if stat_key_hash != Keys.hit_protection_hash: continue

        var interval: int = sub_effect[2]

        if _one_second_timeouts % interval != 0: continue

        # The _hit_protection only affected by RunData's stat,so it will reset in _ready()
        var stat_value: int = sub_effect[1]
        _hit_protection += stat_value

func _yztato_temp_stats_per_interval_reset_on_hit(result: Array) -> void:
    # Extra process for hit_protection
    var damage_taken_bool: bool = result[1] > 0
    if !damage_taken_bool: return

    for stat in _remove_temp_stats_on_hit:
        if stat != Keys.hit_protection_hash: continue

        _hit_protection -= _remove_temp_stats_on_hit[stat]

func _yztato_heal_on_damage_taken(result: Array) -> void:
    var heal_on_damage_taken: Array = RunData.get_player_effect(Utils.yztato_heal_on_damage_taken_hash, player_index)
    _last_damage_taken = result[1]

    for effect in heal_on_damage_taken:
        var tracking_key_hash: int = effect[0]
        var chance: float = effect[1] / 100.0
        var percent: float = effect[2] / 100.0

        if Utils.get_chance_success(chance):
            var last_damage: int = _last_damage_taken
            var heal_amount: int = int(max(1, last_damage * percent))
            if heal_amount > 0: on_healing_effect(heal_amount, tracking_key_hash)

func _yztato_projectiles_on_hurt(result: Array) -> void:
    var hurt_bool: bool = result[1] > 0
    if !hurt_bool: return

    var projs_on_hurt: Array = RunData.get_player_effect(Utils.yztato_projectiles_on_hurt_hash, player_index)
    var entity_spawner = Utils.get_scene_node()._entity_spawner

    for proj in projs_on_hurt:
        var stats_caches: RangedWeaponStats = null
        var auto_target_enemy: bool = proj[3]
        var from: Node = self
        var _spawn_projectile_args: WeaponServiceSpawnProjectileArgs = WeaponServiceSpawnProjectileArgs.new()
        _spawn_projectile_args.damage_tracking_key_hash = proj[4]
        _spawn_projectile_args.from_player_index = player_index

        for _i in range(proj[1]):
            var stats: RangedWeaponStats = null

            if stats_caches != null: 
                stats = stats_caches
            else:
                stats = WeaponService.init_ranged_stats(proj[2], player_index, true)
                stats_caches = stats

            WeaponService.manage_special_spawn_projectile(
                self,
                stats,
                rand_range( - PI, PI),
                auto_target_enemy,
                entity_spawner,
                from,
                _spawn_projectile_args
            )


func _yztato_chal_ready() -> void:
    ### only_in ###
    var player_data = RunData.players_data[player_index]
    consumables_picked_up_last_wave = player_data.consumables_picked_up_this_run

    ### more_than_enough ###    
    if RunData.current_wave >= 20 and \
    RunData.get_player_character(player_index).my_id == "character_multitasker":
        ChallengeService.try_complete_challenge(Utils.chal_more_than_enough_hash, RunData.get_free_weapon_slots(player_index))

func _yztato_chal_on_consumable_picked_up() -> void:
    ### only_in ###
    var player_data = RunData.players_data[player_index]
    consumables_picked_up_this_wave = player_data.consumables_picked_up_this_run - consumables_picked_up_last_wave
    ChallengeService.try_complete_challenge(Utils.chal_only_in_hash, consumables_picked_up_this_wave)

func _yztato_lose_hp_per_second_min_hp() -> bool:
    var lose_hp_per_second_min_hp: int = RunData.get_player_effect(Utils.yztato_lose_hp_per_second_min_hp_hash, player_index)
    if lose_hp_per_second_min_hp <= 0: return false

    _take_damage_args.dodgeable = false
    _take_damage_args.armor_applied = false
    _take_damage_args.bypass_invincibility = true
    _take_damage_args.from = self
    var lose_hp_per_second: int = RunData.get_player_effect(Keys.lose_hp_per_second_hash, player_index)
    if current_stats.health - lose_hp_per_second <= lose_hp_per_second_min_hp:
        lose_hp_per_second = current_stats.health - lose_hp_per_second_min_hp

    if lose_hp_per_second > 0: take_damage(lose_hp_per_second, _take_damage_args)
    elif lose_hp_per_second < 0: on_healing_effect(-lose_hp_per_second)

    return true

func _yztato_delayed_death() -> int:
    if dead: return -1

    var delay: int = RunData.get_player_effect(Utils.yztato_delayed_death_hash, player_index)
    if delay <= 0: delay = -1

    return delay

func _yztato_start_delayed_death(delay: int, args: Entity.DieArgs) -> void:
    _is_dying = true
    _death_delay = 0.0
    _death_delay_duration = float(delay)
    _pending_die_args = args
    set_process(true)

func _yztato_delayed_death_process(delta: float) -> void:
    if _death_delay_duration <= 0.0: return

    _death_delay += delta
    if _death_delay < _death_delay_duration: return

    _yztato_finish_delayed_death()

func _yztato_finish_delayed_death() -> void:
    _is_dying = false
    _death_delay = 0.0
    _death_delay_duration = 0.0
    set_process(false)

    if is_queued_for_deletion() or cleaning_up or dead: return

    if current_stats.health > 0: return

    var args: Entity.DieArgs = _pending_die_args
    _pending_die_args = null

    .die(args)

func _yztato_cancel_delayed_death() -> void:
    _is_dying = false
    _death_delay = 0.0
    _death_delay_duration = 0.0
    _pending_die_args = null
    set_process(false)

# =========================== Method =========================== #
func yz_on_enemy_killed_reset_blood_rage() -> void:
    if !blood_rage_effects.empty():
        for effect in blood_rage_effects: 
            yz_trigger_blood_rage(effect[2], effect[1])

func yz_trigger_blood_rage(stats_change: Array, duration: float) -> void:
    if _blood_rage_screen: _blood_rage_screen.start_blood_rage(0.4)

    if _blood_rage_particles:
        _blood_rage_particles.global_position = global_position
        _blood_rage_particles.restart()

    for stat_change in stats_change:
        if stat_change[1] != 0:
            TempStats.add_stat(stat_change[0], stat_change[1], player_index)

    var timer = RunData.get_tree().create_timer(duration, false)
    timer.connect("timeout", self, "yz_on_blood_rage_timeout", [stats_change])

func yz_on_blood_rage_timeout(stats_change: Array) -> void:
    for stat_change in stats_change:
        if stat_change[1] != 0: 
            TempStats.remove_stat(stat_change[0], stat_change[1], player_index)

    if _blood_rage_screen: _blood_rage_screen.stop_blood_rage()

func yz_on_blood_rage_timer_timeout() -> void:
    if blood_rage_effects.empty(): return

    for effect in blood_rage_effects:
        yz_trigger_blood_rage(effect[2], effect[1])
