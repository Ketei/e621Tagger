extends SpinBox

@onready var topwear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/TopwearCheckBox"
@onready var underwear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/UnderVBox/UnderwearCheckBox"
@onready var visible_underwear: CheckBox = $"../../../ScrollContainer/HBoxContainer/UnderVBox/VisibleUnderwear"
@onready var bottomwear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/BottomwearCheckBox"
@onready var leg_wear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/LegWearCheckBox"
@onready var arm_wear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/ArmWearCheckBox"
@onready var hand_wear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/HandWearCheckBox"
@onready var foot_wear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/FootWearCheckBox"
@onready var head_wear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/HeadWearCheckBox"
@onready var collar_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/CollarCheckBox"
@onready var eyewear_check_box: CheckBox = $"../../../ScrollContainer/HBoxContainer/EyewearCheckBox"

var max_memory: float = 0
var clothing_opt_dict: Dictionary = {}
var disabled_menus: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	max_memory = max_value
	changed.connect(on_max_changed)
	value_changed.connect(on_current_changed)
	topwear_check_box.toggled.connect(on_topwear_toggled)
	underwear_check_box.toggled.connect(on_underwear_toggled)
	visible_underwear.toggled.connect(on_visible_underwear_toggled)
	bottomwear_check_box.toggled.connect(on_bottomwear_toggled)
	leg_wear_check_box.toggled.connect(on_legwear_toggled)
	arm_wear_check_box.toggled.connect(on_armwear_toggled)
	hand_wear_check_box.toggled.connect(on_handwear_toggled)
	foot_wear_check_box.toggled.connect(on_footwear_toggled)
	head_wear_check_box.toggled.connect(on_headwear_toggled)
	collar_check_box.toggled.connect(on_collar_toggled)
	eyewear_check_box.toggled.connect(on_eyewear_toggled)
	

func on_current_changed(current_value: float) -> void:
	if current_value == 0:
		clear_all()
		change_disabled(true)
		return
	
	if disabled_menus:
		change_disabled(false)
	
	topwear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["topwear"]
	underwear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["underwear"]
	visible_underwear.button_pressed = clothing_opt_dict[str(current_value)]["visible_underwear"]
	bottomwear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["bottomwear"]
	leg_wear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["legwear"]
	arm_wear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["armwear"]
	hand_wear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["handwear"]
	foot_wear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["footwear"]
	head_wear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["headwear"]
	collar_check_box.button_pressed = clothing_opt_dict[str(current_value)]["collar"]
	eyewear_check_box.button_pressed = clothing_opt_dict[str(current_value)]["eyewear"]


func on_topwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["topwear"] = is_toggled


func on_underwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["underwear"] = is_toggled


func on_visible_underwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["visible_underwear"] = is_toggled


func on_bottomwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["bottomwear"] = is_toggled


func on_legwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["legwear"] = is_toggled


func on_armwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["armwear"] = is_toggled


func on_handwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["handwear"] = is_toggled


func on_footwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["footwear"] = is_toggled


func on_headwear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["headwear"] = is_toggled


func on_collar_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["collar"] = is_toggled


func on_eyewear_toggled(is_toggled: bool) -> void:
	if value == 0:
		return
	clothing_opt_dict[str(value)]["eyewear"] = is_toggled


func on_max_changed() -> void:
	if max_memory == max_value:
		return
	if max_value < max_memory:
		var target_key: int = floori(max_memory)
		for _cycle in range(max_memory - max_value):
			clothing_opt_dict.erase(str(target_key))
			target_key -= 1
	else: # max_memory < max_value
		var starting_index: int = floori(max_memory)
		for _cycle in range(max_value - max_memory):
			starting_index += 1
			clothing_opt_dict[str(starting_index)] = get_empty_entry()
	max_memory = max_value


func get_empty_entry() -> Dictionary:
	return {
		"topwear": false,
		"underwear": false,
		"visible_underwear": false,
		"bottomwear": false,
		"legwear": false,
		"armwear": false,
		"handwear": false,
		"footwear": false,
		"headwear": false,
		"collar": false,
		"eyewear": false,
	}


func clear_all() -> void:
	topwear_check_box.set_pressed_no_signal(false)
	underwear_check_box.set_pressed_no_signal(false)
	visible_underwear.set_pressed_no_signal(false)
	bottomwear_check_box.set_pressed_no_signal(false)
	leg_wear_check_box.set_pressed_no_signal(false)
	arm_wear_check_box.set_pressed_no_signal(false)
	hand_wear_check_box.set_pressed_no_signal(false)
	foot_wear_check_box.set_pressed_no_signal(false)
	head_wear_check_box.set_pressed_no_signal(false)
	collar_check_box.set_pressed_no_signal(false)
	eyewear_check_box.set_pressed_no_signal(false)


func change_disabled(is_disabled: bool) -> void:
	topwear_check_box.disabled = is_disabled
	underwear_check_box.disabled = is_disabled
	visible_underwear.disabled = is_disabled
	bottomwear_check_box.disabled = is_disabled
	bottomwear_check_box.disabled = is_disabled
	leg_wear_check_box.disabled = is_disabled
	arm_wear_check_box.disabled = is_disabled
	hand_wear_check_box.disabled = is_disabled
	foot_wear_check_box.disabled = is_disabled
	head_wear_check_box.disabled = is_disabled
	collar_check_box.disabled = is_disabled
	eyewear_check_box.disabled = is_disabled
	disabled_menus = is_disabled




