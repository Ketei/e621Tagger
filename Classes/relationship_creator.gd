class_name TagMaker
extends Node

static func make_tag(tag_name: String, tag_parents: Array, tag_category: Tagger.Categories, tag_wiki_info: String = "", tag_prio: int = 0, tag_suggestions: Array[String] = [], has_images: bool = true, tag_conflicts: Array[String] = [], tag_tooltip: String = "", aliased_tags: Array = []) -> String:
	var _tag_dict: Dictionary = {}
	#aliases: Dictionary = {}
	var _tag := Tag.new()
	_tag.tag = tag_name
	_tag.category = tag_category
	_tag.parents = tag_parents
	_tag.wiki_entry = tag_wiki_info
	_tag.tag_priority = tag_prio
	_tag.suggestions = tag_suggestions.duplicate()
	_tag.has_pictures = has_images
	_tag.conflicts = tag_conflicts.duplicate()
	_tag.tooltip = tag_tooltip
	_tag.aliases = PackedStringArray(aliased_tags)
	var tag_path: String = _tag.save()
	
	if not DirAccess.dir_exists_absolute(Tagger.tag_images_path + tag_path.get_basename()):
		DirAccess.make_dir_absolute(Tagger.tag_images_path + tag_path.get_basename())
	
	
	var _implication : ImplicationDictionary
	
	if not Tagger.tag_manager.relation_paths.has(_tag.tag.left(1)):
		_implication = ImplicationDictionary.create_implication(tag_name.left(1), tag_name.left(1))
	else:
		_implication = ResourceLoader.load(Tagger.implications_path + tag_path.left(1) + ".tres")
	
	if not Tagger.tag_manager.relation_database.has(_implication.implication_index):
		Tagger.tag_manager.relation_database[_implication.implication_index] = {}

	_implication.tag_implications[tag_name] = Tagger.tags_path + tag_path
	Tagger.tag_manager.relation_database[tag_name.left(1)][tag_name] = Tagger.tags_path + tag_path
	Tagger.tag_manager.relation_paths[_implication.implication_index] = Tagger.implications_path + _implication.file_name
	_implication.save()
	
	return Tagger.tags_path + tag_path

