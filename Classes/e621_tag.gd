class_name  e621Tag
extends Resource

enum Category {
	GENERAL = 0,
	ARTIST = 1,
	COPYRIGHT = 3,
	CHARACTER = 4,
	SPECIES = 5,
	INVALID = 6,
	META = 7,
	LORE= 8,
}


var id: int = 0
var tag_name: String = ""
var post_count: int = 0
var related_tags: Dictionary = {}
var category: Category = Category.GENERAL
var is_locked: bool

var highest_tag_strenght: int = 0


func set_related_tags(set_tags: String) -> void:
	var _set_tags: Array = set_tags.split(" ")
	var _tags: Array = []
	var _weights: Array = []
	
	for index in range(_set_tags.size()):

		if index % 2 == 0:
			_tags.append(_set_tags[index].replace("_", " "))
		else:
			_weights.append(_set_tags[index])
	
	for index in range(_weights.size()):
		if Tagger.settings_lists.suggestion_blacklist.has(_tags[index]):
			continue

		if highest_tag_strenght < int(_weights[index]):
			highest_tag_strenght = int(_weights[index])
		
		if not related_tags.has(_weights[index]):
			related_tags[_weights[index]] = []
		
		related_tags[_weights[index]].append(_tags[index])
		

func get_tags_with_strength() -> PackedStringArray:
	var _return_list: PackedStringArray = []
	
	var target_strenght = highest_tag_strenght * (Tagger.settings.suggestion_strength / 100.0)
	
	for strenght in related_tags.keys():
		if target_strenght <= int(strenght):
			_return_list.append_array(related_tags[strenght])
	
	return _return_list


func translate_category() -> Tagger.Categories:
	if category == Category.ARTIST:
		return Tagger.Categories.ARTIST
	elif category == Category.COPYRIGHT:
		return Tagger.Categories.COPYRIGHT
	elif category == Category.CHARACTER:
		return Tagger.Categories.CHARACTER
	elif category == Category.SPECIES:
		return Tagger.Categories.SPECIES
	else:
		return Tagger.Categories.GENERAL

