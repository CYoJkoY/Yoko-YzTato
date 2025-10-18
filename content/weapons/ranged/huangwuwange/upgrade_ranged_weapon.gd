extends RangedWeapon

# EFFECT : upgrade_range_killed_enemies
var effect_kill_count: Dictionary = {}
var connection_ids = {}

# EFFECT : chimera_weapon_effect
var current_chimera_projs: Array = []
var current_chimera_projs_textures_paths: Array = []
var current_chimera_texture_sets: Array = []

# =========================== Extention =========================== #
func on_projectile_shot(projectile: Node2D) -> void :
	_yztato_upgrade_range_killed_enemies_on_shot(projectile)
	.on_projectile_shot(projectile)

func init_stats(at_wave_begin:bool = true)-> void :
	.init_stats(at_wave_begin)
	_yztato_chimera_init_stats()

# =========================== Custom =========================== #
func _yztato_upgrade_range_killed_enemies_on_shot(projectile: Node2D)-> void:
	if RunData.get_player_effect("yztato_upgrade_range_killed_enemies", player_index) and is_instance_valid(projectile):
		var hitbox = projectile._hitbox
		var conn_id = hitbox.connect("killed_something", self, "_yztato_upgrade_range_killed_enemies", [hitbox])
		connection_ids[projectile] = conn_id

func _yztato_chimera_init_stats()-> void:
	for effect in effects:
		if effect.get_id() != "yztato_chimera_weapon": continue
		
		for proj_stats in effect.chimera_projectile_stats:
			var projectile_instance = proj_stats.projectile_scene.instance()
			var sprite_node = projectile_instance.get_node_or_null("Sprite")
			current_chimera_projs_textures_paths.push_back(sprite_node.texture.resource_path)
			projectile_instance.queue_free()
			current_chimera_projs.push_back(WeaponService.init_ranged_stats(proj_stats, player_index))
		
		for proj_texture_set in effect.chimera_texture_sets:
			current_chimera_texture_sets.append(proj_texture_set)

# =========================== Method =========================== #
func _yztato_upgrade_range_killed_enemies(_thing_killed: Node, _hitbox: Hitbox)-> void:
	var upgrade_attack_killed_enemies: int = RunData.get_player_effect("yztato_upgrade_range_killed_enemies", player_index)
	if upgrade_attack_killed_enemies > 0:
		effect_kill_count[weapon_id] = effect_kill_count.get(weapon_id, 0) + 1
		if effect_kill_count[weapon_id] >= upgrade_attack_killed_enemies:
			effect_kill_count[weapon_id] = -Utils.LARGE_NUMBER
			var old_weapon_data: WeaponData = ItemService.get_element(ItemService.weapons, weapon_id)
			if old_weapon_data and old_weapon_data.upgrades_into and old_weapon_data.upgrades_into.weapon_id:
				var new_weapon_data: WeaponData = ItemService.get_element(ItemService.weapons, old_weapon_data.upgrades_into.weapon_id)
				new_weapon_data.is_cursed = old_weapon_data.is_cursed
				var _re: int = RunData.remove_weapon(old_weapon_data, player_index)
				var _ad: WeaponData = RunData.add_weapon(new_weapon_data, player_index)
