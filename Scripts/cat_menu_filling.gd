extends OptionButton

func _ready():
	get_popup().max_size.y = 256
	var category_keys: Array = Tagger.Categories.keys()
	for key_index in Tagger.CategorySorting:
		add_item(
				Utils.just_capitalize(
						category_keys[key_index]
						.replace("_AND_", "_&_")
						.replace("_", " ")
						),
				key_index)
	select(0)

