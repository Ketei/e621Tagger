class_name  TagListGenerator
extends Node

const character_amounts: Array[String] = ["zero pictured", "solo", "duo", "trio", "group"]
const character_bodytypes: Array[String] = ["anthro", "semi-anthro", "feral", "humanoid", "human", "taur"]
const character_genders: Array[String] = ["male", "female", "ambiguous gender", "andromorph", "gynomorph", "herm", "maleherm"]


var _gen_tags: Array[String] = []
var _implied_tags: Array[String] = []

var _unexplored_parents: Array[Tag] = []
var _explored_parents: Array[Tag] = []

var inputed_tags: Array = []
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
	_gen_tags.clear()
	_implied_tags.clear()
	_unexplored_parents.clear()
	_explored_parents.clear()
	
	_dad_queue.clear()
	_groped_dads.clear()
	_kid_return.clear()
	_offline_suggestions.clear()


func generate_tag_list(resource_tags: Array, generic_tags: Array) -> void:
	_gen_tags.clear()
	_implied_tags.clear()
	_explored_parents.clear()
	_unexplored_parents.clear()
	priority_dict.clear()
	
	for generic_tag in generic_tags:
		_gen_tags.append(generic_tag)
	
	for tag in resource_tags:
		if not priority_dict.has(str(tag.tag_priority)):
			priority_dict[str(tag.tag_priority)] = []
		
		if not priority_dict[str(tag.tag_priority)].has(tag.get_tag()):
			priority_dict[str(tag.tag_priority)].append(tag.get_tag())
		
		_explored_parents.append(tag)
		
		for parent_tag in tag.parents:
			if Tagger.tag_manager.has_tag(parent_tag):

				_unexplored_parents.append(
					Tagger.tag_manager.get_tag(parent_tag))
			else:
				if not _implied_tags.has(parent_tag):# and not _user_tags.has(parent_tag):
					_implied_tags.append(parent_tag)
		
	__explore_parents()


func generate_tag_list_v2(tags_dictionary: Dictionary) -> void:
	_gen_tags.clear()
	_implied_tags.clear()
	explored_tags.clear()
	unexplored_tags.clear()
	priority_dict.clear()
	
	for tag_added in tags_dictionary.keys():
		if unexplored_tags.has(tag_added):
			unexplored_tags.erase(tag_added)
		
		if not priority_dict.has(str(tags_dictionary[tag_added]["priority"])):
			priority_dict[str(tags_dictionary[tag_added]["priority"])] = []
		
		if not priority_dict[str(tags_dictionary[tag_added]["priority"])].has(tag_added):
			priority_dict[str(tags_dictionary[tag_added]["priority"])].append(tag_added)
		
		explored_tags.append(tag_added)
		
		for parent_tag in tags_dictionary[tag_added]["parents"]:
			if not unexplored_tags.has(parent_tag) and not explored_tags.has(parent_tag):
				unexplored_tags.append(parent_tag)

	__explore_parents_v2()


func __explore_parents_v2():
	var _parents_queue: Array = unexplored_tags.duplicate()
	
	for parent_tag in _parents_queue:
		
		explored_tags.append(parent_tag)
		unexplored_tags.erase(parent_tag)
		
		if Tagger.tag_manager.has_tag(parent_tag):
			var tag_load: Tag = Tagger.tag_manager.get_tag(parent_tag)
			
			if not priority_dict.has(str(tag_load.tag_priority)):
				priority_dict[str(tag_load.tag_priority)] = []
			
			if not priority_dict[str(tag_load.tag_priority)].has(tag_load.get_tag()):
				priority_dict[str(tag_load.tag_priority)].append(tag_load.get_tag())
				
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


