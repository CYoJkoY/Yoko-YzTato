extends "res://singletons/progress_data.gd"

var Yztato = null

# =========================== Extention =========================== #
func _ready() -> void:
	_yztato_ready()

# =========================== Custom =========================== #
func _yztato_ready() -> void:
	var yztato_data = load("res://mods-unpacked/Yoko-YzTato/content_data/YzTato_content_New.tres")
	yztato_data.add_resources()

	RunData.reset()

	load_game_file()
	add_unlocked_by_default()

	set_max_selectable_difficulty()

	Yztato = get_node("/root/ModLoader/Yoko-YzTato/Yztato")
