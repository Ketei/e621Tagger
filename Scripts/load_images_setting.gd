extends CheckButton

@onready var e621_load_button: CheckButton = $VBoxContainer/ToggleButtons/e621LoadButton
@onready var local_load_button: CheckButton = $VBoxContainer/ToggleButtons/LocalLoadButton
@onready var e_621_spin_box: SpinBox = $VBoxContainer/AmountToLoad/e621SpinBox
@onready var local_spin_box: SpinBox = $VBoxContainer/AmountToLoad/LocalSpinBox
@onready var load_gif_e621_check_box: CheckBox = $VBoxContainer/AmountToLoad2/LoadGife6CheckBox
@onready var load_gif_local_check_box: CheckBox = $VBoxContainer/AmountToLoad2/LoadGifLocalCheckBox2
@onready var columns_spin_box: SpinBox = $ColumnsSpinBox

func _ready():
	
	button_pressed = Tagger.settings.load_review_images
	local_load_button.button_pressed = Tagger.settings.load_review_local
	e621_load_button.button_pressed = Tagger.settings.load_review_e621
	load_gif_e621_check_box.button_pressed = Tagger.settings.load_web_gifs
	load_gif_local_check_box.button_pressed = Tagger.settings.load_local_gifs

	e621_load_button.disabled = not button_pressed
	local_load_button.disabled = not button_pressed
	e_621_spin_box.editable = button_pressed and e621_load_button.button_pressed
	local_spin_box.editable = button_pressed and local_load_button.button_pressed
	local_spin_box.set_value_no_signal(Tagger.settings.local_review_amount)
	
	load_gif_e621_check_box.disabled = not button_pressed or not e621_load_button.button_pressed
	load_gif_local_check_box.disabled = not button_pressed or not local_load_button.button_pressed

	load_gif_e621_check_box.toggled.connect(toggle_load_gifs_e621)
	load_gif_local_check_box.toggled.connect(toggle_load_gifs_local)
	
	e621_load_button.toggled.connect(toggle_e6_load)
	e621_load_button.toggled.connect(e_621_spin_box.set_editable)
	e621_load_button.toggled.connect(e621_gif_checkbox_set_enabled)
	e_621_spin_box.value_changed.connect(e6_spinbox_value_changed)
	
	local_load_button.toggled.connect(toggle_local_load)
	local_load_button.toggled.connect(local_spin_box.set_editable)
	local_load_button.toggled.connect(local_gif_checkbox_set_enabled)
	local_spin_box.value_changed.connect(local_spinbox_value_changed)
	
	e_621_spin_box.set_value_no_signal(Tagger.settings.e621_review_amount)
	
	columns_spin_box.set_value_no_signal(Tagger.settings.picture_columns_to_search)
	columns_spin_box.editable = button_pressed
	columns_spin_box.value_changed.connect(update_columns_review)
	
	self.toggled.connect(toggle_sub_buttons)


func update_columns_review(new_value: float) -> void:
	Tagger.settings.picture_columns_to_search = int(new_value)


func toggle_load_gifs_e621(toggle_state: bool) -> void:
	Tagger.settings.load_web_gifs = toggle_state


func toggle_load_gifs_local(toggle_state: bool) -> void:
	Tagger.settings.load_local_gifs = toggle_state


func e621_gif_checkbox_set_enabled(is_enabled: bool) -> void:
	load_gif_e621_check_box.disabled = not is_enabled


func local_gif_checkbox_set_enabled(is_enabled: bool) -> void:
	load_gif_local_check_box.disabled = not is_enabled


func local_spinbox_value_changed(new_value: float) -> void:
	var _value: int = int(new_value)
	Tagger.settings.local_review_amount = _value
	

func e6_spinbox_value_changed(new_value: float) -> void:
	var _value: int = int(new_value)
	Tagger.settings.e621_review_amount = _value


func toggle_sub_buttons(toggle_state: bool) -> void:
	Tagger.settings.load_review_images = toggle_state
	
	columns_spin_box.editable = toggle_state
	
	e621_load_button.disabled = not toggle_state
	local_load_button.disabled = not toggle_state
	
	e_621_spin_box.editable = e621_load_button.button_pressed and not e621_load_button.disabled
	local_spin_box.editable = local_load_button.button_pressed and not local_load_button.disabled
	
	load_gif_e621_check_box.disabled = not e621_load_button.button_pressed or e621_load_button.disabled
	load_gif_local_check_box.disabled = not local_load_button.button_pressed or local_load_button.disabled


func toggle_e6_load(toggle_state: bool) -> void:
	Tagger.settings.load_review_e621 = toggle_state


func toggle_local_load(toggle_state: bool) -> void:
	Tagger.settings.load_review_local = toggle_state
