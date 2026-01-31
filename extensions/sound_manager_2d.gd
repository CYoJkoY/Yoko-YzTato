extends "res://singletons/sound_manager_2d.gd"


func play(sound: Resource, pos: Vector2, volume_mod: float = 0.0, pitch_rand: float = 0.0, always_play: bool = false) -> void:
    if !sound:
        return
    if always_play:
        sounds_to_play.push_front([sound, volume_mod, pitch_rand, pos])
    else:
        .play(sound, pos, volume_mod, pitch_rand, always_play)
