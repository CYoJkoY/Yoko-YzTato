extends RangedWeaponStats

# =========================== Extension =========================== #
func serialize() -> Dictionary:
	var serialized =.serialize()
	serialized.speed_percent_modifier = speed_percent_modifier
	
	return serialized
	
func deserialize_and_merge(serialized: Dictionary):
	.deserialize_and_merge(serialized)
	speed_percent_modifier = serialized.speed_percent_modifier as int
