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


func get_tags() -> Array[String]:
	var tags: Array[String] = []
	tags.append_array(tags_array) 
	if node_to_display:
		tags.append_array(node_to_display.get_tags())
	return tags


func get_suggestions() -> Array:
	var suggestions: Array[String] = []
	suggestions.append_array(suggestions) 
	if node_to_display:
		suggestions.append_array(node_to_display.get_suggestions())
	return suggestions


func reset_selections() -> void:
	if button_pressed:
		set_pressed_no_signal(false)
	if node_to_display:
		node_to_display.visible = display_inverted
		if node_to_display is OptionButton:
			node_to_display.select(0)
		else:
			node_to_display.reset_selection()

