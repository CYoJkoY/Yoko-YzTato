extends "res://entities/units/player/player.gd"

var timer_stop: bool = false

# blade_storm
var blade_storm: Array = []

# blood_rage
var blood_rage_effects: Array = []
onready var _blood_rage_screen: ColorRect = null
onready var _blood_rage_particles: CPUParticles2D = null
var blood_rage_timeout: int = 0
var _active_blood_rage_effects: Array = []

# invincible_on_hit_duration
var _original_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var _is_invincible: bool = false

# random_primary_stat_on_hit, random_primary_stat_over_time
var primary_stats: Array = [
	"stat_max_hp", "stat_hp_regeneration", "stat_lifesteal", "stat_percent_damage",
	"stat_melee_damage", "stat_ranged_damage", "stat_elemental_damage", "stat_attack_speed",
	"stat_crit_chance", "stat_engineering", "stat_range", "stat_armor", "stat_dodge",
	"stat_speed", "stat_luck", "stat_harvesting"
	]
var stat_change: Array = []
var random_primary_stat_over_time_timer: int = 0

# heal_on_damage_taken
var heal_on_damage_taken: Array = []
var _last_damage_taken: int = 0

# chal_on_consumable_picked_up
### only_in ###
var consumables_picked_up_last_wave: int = 0
var consumables_picked_up_this_wave: int = 0

### more_than_enough ###
var less_than_four_throught: bool = true

# =========================== Extention =========================== #
func _ready() -> void:
	_yztato_blade_storm_ready()
	_yztato_lifesteal_ready()
	_yztato_blood_rage_ready()
	_yztato_invincible_on_hit_duration_ready()
	_yztato_random_primary_stat_over_time_ready()
	_yztato_heal_on_damage_taken_ready()
	_yztato_chal_ready()

func _physics_process(delta: float)->void :
	_yztato_blade_storm_attack_speed(delta)
	_yztato_timer_process()

func take_damage(value: int, args: TakeDamageArgs)->Array:
	var result = .take_damage(value, args)
	_yztato_invincible_on_hit_duration()
	_yztato_stat_on_hit()
	_yztato_random_primary_stat_on_hit()
	_yztato_heal_on_damage_taken(result)
	
	return result

func _on_InvincibilityTimer_timeout() -> void:
	._on_InvincibilityTimer_timeout()
	_restore_original_color()

func _on_OneSecondTimer_timeout()->void :
	._on_OneSecondTimer_timeout()
	_yztato_temp_stats_per_interval()

func on_consumable_picked_up(consumable_data: ConsumableData)->void :
	.on_consumable_picked_up(consumable_data)
	_yztato_chal_on_consumable_picked_up()

# =========================== Custom =========================== #
func _yztato_blade_storm_ready() -> void:
	blade_storm = RunData.get_player_effect("yztato_blade_storm",player_index)

func _yztato_lifesteal_ready() -> void:
	if not RunData.is_connected("lifesteal_effect", self, "_on_lifesteal_effect"):
		RunData.connect("lifesteal_effect", self, "_on_lifesteal_effect")

func _yztato_blade_storm_attack_speed(delta: float)-> void:
	if dead: return

	if blade_storm.size() > 0:
		var _storm_duration = 0
		_storm_duration = 0.0
		for weapon in current_weapons:
			_storm_duration += weapon.current_stats.cooldown
		_storm_duration *= max(0.1, current_stats.health * 1.0 / max_stats.health) * 0.07 / current_weapons.size()
		_storm_duration /= max( 1.0, current_stats.speed / 10000 / current_weapons.size() )
		_storm_duration /= max(0.01, 1.0 + Utils.get_stat("stat_attack_speed", player_index) / 100)
		_storm_duration = max(_storm_duration, 0.04)
		_weapons_container.rotation += delta / _storm_duration * TAU

		for weapon in current_weapons:
			if _weapons_container.rotation > TAU:
				weapon.disable_hitbox()
				weapon.enable_hitbox()
			weapon._hitbox.set_knockback( - Vector2(cos(weapon.global_rotation), sin(weapon.global_rotation)), weapon.current_stats.knockback, player_index)

		if _weapons_container.rotation > TAU:
				_weapons_container.rotation -= TAU

