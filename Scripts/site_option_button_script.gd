extends OptionButton

func _ready():
	for site in Tagger.Sites.keys():
		if site == "E621":
			add_item("e621/Itaku")
		else:
			add_item(site.capitalize())
