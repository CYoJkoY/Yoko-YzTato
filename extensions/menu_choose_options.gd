extends "res://ui/menus/pages/menu_choose_options.gd"

signal yztato_set_button_pressed

# =========================== Extention =========================== #
func init()->void :
	$Buttons / GeneralButton.grab_focus()
	_yztato_set_button_init()

# =========================== Custom =========================== #
func _yztato_set_button_init() -> void:
	if $Buttons.has_node("YztatoSetButton"):
		return

	var yztato_set_button = MyMenuButton.new()
	yztato_set_button.name = "YztatoSetButton"
	yztato_set_button.text = "MENU_YZTATO_SET"
	yztato_set_button.margin_right = 600
	yztato_set_button.margin_bottom = 65
	yztato_set_button.rect_size = Vector2(600, 65)
	
	$Buttons.add_child(yztato_set_button)
	var back_button_index = $Buttons / BackButton.get_index()
	$Buttons.move_child(yztato_set_button, back_button_index)

	yztato_set_button.connect("pressed", self, "_on_YztatoSetButton_pressed")
	
func _on_YztatoSetButton_pressed()->void :
	emit_signal("yztato_set_button_pressed")
