extends HBoxContainer

#@onready var default_site_optbtn: OptionButton = $AvailableSites
#
#
#func _ready():
#	default_site_optbtn.selected = Tagger.site_settings.target_site
#	default_site_optbtn.item_selected.connect(target_site_change)
#
#
#func target_site_change(index_selected: int) -> void:
#	Tagger.site_settings.target_site = default_site_optbtn.get_item_id(index_selected) as Tagger.Sites
