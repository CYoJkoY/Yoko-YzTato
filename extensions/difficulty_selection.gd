extends "res://ui/menus/run/difficulty_selection/difficulty_selection.gd"

# =========================== Extention =========================== #
func _get_unlocked_elements(_player_index: int)->Array:
	var unlocked_difficulties = ._get_unlocked_elements(_player_index)
	unlocked_difficulties = _yztato_unlock_difficulties(unlocked_difficulties)

	return unlocked_difficulties

# =========================== Custom =========================== #
func _yztato_unlock_difficulties(unlocked_difficulties: Array) -> Array:
	if ProgressData.settings.yztato_unlock_difficulties:
		for player_data in RunData.players_data:
			# Unlock all difficulties
			for character in ItemService.characters:
				var character_difficulty_info_exists = false
				var existing_char_diff_info: CharacterDifficultyInfo = null
				
				# Check if exists
				for difficulty_unlocked in ProgressData.difficulties_unlocked:
					if difficulty_unlocked.character_id == character.my_id:
						character_difficulty_info_exists = true
						existing_char_diff_info = difficulty_unlocked
						break
				
				# If not exists
				if not character_difficulty_info_exists:
					var char_diff_info = CharacterDifficultyInfo.new(character.my_id)
					ProgressData.difficulties_unlocked.push_back(char_diff_info)
					existing_char_diff_info = char_diff_info
				
				# Max difficulty
				for zone in ZoneService.zones:
					var zone_difficulty_info_exists = false
					var existing_zone_diff_info: ZoneDifficultyInfo = null
					
					# Check if exists
					for zone_diff_info in existing_char_diff_info.zones_difficulty_info:
						if zone_diff_info.zone_id == zone.my_id:
							zone_difficulty_info_exists = true
							existing_zone_diff_info = zone_diff_info
							break
					
					# If not exists
					if not zone_difficulty_info_exists:
						var zone_diff_info = ZoneDifficultyInfo.new(zone.my_id)
						zone_diff_info.max_selectable_difficulty = ProgressData.MAX_DIFFICULTY
						existing_char_diff_info.zones_difficulty_info.push_back(zone_diff_info)
					else: existing_zone_diff_info.max_selectable_difficulty = ProgressData.MAX_DIFFICULTY
				
				# Add all difficulties
				for diff in ItemService.difficulties:
					if not unlocked_difficulties.has(diff.my_id):
						unlocked_difficulties.push_back(diff.my_id)
		
		# Save
		ProgressData.save()
	
	return unlocked_difficulties