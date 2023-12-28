class_name  TagListGenerator
extends Node

const character_amounts: Array[String] = ["zero pictured", "solo", "duo", "trio", "group"]
const character_bodytypes: Array[String] = ["anthro", "semi-anthro", "feral", "humanoid", "human", "taur"]
const character_genders: Array[String] = ["male", "female", "ambiguous gender", "andromorph", "gynomorph", "herm", "maleherm"]

var target_site: String = ""

var explored_tags: Array = []
var unexplored_tags: Array = []

var _dad_queue: Array = []
var _groped_dads: Array = []
var _kid_return: Array = []
var _offline_suggestions: Array[String] = []

var priority_dict: Dictionary = {}
var types_count: Dictionary = {
	"species": 0,
	"genders": 0,
	"body_types": 0
	}

func clear_data() -> void:
	explored_tags.clear()
	unexplored_tags.clear()
	
	
	_dad_queue.clear()
	_groped_dads.clear()
	_kid_return.clear()
	_offline_suggestions.clear()


func generate_tag_list_v2(tags_dictionary: Dictionary) -> void:
	explored_tags.clear()
	unexplored_tags.clear()
	priority_dict.clear()
	
	var category_keys: Array = Tagger.Categories.keys()
	
	for tag_added in tags_dictionary.keys():
		var formated_tag: String = tag_added
		if Tagger.settings.include_categories[category_keys[tags_dictionary[tag_added]["category"]].to_lower()]["include"]:
			formated_tag = Tagger.settings.include_categories[category_keys[tags_dictionary[tag_added]["category"]].to_lower()]["tag_name"] + ":" + formated_tag
		if unexplored_tags.has(tag_added):
			unexplored_tags.erase(tag_added)
		
		if not priority_dict.has(str(tags_dictionary[tag_added]["priority"])):
			priority_dict[str(tags_dictionary[tag_added]["priority"])] = []
		
		if not priority_dict[str(tags_dictionary[tag_added]["priority"])].has(formated_tag):
			priority_dict[str(tags_dictionary[tag_added]["priority"])].append(formated_tag)
		
		explored_tags.append(tag_added)
		
		for parent_tag in tags_dictionary[tag_added]["parents"]:
			if not unexplored_tags.has(parent_tag) and not explored_tags.has(parent_tag):
				unexplored_tags.append(parent_tag)

	__explore_parents_v2()


func __explore_parents_v2():
	var _parents_queue: Array = unexplored_tags.duplicate()
	var _category_keys: Array = Tagger.Categories.keys()
	
	for parent_tag in _parents_queue:
		
		explored_tags.append(parent_tag)
		unexplored_tags.erase(parent_tag)
		
		if Tagger.tag_manager.has_tag(parent_tag):
			var tag_load: Tag = Tagger.tag_manager.get_tag(parent_tag)
			
			if not priority_dict.has(str(tag_load.tag_priority)):
				priority_dict[str(tag_load.tag_priority)] = []
			
			var formatted_tag: String = tag_load.tag
			
			if Tagger.settings.include_categories[_category_keys[tag_load.category].to_lower()]["include"]:
				formatted_tag = Tagger.settings.include_categories[_category_keys[tag_load.category].to_lower()]["tag_name"] + ":" + tag_load.tag
			
			if not priority_dict[str(tag_load.tag_priority)].has(formatted_tag):
				priority_dict[str(tag_load.tag_priority)].append(formatted_tag)
				
			for parent in tag_load.parents:
				if not explored_tags.has(parent):
					unexplored_tags.append(parent)
		else:
			if not priority_dict.has("0"):
				priority_dict["0"] = []
			if not priority_dict["0"].has(parent_tag):
				priority_dict["0"].append(parent_tag)
	
	if not unexplored_tags.is_empty():
		__explore_parents_v2()


func explore_parents_v2(_is_first_run: bool = true) -> void:
	if _is_first_run:
		types_count["species"] = 0
		types_count["genders"] = 0
		types_count["body_types"] = 0
		_groped_dads.clear()
		_kid_return.clear()
		_offline_suggestions.clear()
	
	for tag_file in _dad_queue.duplicate():
		_groped_dads.append(tag_file)
		if tag_file.category == Tagger.Categories.SPECIES:
			types_count["species"] += 1
		
		for new_parent in tag_file.parents:
			_kid_return.append(new_parent)
			if new_parent in character_bodytypes:
				types_count["body_types"] += 1
			elif new_parent in character_genders:
				types_count["genders"] += 1
			
			if Tagger.tag_manager.has_tag(new_parent):
				var _new_parent_to_look: Tag = Tagger.tag_manager.get_tag(new_parent)
				if not _groped_dads.has(_new_parent_to_look):
					_dad_queue.append(_new_parent_to_look)

		for suggestion in tag_file.suggestions:
			if not _offline_suggestions.has(suggestion):
				_offline_suggestions.append(suggestion)
		
		_dad_queue.erase(tag_file)
	
	if not _dad_queue.is_empty():
		explore_parents_v2(false)


func create_list_from_array(array_data: Array[String], whitespace_char: String, separator_char: String) -> String:
	var _return_string: String = ""
	
	for tag in array_data:
		_return_string += tag.replace(" ", whitespace_char)
		_return_string += separator_char
	
	_return_string = _return_string.left(-separator_char.length())
	
	for tag in Tagger.settings_lists.constant_tags:
		var _formatted_tag: String = tag.replace(" ", whitespace_char)
		if not array_data.has(_formatted_tag):
			if not _return_string.is_empty():
				_return_string += separator_char
			_return_string += _formatted_tag
	
	return _return_string.strip_edges()


func get_tag_list_v2(clear_on_end: bool = true) -> Array[String]:
	var priority_array: Array[int] = []
	
	for prio in priority_dict.keys():
		priority_array.append(int(prio))
	
	priority_array.sort_custom(func(a, b): return a > b)
	
	var full_tags: Array[String] = []
	
	for prio_key in priority_array:
		for tag_string in priority_dict[str(prio_key)]:
			if not full_tags.has(tag_string):
				full_tags.append(tag_string)
	
	if clear_on_end:
		clear_data()
	
	return full_tags

