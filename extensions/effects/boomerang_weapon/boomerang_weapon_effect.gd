extends NullEffect

export (float) var return_speed = 1.0
export (bool) var boomerang_wait = true

export (float) var min_range = 1.0
export (float) var max_damage_mul = 1.0
export (float) var min_damage_mul = 1.0
export (bool) var lock_range = false
export (bool) var lock_speed = false
export (bool) var knockback_only_back = true

# =========================== Extension =========================== #
static func get_id() -> String:
	return "yztato_boomerang_weapon"

func get_args(_player_index: int) -> Array:
	var boomerang_wait_arg: String = "YZTATO_BOOMERANG_WAIT" if boomerang_wait else "YZTATO_BOOMERANG_WAIT_NO"
	var lock_range_arg: String = "YZTATO_LOCK_RANGE" if lock_range else "YZTATO_LOCK_RANGE_NO"
	var knockback_only_back_arg: String = "YZTATO_KNOCKBACK_ONLY_BACK" if knockback_only_back else "[EMPTY]"
	var max_damage_mul_arg: String = "[color=#"+ ProgressData.settings.color_positive +"]" + str(max_damage_mul * 100) + "%[/color]"
	var min_damage_mul_arg: String = "[color=#"+ ProgressData.settings.color_negative +"]" + str(min_damage_mul * 100) + "%[/color]"
	
	return [tr(boomerang_wait_arg), tr(lock_range_arg),tr(knockback_only_back_arg),
	str(max_damage_mul_arg), str(min_damage_mul_arg)]

func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized = yztato_serialize_boomerang(serialized)
	return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	yztato_deserialize_boomerang(serialized)

# =========================== Custom =========================== #
func yztato_serialize_boomerang(serialized) -> Dictionary:
	serialized.return_speed = return_speed
	serialized.boomerang_wait = boomerang_wait
	return serialized

func yztato_deserialize_boomerang(serialized) -> void:
		return_speed = serialized.return_speed as float
		boomerang_wait = serialized.boomerang_wait as bool
