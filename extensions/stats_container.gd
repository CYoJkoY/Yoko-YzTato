extends "res://ui/menus/shop/stats_container.gd"

onready var _VBoxContainer2 = $MarginContainer / VBoxContainer2
var tertiary_stats_keys: Array = []
var _tertiary_stats = SecondaryStatsContainer.new()
var _tertiary_tab = MyMenuButton.new()

var tertiary_stats: Array = []

# =========================== Extention =========================== #
func _ready()->void :
	_yztato_tertiary_stat_ready()

func set_focus_neighbours()->void :
	_yztato_set_focus_neighbours()

func _reset_focus_neighbours()->void :
	_yztato_reset_focus_neighbours()

func update_tab(tab: int)->void :
	_yztato_update_tab(tab)

func _input(event: InputEvent)->void :
	_yztato_input(event)

func update_player_stats(player_index: int)->void :
	_yztato_update_player_stats(player_index)

# =========================== Custom =========================== #
func _yztato_tertiary_stat_ready() -> void:
	# Create TertiaryStats VBoxContainer
	_tertiary_stats.name = "TertiaryStats"
	_VBoxContainer2.add_child(_tertiary_stats)
	for stat in ItemService.stats:
		if stat.get("is_tertiary_stat") != null:
			if stat.is_tertiary_stat:
				tertiary_stats_keys.append(stat.stat_name.to_upper())
				var teriary_stat = _secondary_stats.get_child(0).duplicate()
				teriary_stat.key = stat.stat_name.to_upper()
				teriary_stat.reverse = stat.reverse
				_tertiary_stats.add_child(teriary_stat)
				teriary_stat.disable_focus()
	
	tertiary_stats = _tertiary_stats.get_children()
	
	# Remove Tertiary Stat From Primary
	for primary in primary_stats:
		if primary.key in tertiary_stats_keys:
			_primary_stats.remove_child(primary)
	
	# Remove Tertiary Stat From Secondary
	for secondary in secondary_stats:
		if secondary.key in tertiary_stats_keys:
			_secondary_stats.remove_child(secondary)

	_tertiary_tab.name = "Tertiary"
	_tertiary_tab.text = "TERTIARY"
	_tertiary_tab.clip_text = true
	_tertiary_tab.add_font_override("font", load("res://resources/fonts/actual/base/font_26.tres"))
	
	_primary_tab.rect_min_size.x = 110
	_secondary_tab.rect_min_size.x = 110
	_tertiary_tab.rect_min_size.x = 110
	
	_tertiary_tab.connect("pressed", self, "_on_Tertiary_pressed")
	
	_buttons_container.add_child(_tertiary_tab)

# Override
func _yztato_update_tab(tab: int) -> void:
	focused_tab = tab

	if tab == Tab.PRIMARY:
		_set_flat(_primary_tab, true)
		_set_flat(_secondary_tab, false)
		_set_flat(_tertiary_tab, false)
		_general_stats.show()
		_primary_stats.show()
		_secondary_stats.hide()
		_tertiary_stats.hide()

	elif tab == Tab.SECONDARY:
		_set_flat(_primary_tab, false)
		_set_flat(_secondary_tab, true)
		_set_flat(_tertiary_tab, false)
		_secondary_stats.show()
		_general_stats.hide()
		_primary_stats.hide()
		_tertiary_stats.hide()
	
	else:
		_set_flat(_primary_tab, false)
		_set_flat(_secondary_tab, false)
		_set_flat(_tertiary_tab, true)
		_tertiary_stats.show()
		_general_stats.hide()
		_primary_stats.hide()
		_secondary_stats.hide()

	set_focus_neighbours()

