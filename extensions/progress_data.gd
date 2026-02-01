extends "res://singletons/progress_data.gd"

var yz_dir: String = ModLoaderMod.get_unpacked_dir() + "Yoko-YzTato/"

# =========================== Extension =========================== #
func load_dlc_pcks() -> void:
    .load_dlc_pcks()
    yz_install_extensions()

# =========================== Custom =========================== #
func yz_install_extensions() -> void:
    var extensions: Array = [
        
        "dlc_1_data.gd",
        # Curse My Effects
        
    ]
    
    for path in extensions:
        ModLoaderMod.install_script_extension(yz_dir + "extensions/" + path)
