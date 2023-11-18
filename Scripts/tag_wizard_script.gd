class_name TagWizard
extends Control

signal wizard_tags_created(tags_array)

@export var artist_line_edit: LineEdit

@export var char_amount: SpinBox

@export var male_check_box: CheckBox
@export var female_check_box: CheckBox
@export var ambig_check_box: CheckBox
@export var andro_check_box: CheckBox
@export var gyno_check_box: CheckBox
@export var herm_check_box: CheckBox 
@export var male_herm_check_box: CheckBox

@export var male_focus_check_box: CheckBox
@export var female_focus_check_box: CheckBox
@export var ambig_focus_check_box: CheckBox
@export var andro_focus_check_box: CheckBox
@export var gyno_focus_check_box: CheckBox
@export var herm_focus_check_box: CheckBox 
@export var male_focus_herm_check_box: CheckBox

@export var anthro_check_box: CheckBox
@export var semi_anthro_check_box: CheckBox
@export var feral_check_box: CheckBox
@export var human_check_box: CheckBox
@export var humanoid_check_box: CheckBox
@export var taur_check_box: CheckBox

@export var anthro_focus_check_box: CheckBox
@export var semi_focus_anthro_check_box: CheckBox
@export var feral_focus_check_box: CheckBox
@export var human_focus_check_box: CheckBox
@export var humanoid_focus_check_box: CheckBox
@export var taur_focus_check_box: CheckBox

@export var background_option_button: OptionButton

@export var completion_option_button: OptionButton
@export var color_types_option_button: OptionButton

@export var angle_option_button: OptionButton

@export var media_type_option_button: OptionButton
@export var done_button: Button
@export var cancel_button: Button
@export var interactions_box: HBoxContainer

@export var fur_check_box: CheckBox
@export var scales_check_box: CheckBox
@export var feathers_check_box: CheckBox
@export var wool_check_box: CheckBox
@export var skin_check_box: CheckBox
@export var exo_check_box: CheckBox

var background_types = ["simple background", "detailed background"]
var angle_types: Array = ["front view", "three-quarter view", "side view", "rear view", "high-angle view", "low-angle view"]
var media_types: Array = ["digital media (artwork)", "traditional media (artwork)", "photography (artwork)"]

var suggestions_types: Array = []

func _ready():
	done_button.pressed.connect(create_basic_tags)
	cancel_button.pressed.connect(cancel_button_pressed)


func magic_clean() -> void:
	artist_line_edit.clear()
	char_amount.value = 0
	male_check_box.set_pressed_no_signal(false)
	female_check_box.set_pressed_no_signal(false)
	ambig_check_box.set_pressed_no_signal(false)
	andro_check_box.set_pressed_no_signal(false)
	gyno_check_box.set_pressed_no_signal(false)
	herm_check_box.set_pressed_no_signal(false)
	male_herm_check_box.set_pressed_no_signal(false)
	
	male_focus_check_box.set_pressed_no_signal(false)
	female_focus_check_box.set_pressed_no_signal(false)
	ambig_focus_check_box.set_pressed_no_signal(false)
	andro_focus_check_box.set_pressed_no_signal(false)
	gyno_focus_check_box.set_pressed_no_signal(false)
	herm_focus_check_box.set_pressed_no_signal(false)
	male_focus_herm_check_box.set_pressed_no_signal(false)
	
	for child in interactions_box.get_children():
		child.queue_free()
	
	anthro_check_box.set_pressed_no_signal(false)
	semi_anthro_check_box.set_pressed_no_signal(false)
	feral_check_box.set_pressed_no_signal(false)
	human_check_box.set_pressed_no_signal(false)
	humanoid_check_box.set_pressed_no_signal(false)
	taur_check_box.set_pressed_no_signal(false)
	
	anthro_focus_check_box.set_pressed_no_signal(false)
	semi_focus_anthro_check_box.set_pressed_no_signal(false)
	feral_focus_check_box.set_pressed_no_signal(false)
	human_focus_check_box.set_pressed_no_signal(false)
	humanoid_focus_check_box.set_pressed_no_signal(false)
	taur_focus_check_box.set_pressed_no_signal(false)
	
	background_option_button.select(0)
	completion_option_button.select(0)
	color_types_option_button.select(0)
	angle_option_button.select(0)
	media_type_option_button.select(0)
	
	fur_check_box.set_pressed_no_signal(false)
	scales_check_box.set_pressed_no_signal(false)
	feathers_check_box.set_pressed_no_signal(false)
	wool_check_box.set_pressed_no_signal(false)
	skin_check_box.set_pressed_no_signal(false)
	exo_check_box.set_pressed_no_signal(false)


