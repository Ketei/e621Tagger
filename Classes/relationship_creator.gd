class_name TagMaker
extends Node

static func make_tag(tag_name: String, tag_parents: Array, tag_category: Tagger.Categories, tag_wiki_info: String = "", tag_prio: int = 0, tag_suggestions: Array[String] = [], has_images: bool = true, tag_conflicts: Array[String] = [], tag_tooltip: String = "", aliased_tags: Array = [], pr_cat: String = "", pr_cat_img: String = "", pr_cat_desc: String = "", pr_sub_cat := "", pr_sub_cat_img := "", pr_sub_cat_desc := "", pr_title := "", pr_desc := "", has_prompt_data := false, tag_group_entry: Dictionary = {}) -> String:
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
	_tag.prompt_category = pr_cat
	_tag.prompt_category_img_tag = pr_cat_img
	_tag.prompt_category_desc = pr_cat_desc
	_tag.prompt_subcat = pr_sub_cat
	_tag.prompt_subcat_img_tag = pr_sub_cat_img
	_tag.prompt_subcat_desc = pr_sub_cat_desc
	_tag.prompt_title = pr_title
	_tag.prompt_desc = pr_desc
	_tag.has_prompt_data = has_prompt_data
	_tag.tag_groups = tag_group_entry.duplicate()
	var tag_path: String = _tag.save()
	
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

