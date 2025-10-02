extends "res://ui/menus/shop/secondary_stat_container.gd"

onready var _icon:TextureRect = TextureRect.new()
onready var _HBoxContainer = $HBoxContainer

# =========================== Extention =========================== #
func _ready() -> void:
	_icon.expand = true
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_icon.rect_min_size = Vector2(30, 30)
	_HBoxContainer.add_child(_icon)
	_HBoxContainer.move_child(_icon, 0)

func update_player_stat(player_index: int)->void :
	_icon.texture = ItemService.get_stat_small_icon(key.to_lower())
	.update_player_stat(player_index)
