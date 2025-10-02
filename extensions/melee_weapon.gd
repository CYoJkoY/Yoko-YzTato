extends "res://weapons/melee/melee_weapon.gd"

# EFFECT : melee_bounce
var projectile_shader: = preload("res://resources/shaders/hue_shift_shadermat.tres")

# EFFECT : blade_storm
onready var _collision: CollisionShape2D = $Sprite / Hitbox / Collision
onready var YZ_is_blade_storm: bool = _yztato_blade_storm(player_index)

# EFFECT : flying_sword
onready var YZ_is_flying_sword: bool = _yztato_flying_sword(player_index)
var YZ_rng := RandomNumberGenerator.new()
var idle_angle: float = 0.0
var has_attacked_target: bool = false
var _current_locked_target: Node = null

# EFFECT : gain_stat_when_killed_scaling_single
var kill_count: Dictionary = {}
var effect_single_kill_count: Dictionary = {}

# EFFECT : leave_fire
var _burning_particles_manager = null

# EFFECT : vine_trap
onready var _entity_spawner = get_tree().current_scene.get_node("EntitySpawner")

# =========================== Extention =========================== #
func _ready()->void :
	_yztato_melee_erase()
	_yztato_melee_bounce()
	_yztato_leave_fire_ready()
	_yztato_set_weapon_transparency(ProgressData.settings.yztato_set_weapon_transparency)

func _physics_process(_delta: float) -> void:
	_yztato_flying_sword(player_index)

func _on_Hitbox_hit_something(thing_hit: Node, damage_dealt: int) -> void:
	._on_Hitbox_hit_something(thing_hit, damage_dealt)
	_yztato_flying_sword_erase(thing_hit, player_index)
	

func on_weapon_hit_something(thing_hit: Node, damage_dealt: int, hitbox: Hitbox):
	.on_weapon_hit_something(thing_hit, damage_dealt, hitbox)
	if thing_hit._burning != null:
		_yztato_leave_fire(thing_hit, player_index)
	_yztato_multi_hit(thing_hit, damage_dealt, player_index)
	_yztato_vine_trap(thing_hit, player_index)
	
func update_sprite_flipv() -> void:
	if YZ_is_blade_storm: return
	.update_sprite_flipv()


func update_idle_angle() -> void:
	if YZ_is_blade_storm:
		_current_idle_angle = _idle_angle
		return
	.update_idle_angle()


func get_direction() -> float:
	var direction = .get_direction()
	direction = _yztato_blade_storm_direction(direction)

	return direction


func get_direction_and_calculate_target() -> float:
	var target = .get_direction_and_calculate_target()
	target = _yztato_blade_storm_target(target)

	return target

func shoot() -> void:
	if YZ_is_flying_sword or YZ_is_blade_storm: return
	.shoot()

func on_killed_something(_thing_killed: Node, hitbox: Hitbox) -> void:
	.on_killed_something(_thing_killed, hitbox)
	_yztato_gain_stat_when_killed_scaling_single()

func should_shoot()->bool:
	var should_shoot: bool = .should_shoot()
	should_shoot = _yztato_can_attack_while_moving(should_shoot)

	return should_shoot

# =========================== Custom =========================== #
func _yztato_melee_erase()-> void:
	for player_index in RunData.players_data.size():
		var melee_erase = RunData.get_player_effect("yztato_melee_erase_bullets",player_index)
		if melee_erase:
			var node_range = get_node("Range")
			var node_hit_box = get_node("Sprite").get_node("Hitbox")
			node_range.collision_mask = Utils.NEUTRAL_BIT + Utils.ENEMIES_BIT + Utils.ENEMY_PROJECTILES_BIT
			node_range.connect("area_entered",self,"yz_on_Range_area_entered")
			node_range.connect("area_exited",self,"yz_on_Range_area_exited")
			node_hit_box.monitoring = true
			node_hit_box.collision_mask = Utils.ENEMY_PROJECTILES_BIT
			node_hit_box.connect("area_entered",self,"yz_on_Hitbox_area_entered_erase")

	for effect in effects:
		if effect is ProgressData.Yztato.MeleeEffect.EraseEffect:
			var node_range = get_node("Range")
			var node_hit_box = get_node("Sprite").get_node("Hitbox")
			node_range.collision_mask = Utils.NEUTRAL_BIT + Utils.ENEMIES_BIT + Utils.ENEMY_PROJECTILES_BIT
			node_range.connect("area_entered",self,"yz_on_Range_area_entered")
			node_range.connect("area_exited",self,"yz_on_Range_area_exited")
			node_hit_box.monitoring = true
			node_hit_box.collision_mask = Utils.ENEMY_PROJECTILES_BIT
			node_hit_box.connect("area_entered",self,"yz_on_Hitbox_area_entered_erase")

