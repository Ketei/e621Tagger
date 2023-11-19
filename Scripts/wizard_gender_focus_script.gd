extends CheckBox

@export var main_checkbox: bool = false
@export var parent_checkbox: CheckBox
@export var focused_array: Array[CheckBox] = []


func _ready():
	if main_checkbox:
		for checkbox in focused_array:
			checkbox.focused_array = focused_array.duplicate()
	
	focused_array.erase(self)
#	toggled.connect(this_toggled)


func enable_focus() -> void:
	disabled = not parent_checkbox.button_pressed


func this_toggled(toggle_state: bool) -> void:
	if toggle_state:
		for checkbox in focused_array:
			checkbox.disabled = true
			checkbox.set_pressed_no_signal(false)
	else:
		for checkbox in focused_array:
			if checkbox == self:
				continue
			checkbox.enable_focus()

