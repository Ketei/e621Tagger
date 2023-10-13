extends Control
@onready var item_list = $CurrentTags/ItemList


func _ready():
	for count in range(50):
		item_list.add_item(str(randi()))
