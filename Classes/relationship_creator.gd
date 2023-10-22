class_name TagMaker
extends Node

static func make_tag(tag_name: String, tag_parents: Array, tag_category: Tagger.Categories, tag_wiki_info: String = "", tag_prio: int = 0, tag_suggestions: Array[String] = [], has_images: bool = true, tag_conflicts: Array[String] = []) -> String:
	var _tag_dict: Dictionary = {}
	
	var _tag := Tag.new()
	_tag.tag = tag_name
	_tag.category = tag_category
	_tag.parents = tag_parents
	_tag.wiki_entry = tag_wiki_info
	_tag.tag_priority = tag_prio
	_tag.suggestions = tag_suggestions.duplicate()
	_tag.has_pictures = has_images
	_tag.conflicts = tag_conflicts.duplicate()
	var tag_path: String = _tag.save()
	
	if not DirAccess.dir_exists_absolute(Tagger.tag_images_path + tag_path.get_basename()):
		DirAccess.make_dir_absolute(Tagger.tag_images_path + tag_path.get_basename())
	
	
	var _implication : ImplicationDictionary
	
	if not Tagger.tag_manager.relation_paths.has(_tag.tag.left(1)):
		_implication = ImplicationDictionary.create_implication(tag_name.left(1), tag_name.left(1))
	else:
		_implication = ResourceLoader.load("user://database/implications/" + tag_path.left(1) + ".tres")
	
	if not Tagger.tag_manager.relation_database.has(_implication.implication_index):
		Tagger.tag_manager.relation_database[_implication.implication_index] = {}

	_implication.tag_implications[tag_name] = "user://database/tags/" + tag_path
	Tagger.tag_manager.relation_database[tag_name.left(1)][tag_name] = "user://database/tags/" + tag_path
	Tagger.tag_manager.relation_paths[_implication.implication_index] = "user://database/implications/" + _implication.file_name
	_implication.save()
	
	return "user://database/tags/" + tag_path


static func build_all_implications(index_dict: Dictionary) -> void:
	var _filename: String = ""
	
	for character in index_dict.keys():
		_filename = character + ".tres"
		
		if not _filename.is_valid_filename():
			_filename = _filename.validate_filename()
		
		var _new_implication = ImplicationDictionary.new()
		_new_implication.file_name = _filename
		_new_implication.implication_index = character
		_new_implication.tag_implications = index_dict[character]
		_new_implication.save(true)
	

static func build_specific_implications(index_dict: Dictionary, override_string: String, override_filename: String) -> void:
	if not index_dict.has(override_string):
		return
		
	if not override_filename.ends_with(".tres"):
		override_filename += ".tres"
	
	var _new_implication := ImplicationDictionary.new()
	_new_implication.file_name = override_filename
	_new_implication.implication_index = override_string
	_new_implication.tag_implications = index_dict[override_string]
	_new_implication.save(true)

