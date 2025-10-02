extends "res://singletons/sound_manager.gd"


func play(sound:Resource, volume_mod:float = 0.0, pitch_rand:float = 0.0, always_play:bool = false)->void :
	if not sound:
		return
	if always_play :
		sounds_to_play.push_front([sound, volume_mod, pitch_rand])
	else:
		.play(sound, volume_mod, pitch_rand, always_play)
