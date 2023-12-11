extends OptionButton


@export var defined_options: OptionButton
@onready var animations_h_box: VBoxContainer = $"../AnimationsVBox"


var elements_array: Array = [
		[
			"Digital drawing (artwork)",
			"Digital painting (artwork)",
			"Pixel (artwork)",
			"3D (artwork)",
			"Oekaki",
		], # Digital
		[
			"Colored pencil (artwork)",
			"Marker (artwork)",
			"Crayon (artwork)",
			"Pastel (artwork)",
			"Painting (artwork)",
			"Pen (artwork)",
			"Sculpture (artwork)",
			"Graphite (artwork)",
			"Chalk (artwork)",
			"Charcoal (artwork)",
			"Engraving (artwork)",
			"Airbrush (artwork)",
		], # Traditional
		[""], # Photography
		[
			"2D animation",
			"3D animation",
			"Pixel animation"
		]# Animated
]


func _ready():
	new_selected(0)
	item_selected.connect(new_selected)


func new_selected(selected_index: int) -> void:
	defined_options.clear()
	for element in elements_array[selected_index]:
		defined_options.add_item(element)
	defined_options.select(0)
	
	if selected_index == 3:
		animations_h_box.show()
	else:
		animations_h_box.hide()

