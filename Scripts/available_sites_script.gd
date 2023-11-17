extends OptionButton

signal site_selected(site_id)

## Sets to the selected site in site_settings when loading
@export var set_on_load: bool = false
## Changes setting in site_settings when changed
@export var save_on_set: bool = false


func _ready():
	load_sites()
	
	if set_on_load:
		var selected_index: int = Tagger.available_sites.find(Tagger.site_settings.default_site)
		if selected_index == -1:
			select(0)
			Tagger.site_settings.default_site = Tagger.available_sites[0]
		else:
			select(selected_index)
	
	item_selected.connect(new_site_selected)


func load_sites() -> void:
	clear()
	for site in Tagger.available_sites:
		add_item(Utils.better_capitalize(site, true))


func new_site_selected(index_selected: int) -> void:
	if save_on_set:
		Tagger.site_settings.default_site = Tagger.available_sites[index_selected]
	
	site_selected.emit(index_selected)


#func _notification(what):
#	if what == Tagger.Notifications.SITES_UPDATED:
#		load_sites()

