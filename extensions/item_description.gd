extends "res://ui/menus/shop/item_description.gd"

onready var _curse_strength_label: Label

# =========================== Extention =========================== #
func set_item(item_data: ItemParentData, player_index: int, item_count: int = 1)->void :
	.set_item(item_data, player_index, item_count)
	_update_curse_strength_display(item_data)

# =========================== Custom =========================== #
func _update_curse_strength_display(item_data: ItemParentData) -> void:
	
	if !ProgressData.settings.yztato_curse_strength: return
	
	_create_curse_strength_label()
	
	if item_data.is_cursed:
		_curse_strength_label.visible = true
		
		var curse_strength_text = ""
		curse_strength_text = tr("YZCURSESTRENGTH").format([str(item_data.curse_factor * 100)])
		_curse_strength_label.text = curse_strength_text
		_curse_strength_label.add_color_override("font_color", Utils.CURSE_COLOR)
	
	else:
		_curse_strength_label.visible = false

func _create_curse_strength_label() -> void:
	if is_instance_valid(_curse_strength_label): return
	
	_curse_strength_label = Label.new()
	_curse_strength_label.name = "CurseStrengthLabel"
	_curse_strength_label.visible = false
	_curse_strength_label.align = Label.ALIGN_LEFT

	var small_font = preload("res://resources/fonts/actual/base/font_smallest_text.tres")
	_curse_strength_label.set("custom_fonts/font", small_font)
	
	var VContainer: VBoxContainer = get_node_or_null("HBoxContainer/ScrollContainer/VBoxContainer") as VBoxContainer
	# ↓↓↓ codex_item_description ↓↓↓ #
	if !VContainer or !is_instance_valid(VContainer): VContainer = get_node_or_null("HBoxContainer/VBoxContainer")
	VContainer.add_child(_curse_strength_label)
	
	_curse_strength_label.owner = self
