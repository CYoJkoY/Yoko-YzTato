extends "res://ui/menus/title_screen/title_screen_menus.gd"

# =========================== Extention =========================== #
func _ready():
	_yztato_set_options()

# =========================== Custom =========================== #
func _yztato_set_options() -> void:
	var _yztato_set_options = load("res://mods-unpacked/Yoko-YzTato/content/scenes/set_scene.tscn").instance()
	add_child(_yztato_set_options)
	_yztato_set_options.name = "MenuYztatoSetOptions"
	_yztato_set_options.visible = false

	_yztato_set_options.connect("back_button_pressed", self, "on_options_yztato_set_back_button_pressed", [_yztato_set_options])
	_main_menu.connect("yztato_set_button_pressed", self, "on_options_yztato_set_button_pressed", [_yztato_set_options])

func on_options_yztato_set_back_button_pressed(_yztato_set_options) -> void:
	switch(_yztato_set_options, _main_menu)

func on_options_yztato_set_button_pressed(_yztato_set_options) -> void:
	switch(_main_menu, _yztato_set_options)
