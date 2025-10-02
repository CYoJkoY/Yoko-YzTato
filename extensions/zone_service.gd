extends "res://singletons/zone_service.gd"

# =========================== Extention =========================== #
func get_wave_data(my_id:int, index:int)->Resource:
	var wave = .get_wave_data(my_id, index)
	wave = _yztato_adjust_wave_timer(wave)
	wave = _yztato_adjust_wave_max_enemies(wave)

	return wave

# =========================== Custom =========================== #
func _yztato_adjust_wave_timer(wave: Resource)-> Resource :
	for player_index in RunData.players_data.size():
		var adjust_timer = RunData.get_player_effect("yztato_adjust_wave_timer",player_index)
		if adjust_timer.size() > 0 :
			for adjust in adjust_timer:
				if adjust[0] == "sum":
					wave.wave_duration += adjust[1]
				elif adjust[0] == "mul":
					wave.wave_duration *= adjust[1]/100
				elif adjust[0] == "rep":
					wave.wave_duration = adjust[1]
				elif adjust[0] == "mul_plus":
					var add_time = wave.wave_duration * adjust[1]/100
					wave.wave_duration += add_time
	return wave

func _yztato_adjust_wave_max_enemies(wave: Resource)-> Resource :
	for player_index in RunData.players_data.size():
		var adjust_enemies = RunData.get_player_effect("yztato_adjust_wave_max_enemies",player_index)
		if adjust_enemies.size() > 0 :
			for adjust in adjust_enemies:
				if adjust[0] == "sum":
					wave.max_enemies += adjust[1]
				elif adjust[0] == "mul":
					wave.max_enemies *= adjust[1]/100
				elif adjust[0] == "rep":
					wave.max_enemies = adjust[1]
				elif adjust[0] == "mul_plus":
					var add_enemies_number = wave.max_enemies * adjust[1]/100
					wave.max_enemies += add_enemies_number
	return wave
