extends Effect

export(Resource) var weapon_stats
export(bool) var auto_target_enemy = false
export(String) var tracking_key = ""
var tracking_key_hash: int = Keys.empty_hash

# =========================== Extension =========================== #
func duplicate(subresources:=false) -> Resource:
	var duplication =.duplicate(subresources)

	duplication.tracking_key_hash = tracking_key_hash

	return duplication

static func get_id() -> String:
	return "yztato_projectiles_on_hurt"

func _generate_hashes() -> void:
	._generate_hashes()
	tracking_key_hash = Keys.generate_hash(tracking_key)

func apply(player_index: int) -> void:
	if custom_key_hash == Keys.empty_hash: return

	var effects: Array = RunData.get_player_effect(custom_key_hash, player_index)
	var found: bool = false

	for projectile in effects:
		if projectile[0] != key_hash or projectile[4] != tracking_key_hash: continue

		var existing_proj_count: int = projectile[1]
		var total_proj_count: int = existing_proj_count + value
		projectile[1] = total_proj_count
		projectile[2].scaling_stats = _merge_scaling_stats(existing_proj_count, projectile[2].scaling_stats)
		found = true
		break

	if !found: effects.append([key_hash, value, weapon_stats.duplicate(), auto_target_enemy, tracking_key_hash])

func unapply(player_index: int) -> void:
	if custom_key_hash == Keys.empty_hash: return

	var effects: Array = RunData.get_player_effect(custom_key_hash, player_index)

	for projectile in effects:
		var existing_proj_count: int = projectile[1]
		var total_proj_count: int = existing_proj_count - value

		if total_proj_count <= 0:
			effects.erase(projectile)
			return

		projectile[1] = total_proj_count
		projectile[2].scaling_stats = _merge_scaling_stats(existing_proj_count, projectile[2].scaling_stats, true)

func _merge_scaling_stats(existing_proj_count: int, existing_scaling: Array, subtract:=false) -> Array:
	var duplicated_scaling: Array = existing_scaling.duplicate(true)
	if weapon_stats == null: return duplicated_scaling

	for scaling_stat in weapon_stats.scaling_stats:
		var found: bool = false
		var symbol: int = -1 if subtract else 1

		for existing_scaling_stat in duplicated_scaling:
			if scaling_stat[0] != existing_scaling_stat[0]: continue

			found = true
			var divisor: int = existing_proj_count + (symbol * value)
			if divisor == 0: existing_scaling_stat[1] = 0.0
			else:
				var original_scaling_value: float = existing_scaling_stat[1] * existing_proj_count
				var delta_scaling_value: float = symbol * scaling_stat[1] * value
				existing_scaling_stat[1] = (original_scaling_value + delta_scaling_value) / divisor

			break

		if !found and !subtract: duplicated_scaling.append(scaling_stat)

	return duplicated_scaling

func get_args(player_index: int) -> Array:
	var current_stats = WeaponService.init_ranged_stats(weapon_stats, player_index, true)
	var scaling_text = WeaponService.get_scaling_stats_icon_text(weapon_stats.scaling_stats)

	return [str(value), str(current_stats.damage), str(current_stats.bounce + 1), scaling_text, tr(key.to_upper())]

func serialize() -> Dictionary:
	var serialized =.serialize()

	if weapon_stats != null:
		serialized.weapon_stats = weapon_stats.serialize()

	serialized.auto_target_enemy = auto_target_enemy

	return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	if serialized.has("weapon_stats"):
		var data = RangedWeaponStats.new()
		data.deserialize_and_merge(serialized.weapon_stats)
		weapon_stats = data

	auto_target_enemy = serialized.auto_target_enemy
