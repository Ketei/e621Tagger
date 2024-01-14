extends SpinBox
@onready var focus_spin_box: SpinBox = $"../../CharacterFocusHBox/FocusSpinBox"

@onready var threesome_check: CheckBox = $"../../../../InteractionAmount/Base/SinContainer/ThreesomeCheck"
@onready var gangbang_check: CheckBox = $"../../../../InteractionAmount/Base/SinContainer/GangbangType/GangbangCheck"
@onready var reverse_gb_check: CheckBox = $"../../../../InteractionAmount/Base/SinContainer/GangbangType/ReverseGBCheck"
@onready var foursome_check: CheckBox = $"../../../../InteractionAmount/Base/SinContainer/FoursomeCheck"
@onready var fivesome_check: CheckBox = $"../../../../InteractionAmount/Base/SinContainer/FivesomeCheck"
@onready var orgy_check: CheckBox = $"../../../../InteractionAmount/Base/SinContainer/OrgyCheck"
@onready var character_clothes: SpinBox = $"../../../../ClothingHBox/VBoxContainer/HBoxContainer/CharacterClothes"


func _ready():
	value_changed.connect(current_value_change)


func current_value_change(current: int) -> void:
	focus_spin_box.max_value = current
	character_clothes.max_value = current
	
	if 2 < current and threesome_check.disabled:
		threesome_check.disabled = false
	elif current <= 2 and not threesome_check.disabled:
		threesome_check.disabled = true
	
	if 3 < current and foursome_check.disabled:
		foursome_check.disabled = false
		gangbang_check.disabled = false
		reverse_gb_check.disabled = false
	elif current <= 3 and not foursome_check.disabled:
		foursome_check.disabled = true
		gangbang_check.disabled = true
		reverse_gb_check.disabled = true
	
	if 4 < current and fivesome_check.disabled:
		fivesome_check.disabled = false
		orgy_check.disabled = false
	elif current <= 4 and not fivesome_check.disabled:
		fivesome_check.disabled = true
		orgy_check.disabled = true