func _yztato_melee_bounce()-> void:
	for player_index in RunData.players_data.size():
		var melee_bounce = RunData.get_player_effect("yztato_melee_bounce_bullets",player_index)
		if melee_bounce:
			var node_range = get_node("Range")
			var node_hit_box = get_node("Sprite").get_node("Hitbox")
			node_range.collision_mask = Utils.NEUTRAL_BIT + Utils.ENEMIES_BIT + Utils.ENEMY_PROJECTILES_BIT
			node_range.connect("area_entered",self,"yz_on_Range_area_entered")
			node_range.connect("area_exited",self,"yz_on_Range_area_exited")
			node_hit_box.monitoring = true
			node_hit_box.collision_mask = Utils.ENEMY_PROJECTILES_BIT
			node_hit_box.connect("area_entered",self,"yz_on_Hitbox_area_entered_bounce", [melee_bounce, node_hit_box])

	for effect in effects:
		if effect is ProgressData.Yztato.MeleeEffect.BounceEffect:
			var node_range = get_node("Range")
			var node_hit_box = get_node("Sprite").get_node("Hitbox")
			node_range.collision_mask = Utils.NEUTRAL_BIT + Utils.ENEMIES_BIT + Utils.ENEMY_PROJECTILES_BIT
			node_range.connect("area_entered",self,"yz_on_Range_area_entered")
			node_range.connect("area_exited",self,"yz_on_Range_area_exited")
			node_hit_box.monitoring = true
			node_hit_box.collision_mask = Utils.ENEMY_PROJECTILES_BIT
			node_hit_box.connect("area_entered",self,"yz_on_Hitbox_area_entered_bounce", [effect.value, node_hit_box])

func _yztato_set_weapon_transparency(alpha_value: float) -> void:
	var clamped_alpha = clamp(alpha_value, 0.0, 1.0)
	modulate.a = clamped_alpha

func _yztato_flying_sword(player_index: int) -> bool:
	var flying_sword = RunData.get_player_effect("yztato_flying_sword", player_index)
	if flying_sword.size() == 0:
		return false

	YZ_rng.randomize()
	var player_level = RunData.players_data[player_index].current_level

	for mode in flying_sword:
		match mode[0]:
			"attack", "attack_limit":
				if yz_meets_condition(mode, current_stats.damage):
					return yz_process_attack_mode()
			"sword_array", "sword_array_limit":
				if yz_meets_condition(mode, current_stats.damage):
					return yz_process_sword_array_mode(player_level)

	return false

func _yztato_blade_storm(player_index: int) -> bool:
	var blade_storm = RunData.get_player_effect("yztato_blade_storm", player_index)
	if blade_storm.size() == 0:
		return false

	for blade in blade_storm:
		var offset = _collision.shape.extents.x * 0.5
		_collision.shape.extents.x = offset
		_collision.position.x *= 0.5
		_collision.position.x += offset

		if blade[0] == "Normal":
			return true
		elif blade[0] == "OP":
			var node_hit_box = get_node("Sprite").get_node("Hitbox")
			node_hit_box.monitoring = true
			node_hit_box.collision_mask = Utils.ENEMY_PROJECTILES_BIT
			node_hit_box.connect("area_entered", self, "yz_on_Hitbox_area_entered")
			return true

	return false

