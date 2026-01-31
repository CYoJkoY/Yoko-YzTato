extends "res://singletons/progress_data.gd"

var Yztato: Node = null
var yz_dir: String = ModLoaderMod.get_unpacked_dir() + "Yoko-YzTato/"

# =========================== Extension =========================== #
func _ready() -> void:
    _yztato_ready()

func load_dlc_pcks() -> void:
    .load_dlc_pcks()
    yz_install_extensions()

# =========================== Custom =========================== #
func _yztato_ready() -> void:
    load(yz_dir + "content_data/YzTato_content_New.tres").add_resources()

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
        ModLoaderMod.install_script_extension(yz_dir + "extensions/" + path)
