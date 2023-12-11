extends Control


signal set_as_accepted(is_submit: bool)

@onready var tag_label: Label = $CenterContainer/SetWindow/MarginContainer/VBoxContainer/HBoxContainer/TagLabel
@onready var categories_menu: OptionButton = $CenterContainer/SetWindow/MarginContainer/VBoxContainer/HBoxContainer/CategoriesMenu
@onready var cancel_button: Button = $CenterContainer/SetWindow/MarginContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var accept_button: Button = $CenterContainer/SetWindow/MarginContainer/VBoxContainer/ButtonsContainer/AcceptButton
@onready var change_cat_check_box: CheckBox = $CenterContainer/SetWindow/MarginContainer/VBoxContainer/HBoxContainer/ChangeCatCheckBox
@onready var change_prio_check_box: CheckBox = $CenterContainer/SetWindow/MarginContainer/VBoxContainer/PrioHBox/ChangePrioCheckBox
@onready var new_priority_spin_box: SpinBox = $CenterContainer/SetWindow/MarginContainer/VBoxContainer/PrioHBox/NewPrioritySpinBox

var prio_selected: int = 0
var change_prio: bool = false

var category_select := Tagger.Categories.GENERAL
var change_category: bool = false


func _ready():
	hide()
	accept_button.pressed.connect(accept_category)
	cancel_button.pressed.connect(cancel_category)
	
	new_priority_spin_box.value_changed.connect(on_spinbox_value_change)
	categories_menu.item_selected.connect(on_cat_change)
	
	change_cat_check_box.toggled.connect(on_cat_toggle)
	change_prio_check_box.toggled.connect(on_prio_toggle)


func on_cat_toggle(is_toggled:bool) -> void:
	change_category = is_toggled


func on_prio_toggle(is_toggled:bool) -> void:
	change_prio = is_toggled


func on_spinbox_value_change(new_value: float) -> void:
	prio_selected = int(new_value)
	if not change_prio_check_box.button_pressed:
		change_prio_check_box.button_pressed = true


func on_cat_change(new_category: int) -> void:
	category_select = new_category as Tagger.Categories
	if not change_cat_check_box.button_pressed:
		change_cat_check_box.button_pressed = true


func set_target_tag(tag_name: String, tag_category: int = 0, tag_priority: int = 0) -> void:
	tag_label.text = tag_name
	categories_menu.selected = categories_menu.get_item_index(tag_category)
	new_priority_spin_box.set_value_no_signal(tag_priority)
	change_prio_check_box.button_pressed = false
	change_cat_check_box.button_pressed = false


func accept_category() -> void:
	set_as_accepted.emit(true)


func cancel_category() -> void:
	set_as_accepted.emit(false)
