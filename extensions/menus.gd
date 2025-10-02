extends "res://ui/menus/menus.gd"

# =========================== Extention =========================== #
func _ready():
	_yztato_set_options()

# =========================== Custom =========================== #
func _yztato_set_options() -> void:
	var _yztato_set_options = load("res://mods-unpacked/Yoko-YzTato/content/scenes/set_scene.tscn").instance()
	add_child(_yztato_set_options)
	_yztato_set_options.name = "MenuYztatoSetOptions"
	_yztato_set_options.visible = false

	var _error_back_gameplay_options = _yztato_set_options.connect("back_button_pressed", self, "on_options_yztato_set_back_button_pressed", [_yztato_set_options])
	var _error_yztato_set_options = _menu_choose_options.connect("yztato_set_button_pressed", self, "on_options_yztato_set_button_pressed", [_yztato_set_options])

func on_options_yztato_set_back_button_pressed(_yztato_set_options) -> void:
	switch(_yztato_set_options, _menu_choose_options)

func on_options_yztato_set_button_pressed(_yztato_set_options) -> void:
	switch(_menu_choose_options, _yztato_set_options)