func create_basic_tags() -> void:
	var return_array: Array = []
	
	if not artist_line_edit.text.strip_edges().is_empty():
		return_array.append(artist_line_edit.text)
	
	if char_amount.value == 0:
		return_array.append("zero pictured")
	elif  char_amount.value == 1:
		return_array.append("solo")
	elif char_amount.value == 2:
		return_array.append("duo")
	elif char_amount.value == 3:
		return_array.append("trio")
		return_array.append("group")
	elif 3 < char_amount.value:
		return_array.append("group")
	
	if male_check_box.button_pressed:
		return_array.append("male")
	if female_check_box.button_pressed:
		return_array.append("female")
	if ambig_check_box.button_pressed:
		return_array.append("ambiguous gender")
	if andro_check_box.button_pressed:
		return_array.append("andromorph")
		return_array.append("intersex")
	if gyno_check_box.button_pressed:
		return_array.append("gynomorph")
		return_array.append("intersex")
	if herm_check_box.button_pressed:
		return_array.append("herm")
		return_array.append("intersex")
	if male_herm_check_box.button_pressed:
		return_array.append("maleherm")
		return_array.append("intersex")
	
	if male_focus_check_box.button_pressed:
		return_array.append("male focus")
	elif female_check_box.button_pressed:
		return_array.append("female focus")
	elif ambig_focus_check_box.button_pressed:
		return_array.append("ambiguous focus")
	elif andro_focus_check_box.button_pressed:
		return_array.append("andromorph focus")
		return_array.append("intersex focus")
	elif gyno_focus_check_box.button_pressed:
		return_array.append("gynomorph focus")
		return_array.append("intersex focus")
	elif herm_focus_check_box.button_pressed:
		return_array.append("herm focus")
		return_array.append("intersex focus")
	elif male_focus_herm_check_box.button_pressed:
		return_array.append("maleherm focus")
		return_array.append("intersex focus")
		
			
	if anthro_check_box.button_pressed:
		return_array.append("anthro")
	if semi_anthro_check_box.button_pressed:
		return_array.append("semi-anthro")
	if feral_check_box.button_pressed:
		return_array.append("feral")
	if human_check_box.button_pressed:
		return_array.append("human")
	if humanoid_check_box.button_pressed:
		return_array.append("humanoid")
	if taur_check_box.button_pressed:
		return_array.append("taur")
	
	if anthro_focus_check_box.button_pressed:
		return_array.append("anthro focus")
	elif semi_focus_anthro_check_box.button_pressed:
		return_array.append("semi-anthro focus")
	elif feral_focus_check_box.button_pressed:
		return_array.append("feral focus")
	elif human_focus_check_box.button_pressed:
		return_array.append("human focus")
	elif humanoid_focus_check_box.button_pressed:
		return_array.append("humanoid focus")
	elif taur_focus_check_box.button_pressed:
		return_array.append("taur focus")
	
	for child in interactions_box.get_children():
		if not child.final_selection.is_empty():
			return_array.append(child.final_selection)
	
	return_array.append(background_types[background_option_button.selected])
	
	if color_types_option_button.selected == 0: # Monochrome
		return_array.append("monochrome")
		if completion_option_button.selected == 0:
			return_array.append("sketch")
		elif completion_option_button.selected == 1:
			return_array.append("lineart")
		elif completion_option_button.selected == 2:
			return_array.append("shaded")
	elif color_types_option_button.selected == 1: # Colored
		if completion_option_button.selected == 0:
			return_array.append("colored sketch")
		elif completion_option_button.selected == 1:
			return_array.append("flat colors")
		elif completion_option_button.selected == 2:
			return_array.append("shaded")
	
	return_array.append(angle_types[angle_option_button.selected])
	
	return_array.append(media_types[media_type_option_button.selected])
	
	if fur_check_box.button_pressed:
		suggestions_types.append("*color* fur")
	if scales_check_box.button_pressed:
		suggestions_types.append("*color* scales")
	if feathers_check_box.button_pressed:
		suggestions_types.append("*color* feathers")
	if wool_check_box.button_pressed:
		suggestions_types.append("*color* wool")
	if skin_check_box.button_pressed:
		suggestions_types.append("*color* skin")
	if exo_check_box.button_pressed:
		suggestions_types.append("*color* exoskeleton")
	
	wizard_tags_created.emit(return_array)


func cancel_button_pressed() -> void:
	wizard_tags_created.emit([])
