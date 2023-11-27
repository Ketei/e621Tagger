extends Control


signal category_selected(category_number)

@onready var tag_label: Label = $CenterContainer/SetWindow/VBoxContainer/HBoxContainer/TagLabel
@onready var categories_menu: OptionButton = $CenterContainer/SetWindow/VBoxContainer/HBoxContainer/CategoriesMenu
@onready var cancel_button: Button = $CenterContainer/SetWindow/VBoxContainer/ButtonsContainer/CancelButton
@onready var accept_button: Button = $CenterContainer/SetWindow/VBoxContainer/ButtonsContainer/AcceptButton


func _ready():
	hide()
	accept_button.pressed.connect(accept_category)
	cancel_button.pressed.connect(cancel_category)


func set_target_tag(tag_name: String) -> void:
	tag_label.text = tag_name
	categories_menu.select(0)


func accept_category() -> void:
	category_selected.emit(categories_menu.selected)


func cancel_category() -> void:
	category_selected.emit(-1)