func explore_parents(_is_first_run: bool = true) -> void:
	if _is_first_run:
		_groped_dads.clear()
		_kid_return.clear()
		_offline_suggestions.clear()
	
	for tag_file in _dad_queue:
		_groped_dads.append(tag_file)
		
		var _tag_name = tag_file.get_tag()
		
		_kid_return.append(_tag_name) # ??????
		
		for new_parent in tag_file.parents:
			if Tagger.tag_manager.has_tag(new_parent):
				var _new_parent_to_look: Tag = Tagger.tag_manager.get_tag(new_parent)
				if _groped_dads.has(_new_parent_to_look):
					continue
				_dad_queue.append(_new_parent_to_look)
			else:
				_kid_return.append(new_parent)
		
		for suggestion in tag_file.suggestions:
			if not _offline_suggestions.has(suggestion):
				_offline_suggestions.append(suggestion)
		
		_dad_queue.erase(tag_file) # Do this at the end
	
	if not _dad_queue.is_empty():
		explore_parents(false)


func __explore_parents():
	var _parents_queue: Array[Tag] = _unexplored_parents.duplicate()
	
	for parent_tag in _parents_queue:
		
		_explored_parents.append(parent_tag)
		_unexplored_parents.erase(parent_tag)
		
		var _tag_name = parent_tag.get_tag()
		
		if not priority_dict.has(str(parent_tag.tag_priority)):
			priority_dict[str(parent_tag.tag_priority)] = []
		
		if not _implied_tags.has(_tag_name) and not priority_dict[str(parent_tag.tag_priority)].has(_tag_name):
			priority_dict[str(parent_tag.tag_priority)].append(_tag_name)
		
		for new_parent in parent_tag.parents:
			if Tagger.tag_manager.has_tag(new_parent):
				var _new_parent_to_look = Tagger.tag_manager.get_tag(new_parent)
				if _explored_parents.has(_new_parent_to_look):
					continue
				_unexplored_parents.append(_new_parent_to_look)
			else:
				if not _implied_tags.has(new_parent):
					_implied_tags.append(new_parent)
		
		if not _unexplored_parents.is_empty():
			__explore_parents()


func create_list_from_array(array_data: Array[String]) -> String:
	var _return_string: String = ""
	
	for tag in array_data:
		_return_string += tag.replace(" ", Tagger.site_settings.whitespace_char)
		_return_string += Tagger.site_settings.tag_separator
	
	_return_string = _return_string.left(-Tagger.site_settings.tag_separator.length())
	
	for tag in Tagger.settings_lists.constant_tags:
		var _formatted_tag: String = tag.replace(" ", Tagger.site_settings.whitespace_char)
		if not array_data.has(_formatted_tag):
			if not _return_string.is_empty():
				_return_string += Tagger.site_settings.tag_separator
			_return_string += _formatted_tag
	
	return _return_string.strip_edges()


func get_tag_list_v2(clear_on_end: bool = true) -> Array[String]:
	var priority_array: Array[int] = []
	
	for prio in priority_dict.keys():
		priority_array.append(int(prio))
	
	priority_array.sort()
	priority_array.reverse()
	
	var full_tags: Array[String] = []
	
	for prio_key in priority_array:
		for tag_string in priority_dict[str(prio_key)]:
			if not full_tags.has(tag_string):
				full_tags.append(tag_string)
	
	if clear_on_end:
		clear_data()
	
	return full_tags


func get_tag_list(clear_on_end: bool = true) -> Array[String]:
	var priority_array: Array[int] = []
	
	for prio in priority_dict.keys():
		priority_array.append(int(prio))
	
	priority_array.sort()
	priority_array.reverse()
	
	var full_tags: Array[String] = []
	
	for prio_key in priority_array:
		for tag_string in priority_dict[str(prio_key)]:
			if not full_tags.has(tag_string):
				full_tags.append(tag_string)
	
	for tag in _gen_tags:
		if not full_tags.has(tag):
			full_tags.append(tag)
	
	for tag in _implied_tags:
		if not full_tags.has(tag):
			full_tags.append(tag)
	
	if clear_on_end:
		clear_data()
	
	return full_tags

