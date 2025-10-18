extends BaseSelection

var _player_items: = []
var _player_items_max_count: int = ProgressData.settings.yztato_starting_items_times

onready var _back_button: Button = $"%BackButton"
onready var _character_panel: ItemPanelUI = $"%CharacterPanelUI"

func _ready()->void :
	_player_items.resize(RunData.get_player_count())
	for player_index in RunData.get_player_count():
		_player_items[player_index] = []

	var player_index_0: int = 0
	_character_panel.set_data(RunData.players_data[player_index_0].current_character, player_index_0)
	_character_panel.visible = not RunData.is_coop_run

	var inventories = _get_inventories()

	var base_columns = inventories[0].columns

	if RunData.get_player_count() > 1:
		base_columns = 16
	
	var columns = int(base_columns / RunData.get_player_count())

	for inventory in inventories:
		inventory.columns = columns
		inventory.queue_set_focus_neighbours()

	for margin in [MARGIN_LEFT, MARGIN_TOP]:
		_back_button.set_focus_neighbour(margin, _back_button.get_path_to(_back_button))

	_background.texture = ZoneService.get_zone_data(RunData.current_zone).ui_background
	

func _on_BackButton_pressed():
	_manage_back()


func _input(event:InputEvent)->void :
	if not RunData.is_coop_run:
		return 
	
	for player_index in RunData.get_player_count():
		var panel = _get_panels()[player_index]
		if Utils.is_player_action_pressed(event, player_index, CoopShowCharacterHint.UI_ACTION):
			
			panel.set_data(RunData.get_player_character(player_index), player_index)
			panel.selected = false
		elif Utils.is_player_action_released(event, player_index, CoopShowCharacterHint.UI_ACTION) and _displayed_panel_data_element[player_index] != null:
			
			_display_element_panel_data(_displayed_panel_data_element[player_index], player_index)
			panel.selected = _has_player_selected[player_index]


func _get_unlocked_elements(_player_index:int)->Array:
	return ProgressData.items_unlocked


func _go_back()->void :
	for player_index in RunData.get_player_count():
		Utils.last_elt_selected[player_index] = RunData.get_player_character(player_index)
	RunData.revert_all_selections()
	_change_scene(MenuData.character_selection_scene)


func _get_all_possible_elements(_player_index:int)->Array:
	var items = []
	for item in ItemService.items:
		if not item.is_locked: items.append(item)
	return items

func _get_reward_type()->int:
	return RewardType.CHARACTER


func _on_element_pressed(element:InventoryElement, inventory_player_index:int)->void :
	if element.is_random:
		var available_elements: = []
		for element in displayed_elements[inventory_player_index]:
			if not element.is_locked:
				available_elements.push_back(element)
		var item = Utils.get_rand_element(available_elements)
		_player_items[inventory_player_index].append(item)
		_add_number_to_item(element)
	elif element.is_special:
		return
	else :
		_player_items[inventory_player_index].append(element.item)
		_add_number_to_item(element)

	if _player_items[inventory_player_index].size() >= _player_items_max_count:
		_set_selected_element(inventory_player_index)


func _add_number_to_item(element:InventoryElement)->void:
	if element.current_number == 1:
		if element._number_label.text == '':
			element._number_label.text = "x" + str(element.current_number)
			element._number_label.show()
		else:
			element.add_to_number()
	else:
		element.add_to_number()


func _on_selections_completed()->void :
	for player_index in _player_items.size():
		var items = _player_items[player_index]
		
		for item in items:
			if item != null:
				RunData.add_item(item, player_index)

		if RunData.some_player_has_weapon_slots():
			_change_scene(MenuData.weapon_selection_scene)
		else :
			_change_scene(MenuData.difficulty_selection_scene)


func _on_element_focused(element:InventoryElement, inventory_player_index:int, displayPanelData: bool = true)->void :
	._on_element_focused(element, inventory_player_index, displayPanelData)

	var player_index = FocusEmulatorSignal.get_player_index(element)
	if player_index >= 0:
		if _player_items[player_index].size() < _player_items_max_count:
			_clear_selected_element(player_index)


func _is_locked_elements_displayed()->bool:
	return false


func _get_inventories()->Array:
	
	var inventory_containers: = _get_inventory_containers()
	var inventories: = []
	for container in inventory_containers:
		inventories.push_back(container.inventory)
	return inventories
