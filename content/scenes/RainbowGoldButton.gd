extends OptionButton

func _ready():
	add_item("YZ_EMPTY")
	for colors_name in ProgressData.yz_colors.keys():
		add_item(colors_name)
