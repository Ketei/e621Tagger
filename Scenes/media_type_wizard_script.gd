extends OptionButton


@export var defined_options: OptionButton
@onready var animations_h_box: VBoxContainer = $"../AnimationsVBox"


var elements_array: Array = [
		[
			"digital drawing (artwork)",
			"digital painting (artwork)",
			"pixel (artwork)",
			"3d (artwork)",
			"oekaki",
		], # Digital
		[
			"colored pencil (artwork)",
			"marker (artwork)",
			"crayon (artwork)",
			"pastel (artwork)",
			"painting (artwork)",
			"pen (artwork)",
			"sculpture (artwork)",
			"graphite (artwork)",
			"chalk (artwork)",
			"charcoal (artwork)",
			"engraving (artwork)",
			"airbrush (artwork)",
		], # Traditional
		[""], # Photography
		[
			"2d animation",
			"3d animation",
			"pixel animation"
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

