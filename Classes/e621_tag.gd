class_name  e621Tag
extends Node

enum Category {
	GENERAL,
	ARTIST,
	COPYRIGHT,
	CHARACTER,
	SPECIES,
	INVALID,
	META,
	LORE,
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
		
		if highest_tag_strenght < int(_weights[index]):
			highest_tag_strenght = int(_weights[index])
		
		if not related_tags.has(_weights[index]):
			related_tags[_weights[index]] = []
		
		related_tags[_weights[index]].append(_tags[index])
		

func get_tags_with_strenght() -> Array[String]:
	var _return_list: Array[String] = []
	
	var target_strenght = highest_tag_strenght * (Tagger.settings.suggestion_strength / 100.0)
	
	for strenght in related_tags.keys():
		if target_strenght <= int(strenght):
			_return_list.append_array(related_tags[strenght])
	
	return _return_list

