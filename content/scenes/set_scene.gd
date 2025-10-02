extends Control

signal back_button_pressed

onready var ItemAppearancesHideButton = $"%ItemAppearancesHide" as CheckButton
onready var UnlockDifficulties = $"%UnlockDifficulties" as CheckButton
onready var UnlockAllChars = $"%UnlockAllChars" as CheckButton
onready var UnlockAllChallenges = $"%UnlockAllChallenges" as CheckButton
onready var OptimizePickUp = $"%OptimizePickUp" as CheckButton

onready var RainbowGold = $"%RainbowGold" as OptionButton
var colors_names: Array = ["YZ_EMPTY", "YZ_EXLIGHT", "YZ_LIGHT", "YZ_MEDIUM", "YZ_DARK", "YZ_EXDARK"]

onready var SetWeaponTransparency = $"%SetWeaponTransparency"
onready var SetEnemyTransparency = $"%SetEnemyTransparency"
onready var SetEnemyProjTransparency = $"%SetEnemyProjTransparency"
onready var SetGoldTransparency = $"%SetGoldTransparency"
onready var SetConsumableTransparency = $"%SetConsumableTransparency"

func init()->void :
	$BackButton.grab_focus()
	init_values_from_progress_data()

func init_values_from_progress_data() -> void:
	ItemAppearancesHideButton.pressed = ProgressData.settings.item_appearances_hide
	UnlockDifficulties.pressed = ProgressData.settings.yztato_unlock_difficulties
	UnlockAllChars.pressed = ProgressData.settings.yztato_unlock_all_chars
	UnlockAllChallenges.pressed = ProgressData.settings.yztato_unlock_all_challenges
	OptimizePickUp.pressed = ProgressData.settings.yztato_optimize_pickup

	RainbowGold.select(colors_names.find(ProgressData.settings.yztato_rainbow_gold))

	SetWeaponTransparency.set_value(ProgressData.settings.yztato_set_weapon_transparency)
	SetEnemyTransparency.set_value(ProgressData.settings.yztato_set_enemy_transparency)
	SetEnemyProjTransparency.set_value(ProgressData.settings.yztato_set_enemy_proj_transparency)
	SetGoldTransparency.set_value(ProgressData.settings.yztato_set_gold_transparency)
	SetConsumableTransparency.set_value(ProgressData.settings.yztato_set_consumable_transparency)

# =========================== Save =========================== #
func _on_BackButton_pressed():
	emit_signal("back_button_pressed")

func _on_MenuYztatoSetOptions_hide():
	ProgressData.save()

# =========================== Check =========================== #
func _on_ItemAppearancesHide_toggled(button_pressed: bool):
	ProgressData.settings.item_appearances_hide = button_pressed

func _on_UnlockDifficulties_toggled(button_pressed: bool):
	ProgressData.settings.yztato_unlock_difficulties = button_pressed


func _on_UnlockAllChars_toggled(button_pressed: bool):
	ProgressData.settings.yztato_unlock_all_chars = button_pressed

func _on_UnlockAllChallenges_toggled(button_pressed: bool):
	ProgressData.settings.yztato_unlock_all_challenges = button_pressed

func _on_OptimizePickUp_toggled(button_pressed: bool):
	ProgressData.settings.yztato_optimize_pickup = button_pressed

# =========================== Option =========================== #
func _on_RainbowGold_item_selected(index: int):
	ProgressData.settings.yztato_rainbow_gold = colors_names[index]

# =========================== Slider =========================== #
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
