class_name CategoryItem
extends HBoxContainer


signal load_subcategory(category_to_load: String)
signal delete_category(category_to_delete: String, caller_node: Node)

var tag_category: String = ""

@onready var category_button: Button = $CategoryKey
@onready var delete_button: Button = $Button

func _ready():
	category_button.text = tag_category
	category_button.pressed.connect(on_button_press)
	delete_button.pressed.connect(on_delete_category)


func on_button_press() -> void:
	load_subcategory.emit(category_button.text)


func on_delete_category() -> void:
	delete_category.emit(category_button.text, self)
	
	
