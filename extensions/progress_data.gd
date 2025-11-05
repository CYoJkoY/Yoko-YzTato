extends "res://singletons/progress_data.gd"

var yztato_data
var Yztato = null

const MYMODNAME_MOD_DIR: String = "Yoko-YzTato/"
var dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
var ext_dir: String = dir + "extensions/"

# =========================== Extention =========================== #
func _ready() -> void:
	_yztato_ready()

func load_dlc_pcks()->void :
	.load_dlc_pcks()
	install_extensions()

# =========================== Custom =========================== #
func _yztato_ready() -> void:
	yztato_data = load("res://mods-unpacked/Yoko-YzTato/content_data/YzTato_content_New.tres")
	yztato_data.add_resources()

	RunData.reset()

	load_game_file()
	add_unlocked_by_default()

	set_max_selectable_difficulty()

	Yztato = get_node("/root/ModLoader/Yoko-YzTato/Yztato")

func install_extensions() -> void:
	var extensions: Array = [
		
		"dlc_1_data.gd",
		# Curse My Effects
		
	]
	
	for path in extensions:
		ModLoaderMod.install_script_extension(ext_dir + path)
