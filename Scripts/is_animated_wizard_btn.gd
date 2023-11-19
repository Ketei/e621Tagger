extends CheckButton

@onready var loops_button: CheckButton = $"../LoopsChkBtn"
@onready var animation_types_btn: OptionButton = $"../AnimationTypesBTN"
@onready var playtime_opt_btn: OptionButton = $"../PlaytimeOptBtn"
@onready var fr_by_fr_anim_chk_btn: CheckButton = $"../FrByFrAnimChkBtn"


func _ready():
	toggled.connect(toggled_button)


func toggled_button(is_toggled: bool) -> void:
	loops_button.disabled = not is_toggled
	animation_types_btn.disabled = not is_toggled
	playtime_opt_btn.disabled = not is_toggled
	fr_by_fr_anim_chk_btn.disabled = not is_toggled
