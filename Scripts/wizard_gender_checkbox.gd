extends CheckBox

@export var is_main_checkbox: bool = false
@export var focus_checkbox: CheckBox
@export var main_checkboxes: Array[CheckBox] = []


func _ready():
	if is_main_checkbox:
		for checkbox in main_checkboxes:
			if checkbox != self:
				checkbox.main_checkboxes = main_checkboxes
	
	toggled.connect(toggle_state)


func enable_focus_check() -> void:
	focus_checkbox.disabled = not button_pressed


func disable_focus_check() -> void:
	if not focus_checkbox.disabled:
		focus_checkbox.disabled = true


func toggle_state(is_toggled: bool) -> void:
	var checked_count: int = 0
	
	for checkbox in main_checkboxes:
		if checkbox.button_pressed:
			checked_count += 1	
	
	for check_box in main_checkboxes:
		if 1 < checked_count:
			check_box.enable_focus_check()
		else:
			check_box.disable_focus_check()
	
	if not is_toggled:
		focus_checkbox.set_pressed_no_signal(false)

