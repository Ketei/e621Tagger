class_name WizzardCheckbox
extends CheckBox

@export var tags_to_include: String
@export var suggestions_to_include: String
@export var node_to_display: Control
@export var display_inverted: bool = false

var tags_array: Array[String] = []
var suggestions_array: Array[String] = []


func _ready():
	for tag in tags_to_include.split(",", false):
		tags_array.append(tag.strip_edges())
		
	for sugg in suggestions_to_include.split(",", false):
		suggestions_array.append(sugg.strip_edges())
	
	if display_inverted and button_pressed:
		if node_to_display:
			node_to_display.hide()
	else:
		if not button_pressed:
			if node_to_display:
				node_to_display.hide()
		
	toggled.connect(toggle_display)


func toggle_display(is_toggled: bool) -> void:
	if not node_to_display:
		return
	
	if display_inverted:
		is_toggled = not is_toggled
	
	node_to_display.visible = is_toggled
