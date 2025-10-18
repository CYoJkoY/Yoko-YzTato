extends "res://ui/menus/pages/main_menu.gd"

signal yztato_set_button_pressed

onready var buttons_right = $MarginContainer/VBoxContainer/HBoxContainer/ButtonsRight

# =========================== Extention =========================== #
func _ready()->void :
	# After init and avoid .init()
	# Equals to init() + .init()
	_yztato_set_button_ready()

# =========================== Custom =========================== #
func _yztato_set_button_ready() -> void:
	if buttons_right.has_node("YztatoSetButton"):
		return

	var yztato_set_button = MyMenuButton.new()
	yztato_set_button.name = "YztatoSetButton"
	yztato_set_button.text = "MENU_YZTATO_SET"
	yztato_set_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	
	buttons_right.add_child(yztato_set_button)
	var mods_button_index: int = mods_button.get_index()
	buttons_right.move_child(yztato_set_button, mods_button_index)

	yztato_set_button.connect("pressed", self, "_on_YztatoSetButton_pressed")
	
	yztato_set_button.focus_neighbour_left = start_button.get_path()
	yztato_set_button.focus_neighbour_right = start_button.get_path()
	yztato_set_button.focus_neighbour_top = credits_button.get_path()
	mods_button.focus_neighbour_top = yztato_set_button.get_path()

func _on_YztatoSetButton_pressed()->void :
	emit_signal("yztato_set_button_pressed")
