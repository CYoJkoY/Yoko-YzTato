extends "res://singletons/progress_data.gd"

const yz_colors: Dictionary = {
	"YZ_EXLIGHT":["#FFEBEE","#FCE4EC","#F3E5F5","#EDE7F6",
				"#E8EAF6","#E3F2FD","#E1F5FE","#E0F7FA",
				"#E0F2F1","#E8F5E9","#F1F8E9","#F9FBE7",
				"#FFFDE7","#FFF8E1","#FFF3E0","#FBE9E7",
				"#EFEBE9","#FAFAFA","#ECEFF1"],
	"YZ_LIGHT": ["#FFCDD2","#F8BBD0","#E1BEE7","#D1C4E9",
				"#C5CAE9","#BBDEFB","#B3E5FC","#B2EBF2",
				"#B2DFDB","#C8E6C9","#DCEDC8","#F0F4C3",
				"#FFF9C4","#FFECB3","#FFE0B2","#FFCCBC",
				"#D7CCC8","#F5F5F5","#CFD8DC"],
	"YZ_MEDIUM": ["#EF9A9A","#F48FB1","#CE93D8","#B39DDB",
				"#9FA8DA","#90CAF9","#81D4FA","#80DEEA",
				"#80CBC4","#A5D6A7","#C5E1A5","#E6EE9C",
				"#FFF59D","#FFE082","#FFCC80","#FFAB91",
				"#BCAAA4","#EEEEEE","#B0BEC5"],
	"YZ_DARK": ["#E57373","#F06292","#BA68C8","#9575CD",
				"#7986CB","#64B5F6","#4FC3F7","#4DD0E1",
				"#4DB6AC","#81C784","#AED581","#DCE775",
				"#FFF176","#FFD54F","#FFB74D","#FF8A65",
				"#A1887F","#E0E0E0","#90A4AE"],
	"YZ_EXDARK": ["#EF5350","#EC407A","#AB47BC","#7E57C2",
				"#5C6BC0","#42A5F5","#29B6F6","#26C6DA",
				"#26A69A","#66BB6A","#9CCC65","#D4E157",
				"#FFEE58","#FFCA28","#FFA726","#FF7043",
				"#8D6E63","#BDBDBD","#78909C"]
}

var Yztato = null

# =========================== Extention =========================== #
func _ready() -> void:
	_yztato_ready()

func init_settings()->void :
	.init_settings()
	settings.merge(init_yztato_set_options())

# =========================== Custom =========================== #
func _yztato_ready() -> void:
	var yztato_data = load("res://mods-unpacked/Yoko-YzTato/content_data/YzTato_content_New.tres")
	yztato_data.add_resources()

	RunData.reset()

	load_game_file()
	add_unlocked_by_default()

	set_max_selectable_difficulty()

	Yztato = get_node("/root/ModLoader/Yoko-YzTato/Yztato")

func init_yztato_set_options() -> Dictionary:
	return {
		"item_appearances_hide": false,
		"yztato_unlock_difficulties": false,
		"yztato_unlock_all_chars": false,
		"yztato_unlock_all_challenges": false,
		"yztato_optimize_pickup": true,
		"yztato_starting_weapons": false,

		"yztato_starting_items": false,
		"yztato_starting_items_times": 1,

		"yztato_rainbow_gold": "YZ_EMPTY",
		
		"yztato_set_weapon_transparency": 1.0,
		"yztato_set_enemy_transparency": 1.0,
		"yztato_set_enemy_proj_transparency": 1.0,
		"yztato_set_gold_transparency": 1.0,
		"yztato_set_consumable_transparency": 1.0,
	}