func _yztato_blood_rage_ready() -> void:
	blood_rage_effects = RunData.get_player_effect("yztato_blood_rage", player_index)
	
	if not has_node("BloodRageScreen"):
		_blood_rage_screen = ColorRect.new()
		_blood_rage_screen.name = "BloodRageScreen"
		_blood_rage_screen.set_script(preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/blood_rage/blood_rage_screen.gd"))
		add_child(_blood_rage_screen)
	else:
		_blood_rage_screen = $BloodRageScreen
	
	if not has_node("BloodRageParticles"):
		var particles_scene = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/blood_rage/blood_rage_particles.tscn")
		_blood_rage_particles = particles_scene.instance()
		_blood_rage_particles.name = "BloodRageParticles"
		add_child(_blood_rage_particles)
	else:
		_blood_rage_particles = $BloodRageParticles

	if _blood_rage_screen: _blood_rage_screen.visible = false
	if _blood_rage_particles: _blood_rage_particles.emitting = false

	if !blood_rage_effects.empty():
		for i in range(blood_rage_effects.size()):
			var effect = blood_rage_effects[i]
			var blood_rage_timer = Timer.new()
			blood_rage_timer.name = "BloodRageTimer_" + str(i)
			blood_rage_timer.one_shot = false
			blood_rage_timer.autostart = false
			add_child(blood_rage_timer)
			blood_rage_timer.connect("timeout", self, "_on_blood_rage_timer_timeout")

			var interval = effect[0]
			blood_rage_timer.wait_time = interval
			blood_rage_timer.start()

func _yztato_invincible_on_hit_duration_ready() -> void:
	_original_color = modulate

func _yztato_invincible_on_hit_duration() -> void:
	var invincible_duration = RunData.get_player_effect("yztato_invincible_on_hit_duration", player_index)
	if invincible_duration > 0:
		_invincibility_timer.wait_time = invincible_duration
		_invincibility_timer.start()
		disable_hurtbox()
		yz_apply_gold_color()

func _yztato_stat_on_hit() -> void:
	var stat_penalty = RunData.get_player_effect("yztato_stat_on_hit", player_index)
	if stat_penalty.size() > 0:
		for stat in stat_penalty:
			yz_remove_stat(stat[0], -stat[1], player_index)

func _yztato_random_primary_stat_on_hit() -> void:
	var stat_penalty = RunData.get_player_effect("yztato_random_primary_stat_on_hit", player_index)
	if stat_penalty != 0:
		var random_stat = primary_stats[randi() % primary_stats.size()]
		RunData.remove_stat(random_stat, -stat_penalty, player_index)
		RunData.emit_signal("stats_updated", player_index)

func _yztato_random_primary_stat_over_time_ready() -> void:
	stat_change = RunData.get_player_effect("yztato_random_primary_stat_over_time", player_index)

	if not stat_change.empty():
		for i in range(stat_change.size()):
			var effect = stat_change[i]
			var random_stat_timer = Timer.new()
			random_stat_timer.name = "RandomStatTimer_" + str(i)
			random_stat_timer.one_shot = false
			random_stat_timer.autostart = false
			add_child(random_stat_timer)
			random_stat_timer.connect("timeout", self, "_on_random_stat_timer_timeout")

			var interval = effect[1]
			random_stat_timer.wait_time = interval
			random_stat_timer.start()

func _yztato_timer_process() -> void:
	if timer_stop: timer_stop = false

func _yztato_temp_stats_per_interval() -> void:
	var effect: Array = RunData.get_player_effect("temp_stats_per_interval", player_index)
	for sub_effect in effect:
		var stat_key: String = sub_effect[0]
		if stat_key == "hit_protection":
			var interval: int = sub_effect[2]
			
			if _one_second_timeouts % interval == 0:
				_hit_protection = int(Utils.get_stat("hit_protection", player_index))

func _yztato_heal_on_damage_taken_ready() -> void:
	heal_on_damage_taken = RunData.get_player_effect("yztato_heal_on_damage_taken", player_index)

func _yztato_heal_on_damage_taken(result: Array) -> void:
	_last_damage_taken = result[1]

	for effect in heal_on_damage_taken:
		var chance = effect[0]
		var percent = effect[1]
		
		if randf() < chance / 100.0:
			var last_damage: int = _last_damage_taken
			var heal_amount: int = int(max(1, int(last_damage * (percent / 100.0))))
			if heal_amount > 0:
				var _healed = on_healing_effect(heal_amount, "item_yztato_insurance_policy")

func _yztato_chal_ready() -> void:
	### only_in ###
	var player_data = RunData.players_data[player_index]
	consumables_picked_up_last_wave = player_data.consumables_picked_up_this_run

	### more_than_enough ###
	if RunData.current_wave <= 20 and \
	RunData.get_player_character(player_index).my_id == "character_multitasker" and \
	RunData.get_free_weapon_slots(player_index) < 4:
		less_than_four_throught = false
		
	if RunData.current_wave == 20 and \
	RunData.get_player_character(player_index).my_id == "character_multitasker" and \
	less_than_four_throught:
		ChallengeService.try_complete_challenge("chal_more_than_enough", RunData.get_free_weapon_slots(player_index))

func _yztato_chal_on_consumable_picked_up()->void :
	### only_in ###
	var player_data = RunData.players_data[player_index]
	consumables_picked_up_this_wave = player_data.consumables_picked_up_this_run - consumables_picked_up_last_wave
	ChallengeService.try_complete_challenge("chal_only_in", consumables_picked_up_this_wave)

# =========================== Method =========================== #
func _on_lifesteal_effect(value: int, player_index: int) -> void:
	if self.player_index == player_index and not dead and is_instance_valid(self):
		var life_steal = RunData.get_player_effect("yztato_life_steal", player_index)
		if !life_steal.empty():
			on_healing_effect(value)
			return
	.on_lifesteal_effect(value)


func on_enemy_killed_reset_blood_rage() -> void:
	if !blood_rage_effects.empty():
		for effect in blood_rage_effects:
			_trigger_blood_rage(effect[2], effect[3], effect[4], effect[5], effect[6])

func _trigger_blood_rage(percent_damage_bonus: int, attack_speed_bonus: int, dodge_bonus: int, armor_bonus: int, duration: float)->void :
	if _blood_rage_screen:
		_blood_rage_screen.start_blood_rage(0.4)
	
	if _blood_rage_particles:
		_blood_rage_particles.global_position = global_position
		_blood_rage_particles.restart()
	
	if percent_damage_bonus != 0: yz_add_stat("stat_percent_damage", percent_damage_bonus, player_index)
	if attack_speed_bonus != 0: yz_add_stat("stat_attack_speed", attack_speed_bonus, player_index)
	if dodge_bonus != 0: yz_add_stat("stat_dodge", dodge_bonus, player_index)
	if armor_bonus != 0: yz_add_stat("stat_armor", armor_bonus, player_index)

	_active_blood_rage_effects.append([percent_damage_bonus, attack_speed_bonus, dodge_bonus, armor_bonus])

	var timer = RunData.get_tree().create_timer(duration, false)
	timer.connect("timeout", self, "_on_blood_rage_timeout", [[percent_damage_bonus, attack_speed_bonus, dodge_bonus, armor_bonus]])

func _clean_up_blood_rage_effects() -> void:
	for effect_data in _active_blood_rage_effects:
		var percent_damage_bonus = effect_data[0]
		var attack_speed_bonus = effect_data[1]
		var dodge_bonus = effect_data[2]
		var armor_bonus = effect_data[3]
		
		if percent_damage_bonus != 0: yz_remove_stat("stat_percent_damage", percent_damage_bonus, player_index)
		if attack_speed_bonus != 0: yz_remove_stat("stat_attack_speed", attack_speed_bonus, player_index)
		if dodge_bonus != 0: yz_remove_stat("stat_dodge", dodge_bonus, player_index)
		if armor_bonus != 0: yz_remove_stat("stat_armor", armor_bonus, player_index)
	
	_active_blood_rage_effects.clear()
	
	
	if _blood_rage_screen:
		_blood_rage_screen.stop_blood_rage()

func _on_blood_rage_timeout(effect_data: Array) -> void:
	if _active_blood_rage_effects.size() == 0: return
	var percent_damage_bonus = effect_data[0]
	var attack_speed_bonus = effect_data[1]
	var dodge_bonus = effect_data[2]
	var armor_bonus = effect_data[3]
	
	if percent_damage_bonus != 0: yz_remove_stat("stat_percent_damage", percent_damage_bonus, player_index)
	if attack_speed_bonus != 0: yz_remove_stat("stat_attack_speed", attack_speed_bonus, player_index)
	if dodge_bonus != 0: yz_remove_stat("stat_dodge", dodge_bonus, player_index)
	if armor_bonus != 0: yz_remove_stat("stat_armor", armor_bonus, player_index)
	
	_active_blood_rage_effects.erase(effect_data)

	if _blood_rage_screen:
		_blood_rage_screen.stop_blood_rage()

func yz_add_stat(stat_name: String, value: int, player_index: int) -> void:
	assert (Utils.is_stat_key(stat_name), "%s is not a stat key" % stat_name)
	var effects = RunData.get_player_effects(player_index)
	effects[stat_name] += value
	RunData._are_player_stats_dirty[player_index] = true
	Utils.reset_stat_cache(player_index)
	RunData._emit_stats_updated()

func yz_remove_stat(stat_name: String, value: int, player_index: int) -> void:
	assert (Utils.is_stat_key(stat_name), "%s is not a stat key" % stat_name)
	var effects = RunData.get_player_effects(player_index)
	effects[stat_name] -= value
	RunData._are_player_stats_dirty[player_index] = true
	Utils.reset_stat_cache(player_index)
	RunData._emit_stats_updated()

func yz_apply_gold_color() -> void:
	if not _is_invincible:
		_is_invincible = true
		modulate = Color(1.2, 1.0, 0.3, 1.0)

func _restore_original_color() -> void:
	if _is_invincible:
		_is_invincible = false
		modulate = _original_color

func _on_blood_rage_timer_timeout() -> void:
	if blood_rage_effects.empty(): return

	if timer_stop:
		for child in get_children():
			if child is Timer and child.name.begins_with("BloodRageTimer_"):
				child.stop()
		return
	else: 
		timer_stop = true

	for effect in blood_rage_effects:
		for i in effect[1]:
			_trigger_blood_rage(effect[2], effect[3], effect[4], effect[5], effect[6])

func _on_random_stat_timer_timeout() -> void:
	if stat_change.empty(): return

	if timer_stop:
		for child in get_children():
			if child is Timer and child.name.begins_with("RandomStatTimer_"):
				child.stop()
		return
	else: 
		timer_stop = true

	for effect in stat_change:
		var random_stat = primary_stats[randi() % primary_stats.size()]
		RunData.remove_stat(random_stat, -effect[0], player_index)
		RunData.emit_signal("stats_updated", player_index)