func _yztato_leave_fire_ready() -> void:
	_burning_particles_manager = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/burning_particles_manager.gd").new()
	get_tree().current_scene.call_deferred("add_child", _burning_particles_manager)

func _yztato_leave_fire(thing_hit: Node, player_index: int) -> void:
	for fire in effects:
		if fire is ProgressData.Yztato.LeaveFire._Effect:
			var new_fire = _burning_particles_manager.get_burning_particle()
			if new_fire != null:
				new_fire.activate(thing_hit.global_position, thing_hit._burning)
				new_fire.rescale(fire.scale)
				new_fire.set_duration(fire.duration)
				return

	var effect_leave_fire = RunData.get_player_effect("yztato_leave_fire", player_index)
	if !effect_leave_fire.empty():
		for fire in effect_leave_fire:
			var new_fire = _burning_particles_manager.get_burning_particle()
			if new_fire != null:
				new_fire.activate(thing_hit.global_position, thing_hit._burning)
				new_fire.rescale(fire[3])
				new_fire.set_duration(fire[2])

func _yztato_gain_stat_when_killed_scaling_single() -> void:
	kill_count[weapon_id] = kill_count.get(weapon_id, 0) + 1
	for effect_index in effects.size():
		var effect = effects[effect_index]
		effect_single_kill_count[effect_index] = effect_single_kill_count.get(effect_index, kill_count[weapon_id] - 1) + 1
		
		if effect is ProgressData.Yztato.GainStatWhenKilledSingleScaling._Effect and \
		   effect_single_kill_count[effect_index] % int(effect.value + Utils.get_stat(effect.scaling_stat, player_index) * effect.scaling_percent) == 0:
			RunData.add_stat(effect.stat, effect.stat_nb, player_index)

	RunData.emit_signal("stats_updated", player_index)

func _yztato_multi_hit(thing_hit: Node, damage_dealt: int, player_index: int) -> void:
	for effect in effects:
		if effect is ProgressData.Yztato.MultiHit._Effect:
			for _i in range(effect.value):
				var args = TakeDamageArgs.new(player_index)
				thing_hit.take_damage(damage_dealt * effect.damage_percent / 100, args)
				return
	
	var effect_multi_hit = RunData.get_player_effect("yztato_multi_hit", player_index)
	if !effect_multi_hit.empty():
		for effect in effect_multi_hit:
			for _i in range(effect[0]):
				var args = TakeDamageArgs.new(player_index)
				thing_hit.take_damage(damage_dealt * effect[1] / 100, args)

func _yztato_vine_trap(thing_hit: Node, player_index: int) -> void:
	for effect in effects:
		if effect is ProgressData.Yztato.VineTrap._Effect:
			var count = effect.trap_count as int
			var chance = effect.chance as float / 100.0

			if randf() <= chance:
				var vine_trap = effect
				for _i in range(count):
					var pos = _entity_spawner.get_spawn_pos_in_area(thing_hit.global_position, 20)
					var queue = _entity_spawner.queues_to_spawn_structures[player_index]
					queue.push_back([EntityType.STRUCTURE, vine_trap.scene, pos, vine_trap])

			return

	var vine_trap_effects = RunData.get_player_effect("yztato_vine_trap", player_index)
	if !vine_trap_effects.empty():
		for effect_data in vine_trap_effects:
			var count = effect_data[0] as int
			var chance = effect_data[1] as float / 100.0
			
			if randf() <= chance:
				var vine_trap = effect_data[2]
				for _i in range(count):
					var pos = _entity_spawner.get_spawn_pos_in_area(thing_hit.global_position, 20)
					var queue = _entity_spawner.queues_to_spawn_structures[player_index]
					queue.push_back([EntityType.STRUCTURE, vine_trap.scene, pos, vine_trap])

func _yztato_can_attack_while_moving(should_shoot: bool) -> bool:
	if should_shoot: for effect in effects:
		if effect is ProgressData.Yztato.CanAttackWhileMoving._Effect:
			should_shoot = false or _parent._current_movement == Vector2.ZERO

	return should_shoot


