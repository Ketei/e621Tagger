extends OptionButton

func _ready():
	get_popup().max_size.y = 256
	var category_keys: Array = Tagger.Categories.keys()
	for key_index in range(category_keys.size()):
		add_item(category_keys[key_index].replace("_AND_", "_&_").capitalize(), key_index)
	select(0)