# Override
func _yztato_set_focus_neighbours() -> void:
	# Ensure _tertiary_tab is added to the scene tree
	if not _buttons_container.has_node(_tertiary_tab.name):
		return

	if focus_neighbour_top:
		var top_node = get_node(focus_neighbour_top) if has_node(focus_neighbour_top) else null
		if show_buttons:
			_primary_tab.focus_neighbour_top = _primary_tab.get_path_to(top_node) if top_node else NodePath("")
			_secondary_tab.focus_neighbour_top = _secondary_tab.get_path_to(top_node) if top_node else NodePath("")
			_tertiary_tab.focus_neighbour_top = _tertiary_tab.get_path_to(top_node) if top_node else NodePath("")
		else:
			first_primary_stat.focus_neighbour_top = first_primary_stat.get_path_to(top_node) if top_node else NodePath("")
	if focus_neighbour_bottom:
		var bottom_node = get_node(focus_neighbour_bottom) if has_node(focus_neighbour_bottom) else null
		last_primary_stat.focus_neighbour_bottom = last_primary_stat.get_path_to(bottom_node) if bottom_node else NodePath("")
	if focus_neighbour_left:
		var left_node = get_node(focus_neighbour_left) if has_node(focus_neighbour_left) else null
		_primary_tab.focus_neighbour_left = _primary_tab.get_path_to(left_node) if left_node else NodePath("")
		_secondary_tab.focus_neighbour_left = _secondary_tab.get_path_to(_primary_tab)
		_tertiary_tab.focus_neighbour_left = _tertiary_tab.get_path_to(_secondary_tab)
	if focus_neighbour_right:
		var right_node = get_node(focus_neighbour_right) if has_node(focus_neighbour_right) else null
		_primary_tab.focus_neighbour_right = _primary_tab.get_path_to(_secondary_tab)
		_secondary_tab.focus_neighbour_right = _secondary_tab.get_path_to(_tertiary_tab)
		_tertiary_tab.focus_neighbour_right = _tertiary_tab.get_path_to(right_node) if right_node else NodePath("")

# Override
func _yztato_reset_focus_neighbours() -> void:
	for margin in [MARGIN_TOP, MARGIN_BOTTOM, MARGIN_LEFT, MARGIN_RIGHT]:
		if margin == MARGIN_TOP and focus_neighbour_top != NodePath(""):
			continue
		_primary_tab.set_focus_neighbour(margin, NodePath(""))
		_secondary_tab.set_focus_neighbour(margin, NodePath(""))
		_tertiary_tab.set_focus_neighbour(margin, NodePath(""))
	for stat in primary_stats:
		stat.focus_neighbour_top = NodePath("")
		stat.focus_neighbour_bottom = NodePath("")
		stat.focus_neighbour_left = NodePath("")
		stat.focus_neighbour_right = NodePath("")

# Override
func _yztato_input(event: InputEvent)->void :
	if event is InputEventJoypadButton and show_buttons:
		if event.is_action_pressed("ltrigger"):
			if focused_tab == Tab.PRIMARY:
				update_tab(2)
			elif focused_tab == Tab.SECONDARY:
				update_tab(Tab.PRIMARY)
			else:
				update_tab(Tab.SECONDARY)

		elif event.is_action_pressed("rtrigger"):
			if focused_tab == Tab.PRIMARY:
				update_tab(Tab.SECONDARY)
			elif focused_tab == Tab.SECONDARY:
				update_tab(2)
			else:
				update_tab(Tab.PRIMARY)

# Override
func _yztato_update_player_stats(player_index: int)->void :
	var update_stats
	if show_buttons:
		update_stats = primary_stats + secondary_stats + tertiary_stats
	elif focused_tab == Tab.PRIMARY:
		update_stats = primary_stats
	elif focused_tab == Tab.SECONDARY:
		update_stats = secondary_stats
	else:
		update_stats = tertiary_stats

	var level_container = general_stats[0]
	level_container.player_index = player_index
	level_container.update_info(player_index)
	for stat in update_stats:
		stat.update_player_stat(player_index)

# =========================== Method =========================== #
# Signals
func _on_Tertiary_pressed() -> void:
	update_tab(2)