# =========================== Method =========================== #
func yz_on_Range_area_entered(area: Area2D)-> void:
	if area.get_parent().name.count("EnemyProjectile"):
		_targets_in_range.push_back(area)

func yz_on_Range_area_exited(area: Area2D)-> void:
	if area.get_parent().name.count("EnemyProjectile"):
		_targets_in_range.erase(area)

func yz_on_Hitbox_area_entered_erase(area: Area2D)-> void:
	if area.get_parent().name.count("EnemyProjectile"):
		var enemy_projectile: Projectile = area.get_parent()
		area.active = false
		area.disable()
		area.ignored_objects.clear()
		yz_delete_projectile(enemy_projectile)

func yz_on_Hitbox_area_entered_bounce(area: Area2D, melee_bounce: int, hitbox: Hitbox)-> void:
	if area.get_parent().name.count("EnemyProjectile"):
		var enemy_projectil: Projectile = area.get_parent()
		enemy_projectil.rotation_degrees += 180
		projectile_shader.set_shader_param("hue", Utils.CHARM_COLOR.h)
		enemy_projectil.set_sprite_material(projectile_shader)
		area.collision_layer = Utils.PLAYER_PROJECTILES_BIT
		area.damage += current_stats.damage/2
		enemy_projectil.velocity *= -(melee_bounce/100)
		area.damage += enemy_projectil.velocity.length_squared()/3000
		
		### counterattack ###
		if hitbox == null: return 
		var attack_id: = hitbox.player_attack_id
		if attack_id < 0: return 
		var attack_hit_count = _hit_count_by_attack_id.get(attack_id, 0)
		attack_hit_count += 1
		_hit_count_by_attack_id[attack_id] = attack_hit_count
		
		ChallengeService.try_complete_challenge("chal_counterattack", attack_hit_count)

# Avoid Assertion failed Caused By Function Stop
func yz_delete_projectile(proj: Projectile)->void :
	proj.hide()
	proj.velocity = Vector2.ZERO
	proj._hitbox.collision_layer = proj._original_collision_layer
	proj._enable_stop_delay = false
	proj._elapsed_delay = 0
	proj._sprite.material = null
	proj._animation_player.stop()
	proj.set_physics_process(false)

	Utils.disconnect_all_signal_connections(proj, "hit_something")
	Utils.disconnect_all_signal_connections(proj._hitbox, "killed_something")

	if is_instance_valid(proj._hitbox.from) and proj._hitbox.from.has_signal("died") and proj._hitbox.from.is_connected("died", proj, "on_entity_died"):
		proj._hitbox.from.disconnect("died", proj, "on_entity_died")
	
	proj.queue_free()

func _yztato_flying_sword_erase(thing_hit: Node, player_index: int) -> void:
	var flying_sword = RunData.get_player_effect("yztato_flying_sword", player_index)
	if flying_sword.size() == 0:
		return

	for flying in flying_sword:
		if (flying[0] == "attack_limit" or flying[0] == "sword_array_limit") and current_stats.damage <= flying[1]:
			return

	_hitbox.ignored_objects.erase(thing_hit)


func yz_on_Hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent().name.count("EnemyProjectile"):
		yz_delete_projectile(area.get_parent())

func _yztato_blade_storm_direction(direction: float) -> float:
	if YZ_is_blade_storm:
		direction = _current_idle_angle
	return direction


func _yztato_blade_storm_target(target: float) -> float:
	if YZ_is_blade_storm:
		target = _current_idle_angle
	return target

func yz_process_attack_mode() -> bool:
	var target = yz_select_target()
	var speed = 0.05
	if idle_angle < 2 * PI:
		idle_angle += speed
	else:
		idle_angle = speed
	
	if target != null:
		if !has_attacked_target:
			yz_move_to_target(target, 10)
			_hitbox.enable()
		else:
			yz_return_to_player(target)
			_hitbox.disable()
	else:
		yz_perform_idle_movement()
		_hitbox.disable()

	return true

