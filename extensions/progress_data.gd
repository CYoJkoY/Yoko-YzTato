extends "res://singletons/progress_data.gd"

var yztato_data
var Yztato = null

const YZMODNAME_MOD_DIR: String = "Yoko-YzTato/"
var yz_dir = ModLoaderMod.get_unpacked_dir() + YZMODNAME_MOD_DIR
var yz_ext_dir: String = yz_dir + "extensions/"

# =========================== Extention =========================== #
func _ready() -> void:
    _yztato_ready()

func load_dlc_pcks()->void :
    .load_dlc_pcks()
    yz_install_extensions()

# =========================== Custom =========================== #
func _yztato_ready() -> void:
    yztato_data = load("res://mods-unpacked/Yoko-YzTato/content_data/YzTato_content_New.tres")
    yztato_data.add_resources()

    RunData.reset()

    load_game_file()
    add_unlocked_by_default()

    set_max_selectable_difficulty()

    Yztato = get_node("/root/ModLoader/Yoko-YzTato/Yztato")

func yz_install_extensions() -> void:
    var extensions: Array = [
        
        "dlc_1_data.gd",
        # Curse My Effects
        
    ]
    
    for path in extensions:
        ModLoaderMod.install_script_extension(yz_ext_dir + path)
