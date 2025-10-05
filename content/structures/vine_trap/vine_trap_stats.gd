extends RangedWeaponStats

export(String) var tracking_key = ""

# =========================== Extension =========================== #
func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized.tracking_key = tracking_key
	
	return serialized
	
func deserialize_and_merge(serialized: Dictionary):
	.deserialize_and_merge(serialized)
	tracking_key = serialized.tracking_key as String
