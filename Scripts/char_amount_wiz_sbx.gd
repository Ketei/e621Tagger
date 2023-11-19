extends SpinBox
@onready var focus_spin_box: SpinBox = $"../../CharacterFocusHBox/FocusSpinBox"


func _ready():
	value_changed.connect(current_value_change)


func current_value_change(current: int) -> void:
	focus_spin_box.max_value = current