func yz_process_sword_array_mode(player_level: int) -> bool:
	if _current_cooldown <= 0:
		var sword_count: int = int(clamp(1 + player_level / 2, 1, 16))
		var targets = _targets_in_range.duplicate()
		targets.shuffle()
		var target_count = targets.size()
		var projectiles_to_spawn: Array = []

		if target_count >= sword_count:
			projectiles_to_spawn = targets.slice(0, sword_count)
		else:
			var index: int = 0
			while projectiles_to_spawn.size() < sword_count:
				if targets.size() > 0:
					projectiles_to_spawn.append(targets[index % targets.size()])
					index += 1
				else:
					break

		for target in projectiles_to_spawn:
			yz_create_sword_projectile(target)

		_current_cooldown = current_stats.cooldown * 2

	yz_perform_idle_movement()
	return true

func yz_meets_condition(mode: Array, current_damage: float) -> bool:
	if mode[0].ends_with("_limit") and current_damage > mode[1]:
		return true
	elif mode[0].ends_with("_limit") and current_damage <= mode[1]:
		return false
	return true

func yz_select_target() -> Node:
	if _current_locked_target != null:
		if is_instance_valid(_current_locked_target) and \
		_targets_in_range.has(_current_locked_target):
			return _current_locked_target
		else:
			_current_locked_target = null

	if _targets_in_range.size() > 0:
		_current_locked_target = _targets_in_range[YZ_rng.randi() % _targets_in_range.size()]
		return _current_locked_target
	
	return null

func yz_select_multiple_targets(count: int) -> Array:
	var targets = _targets_in_range.duplicate()
	targets.shuffle()
	return targets.slice(0, min(count, targets.size()))

func yz_move_to_target(target: Node, speed: float):
	var direction = (target.position - global_position).normalized()
	var new_position = global_position + direction * speed

	if global_position.distance_to(target.position) <= 4  \
	or global_position.distance_to(_parent.position) > current_stats.max_range * 1.5:
		has_attacked_target = true
	
	if new_position != global_position:
		global_position = new_position

func yz_return_to_player(target: Node):
	if global_position.distance_to(target.position) > 4:
		has_attacked_target = false
	
	yz_perform_idle_movement()

func yz_create_sword_projectile(target: Node):
	var project_of_sword_master = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/sword_array/SwordArray.tres")
	var projectile_scene = load("res://mods-unpacked/Yoko-YzTato/content/projectiles/sword_array/SwordArray.tscn")
	var sword_array_stats = project_of_sword_master.duplicate()
	var project_position = target.position - Vector2(
						YZ_rng.randi_range(-200, 200),
						YZ_rng.randi_range(-200, 200)
					)
	var direction_to_target = (target.position - project_position).angle()

	sword_array_stats.damage = current_stats.damage
	sword_array_stats.crit_chance = current_stats.crit_chance
	sword_array_stats.crit_damage = current_stats.crit_damage
	sword_array_stats.lifesteal = current_stats.lifesteal
	sword_array_stats.piercing = 99
	sword_array_stats.max_range = 300
	sword_array_stats.can_bounce = false

	projectile_scene._bundled['variants'][1] = self.sprite.texture
	sword_array_stats.projectile_scene = projectile_scene
	WeaponService.spawn_projectile(
						project_position,
						sword_array_stats,
						direction_to_target,
						self,
						WeaponServiceSpawnProjectileArgs.new()
					)

func yz_perform_idle_movement():
	var weapon_count = max(1, _parent.get_nb_weapons())
	var radius = 100 if weapon_count <= 6 else 100 + (weapon_count - 6) * 10
	var angel_per_weapon = TAU / weapon_count
	var weapon_offset_angle = weapon_pos * angel_per_weapon
	
	var offset_x = cos(idle_angle + weapon_offset_angle) * radius
	var offset_y = sin(idle_angle + weapon_offset_angle) * radius
	
	# The Difference Between PlayerNode And WeaponsNode
	global_position = Vector2(_parent.position.x + offset_x, _parent.position.y + offset_y - 24)
