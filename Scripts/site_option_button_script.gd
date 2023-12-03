extends OptionButton

func _ready():
	get_popup().max_size.y = 512
	for site in Tagger.Sites.keys():
		if site == "E621":
			add_item("e621/Itaku")
		else:
			add_item(site.capitalize())
