extends VBoxContainer


var site_element = preload("res://Scenes/site_element_scene.tscn")


func _ready():
	for site in Tagger.available_sites:
		var new_site: SiteBoxContainer = site_element.instantiate()
		new_site.site_name = site
		new_site.site_whitespace = Tagger.site_settings.valid_sites[site]["whitespace"]
		new_site.site_separator = Tagger.site_settings.valid_sites[site]["separator"]
		add_child(new_site)
