extends Control

signal back_button_pressed

onready var focus_before_created: Control = get_focus_owner()

onready var UnlockDifficulties = $"%UnlockDifficulties" as CheckButton
onready var UnlockAllChars = $"%UnlockAllChars" as CheckButton
onready var UnlockAllChallenges = $"%UnlockAllChallenges" as CheckButton
onready var OptimizePickUp = $"%OptimizePickUp" as CheckButton
onready var StartingWeapons = $"%StartingWeapons" as CheckButton

onready var StartingItems = $"%StartingItems" as CheckButton
onready var SetStartingItemsTimes = $"%SetStartingItemsTimes" as HBoxContainer

onready var CurseStrength = $"%CurseStrength" as CheckButton

onready var RainbowGold = $"%RainbowGold" as OptionButton
var colors_names: Array = [

	"YZ_EMPTY", "YZ_EXLIGHT", "YZ_LIGHT", 
	"YZ_MEDIUM", "YZ_DARK", "YZ_EXDARK"
	
]

onready var SetWeaponTransparency = $"%SetWeaponTransparency" as HBoxContainer
onready var SetEnemyTransparency = $"%SetEnemyTransparency" as HBoxContainer
onready var SetEnemyProjTransparency = $"%SetEnemyProjTransparency" as HBoxContainer
onready var SetGoldTransparency = $"%SetGoldTransparency" as HBoxContainer
onready var SetConsumableTransparency = $"%SetConsumableTransparency" as HBoxContainer

# =========================== Init =========================== #
func _input(event):
	if self.visible and event.is_action_pressed("ui_cancel"):
		_on_BackButton_pressed()
		get_tree().set_input_as_handled()

func init()->void :
	focus_before_created = get_focus_owner()

	$BackButton.grab_focus()

	init_values_from_progress_data()

func init_values_from_progress_data() -> void:
	UnlockDifficulties.pressed = ProgressData.settings.yztato_unlock_difficulties
	UnlockAllChars.pressed = ProgressData.settings.yztato_unlock_all_chars
	UnlockAllChallenges.pressed = ProgressData.settings.yztato_unlock_all_challenges
	OptimizePickUp.pressed = ProgressData.settings.yztato_optimize_pickup
	StartingWeapons.pressed = ProgressData.settings.yztato_starting_weapons
	
	StartingItems.pressed = ProgressData.settings.yztato_starting_items
	SetStartingItemsTimes.set_value(ProgressData.settings.yztato_starting_items_times)
	
	CurseStrength.pressed = ProgressData.settings.yztato_curse_strength
	
	RainbowGold.select(colors_names.find(ProgressData.settings.yztato_rainbow_gold))

	SetWeaponTransparency.set_value(ProgressData.settings.yztato_set_weapon_transparency)
	SetEnemyTransparency.set_value(ProgressData.settings.yztato_set_enemy_transparency)
	SetEnemyProjTransparency.set_value(ProgressData.settings.yztato_set_enemy_proj_transparency)
	SetGoldTransparency.set_value(ProgressData.settings.yztato_set_gold_transparency)
	SetConsumableTransparency.set_value(ProgressData.settings.yztato_set_consumable_transparency)

# =========================== Save =========================== #
func _on_BackButton_pressed():
	if focus_before_created != null and focus_before_created.is_inside_tree():
		focus_before_created.grab_focus()
	emit_signal("back_button_pressed")

func _on_MenuYztatoSetOptions_hide():
	ProgressData.save_settings()

# =========================== Load =========================== #
func _on_UnlockDifficulties_toggled(button_pressed: bool):
	ProgressData.settings.yztato_unlock_difficulties = button_pressed
func _on_UnlockAllChars_toggled(button_pressed: bool):
	ProgressData.settings.yztato_unlock_all_chars = button_pressed
func _on_UnlockAllChallenges_toggled(button_pressed: bool):
	ProgressData.settings.yztato_unlock_all_challenges = button_pressed
func _on_OptimizePickUp_toggled(button_pressed: bool):
	ProgressData.settings.yztato_optimize_pickup = button_pressed
func _on_StartingWeapons_toggled(button_pressed: bool) -> void:
	ProgressData.settings.yztato_starting_weapons = button_pressed

func _on_StartingItems_toggled(button_pressed: bool) -> void:
	ProgressData.settings.yztato_starting_items = button_pressed
func _on_SetStartingItemsTimes_value_changed(value) -> void:
	ProgressData.settings.yztato_starting_items_times = value

func _on_CurseStrength_toggled(button_pressed: bool) -> void:
	ProgressData.settings.yztato_curse_strength = button_pressed

func _on_RainbowGold_item_selected(index: int):
	ProgressData.settings.yztato_rainbow_gold = colors_names[index]

func _on_SetWeaponTransparency_value_changed(value: float):
	ProgressData.settings.yztato_set_weapon_transparency = value
func _on_SetEnemyTransparency_value_changed(value: float):
	ProgressData.settings.yztato_set_enemy_transparency = value
func _on_SetEnemyProjTransparency_value_changed(value: float):
	ProgressData.settings.yztato_set_enemy_proj_transparency = value
func _on_SetGoldTransparency_value_changed(value: float):
	ProgressData.settings.yztato_set_gold_transparency = value
func _on_SetConsumableTransparency_value_changed(value: float):
	ProgressData.settings.yztato_set_consumable_transparency = value
