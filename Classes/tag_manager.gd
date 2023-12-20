class_name TagManager
extends Resource


@export var relation_database: Dictionary = {}

@export var relation_paths: Dictionary = {}


static func load_database(implications_path: String) -> TagManager:
	var _relation_return: TagManager = TagManager.new()
	
	for external_resource in DirAccess.get_files_at(implications_path):
		if external_resource.get_extension() != "tres":
			continue
		
		var _resource: ImplicationDictionary = ResourceLoader.load(implications_path + external_resource, "ImplicationDictionary")
		
		if _resource:
			_relation_return.relation_database[_resource.implication_index] = _resource.tag_implications
			_relation_return.relation_paths[_resource.implication_index] = implications_path + external_resource
	
	return _relation_return


func get_all_tags() -> Array:
	var return_array: Array = []
	
	for index_char in relation_database:
		return_array.append_array(relation_database[index_char].keys())
	
	return return_array


func get_all_tags_with_paths() -> Dictionary:
	var dict_to_return: Dictionary = {}
	
	for index_char in relation_database:
		dict_to_return.merge(relation_database[index_char])
	
	return dict_to_return
	

func has_tag(tag_implication: String) -> bool:
	if relation_database.has(tag_implication.left(1)) and relation_database[tag_implication.left(1)].has(tag_implication):
		if ResourceLoader.exists(relation_database[tag_implication.left(1)][tag_implication], "Tag"):
			return true
		else:
			var _relation_to_tweak: ImplicationDictionary = ResourceLoader.load(relation_paths[tag_implication.left(1)])
			_relation_to_tweak.tag_implications.erase(tag_implication)
			_relation_to_tweak.save()
	return false
	

func get_tag(tag_name: String) -> Tag:
	if ResourceLoader.exists(relation_database[tag_name.left(1)][tag_name], "Tag"):
		return ResourceLoader.load(relation_database[tag_name.left(1)][tag_name])
	else:
		return null


func recreate_implications() -> void:
	var sorted_files = {}
	
	for tag in DirAccess.get_files_at(Tagger.tags_path):
		
		var tag_file: Tag = ResourceLoader.load(Tagger.tags_path + tag, "Tag")
		
		if tag_file:
			if tag_file.file_name != tag:
				tag_file.file_name = tag
				tag_file.save()
			
			if not sorted_files.has(tag.left(1).to_lower()):
				sorted_files[tag.left(1).to_lower()] = []
			
			sorted_files[tag.left(1).to_lower()].append(tag)
		
	for chara in sorted_files.keys():
		var _implication: ImplicationDictionary = null
		
		if relation_paths.has(chara):
			_implication = ResourceLoader.load(relation_paths[chara])
			_implication.tag_implications.clear()
		else:
			var imp_file: String = chara + ".tres"
			if not imp_file.is_valid_filename():
				imp_file = str(randi_range(0, 9999)) + "_" + imp_file.validate_filename()
			_implication = ImplicationDictionary.create_implication(imp_file, chara)

		for tag_filename in sorted_files[chara]:
			if tag_filename.get_extension() != "tres":
				continue
			
			var _tag_exists: bool = ResourceLoader.exists(Tagger.tags_path + tag_filename, "Tag")
			
			if _tag_exists:
				var _valid_tag: Tag = ResourceLoader.load(Tagger.tags_path + tag_filename)
				_implication.tag_implications[_valid_tag.tag] = Tagger.tags_path + tag_filename
				
				if not relation_database.has(chara):
					relation_database[chara] = {}
				
				relation_database[chara][_valid_tag.tag] = Tagger.tags_path + tag_filename
				
				for alias in _valid_tag.aliases:
					Tagger.register_aliases.emit(alias, _valid_tag.tag)
				
				# ---------- Register prompts here -----------------
				if _valid_tag.has_prompt_data:
					Tagger.prompt_resources.register_category(_valid_tag.prompt_category, _valid_tag.prompt_category_desc, _valid_tag.prompt_category_img_tag)
					Tagger.prompt_resources.register_subcategory(_valid_tag.prompt_category, _valid_tag.prompt_subcat, _valid_tag.prompt_subcat_desc, _valid_tag.prompt_subcat_img_tag)
					Tagger.prompt_resources.register_title(_valid_tag.prompt_category, _valid_tag.prompt_subcat, _valid_tag.prompt_title, _valid_tag.tag, _valid_tag.prompt_desc)
				
				var valid_tag_groups: Dictionary = _valid_tag.get_tag_groups()
				
				for tag_group in valid_tag_groups.keys():
					if not Tagger.settings_lists.tag_types.has(tag_group):
						Tagger.settings_lists.tag_types[tag_group] = {"sort": valid_tag_groups[tag_group]["sort"], "tags": []}
					
					for group_entry in valid_tag_groups[tag_group]["tags"]:
						if not Tagger.settings_lists.tag_types[tag_group]["tags"].has(group_entry):
							Tagger.settings_lists.tag_types[tag_group]["tags"].append(group_entry)

		relation_paths[chara] = Tagger.implications_path + _implication.file_name
		Tagger.settings_lists.save()
		_implication.save()
	
	for tag_group in Tagger.settings_lists.tag_types.keys():
		if Tagger.settings_lists.tag_types[tag_group]["sort"]:
			Tagger.settings_lists.tag_types[tag_group].sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	Tagger.reload_tag_groups.emit()
	Tagger.implication_reload()


func get_implication(implication_key: String) -> ImplicationDictionary:
	if not relation_database.has(implication_key):
		return null
	
	return ResourceLoader.load(relation_paths[implication_key])
	

func search_with_prefix(prefix_search: String) -> Dictionary:
	prefix_search = prefix_search.strip_edges().to_lower()
	
	var return_dictionary: Dictionary = {}
	
	if prefix_search.is_empty() or not relation_database.has(prefix_search.left(1)):
		return return_dictionary
	
	var tags_array: Array = relation_database[prefix_search.left(1)].keys()
	
	for tag in tags_array:
		if tag.begins_with(prefix_search):
			var tag_load: Tag = get_tag(tag)
			return_dictionary[tag_load.tag] = {
				"id": -1,
				"priority": tag_load.tag_priority,
				"parents": PackedStringArray(tag_load.parents.duplicate()),
				"conflicts": PackedStringArray(tag_load.conflicts.duplicate()),
				"post_count": -1,
				"related_tags": PackedStringArray(),
				"suggested_tags": PackedStringArray(tag_load.suggestions.duplicate()),
				"category": tag_load.category,
				"is_locked": false,
				"is_registered": true
			}
	
	return return_dictionary


func get_n_tags_prefix(prefix_search: String, amount: int) -> PackedStringArray:
	prefix_search = prefix_search.strip_edges().to_lower()
	amount = maxi(amount, 0)
	
	var return_array := PackedStringArray()
	
	if not relation_database.has(prefix_search.left(1)):
		return return_array
	
	var tags_counter: int = 0
	
	for tag_result in relation_database[prefix_search.left(1)].keys():
		if tag_result.begins_with(prefix_search):
			return_array.append(tag_result)
			tags_counter += 1
			if amount <= tags_counter:
				break
	
	return return_array


func search_with_suffix(suffix_search: String) -> Dictionary:
	suffix_search = suffix_search.replace(" ", "_").strip_edges().to_lower()
	var valid_tags: Array = []
	var return_dict: Dictionary = {}
	
	for tag in get_all_tags():
		if tag.ends_with(suffix_search):
			valid_tags.append(tag)
	
	for tag in valid_tags:
		var tag_loader: Tag = get_tag(tag)
		return_dict[tag_loader.tag] = {
				"id": -1,
				"priority": tag_loader.tag_priority,
				"parents": PackedStringArray(tag_loader.parents.duplicate()),
				"conflicts": PackedStringArray(tag_loader.conflicts.duplicate()),
				"post_count": -1,
				"related_tags": PackedStringArray(),
				"suggested_tags": PackedStringArray(tag_loader.suggestions.duplicate()),
				"category": tag_loader.category,
				"is_locked": false,
				"is_registered": true
			}

	return return_dict
	

func search_for_content(contain_search: String) -> Dictionary:
	contain_search = contain_search.replace("_", " ").strip_edges().to_lower()
	var valid_tags: Array = []
	var return_dictionary: Dictionary = {}
		
	for tag in get_all_tags():
		if tag.contains(contain_search):
			valid_tags.append(tag)
	
	for tag in valid_tags:
		
		var tag_loader: Tag = get_tag(tag)
		
		return_dictionary[tag] = {
				"id": -1,
				"priority": tag_loader.tag_priority,
				"parents": PackedStringArray(tag_loader.parents.duplicate()),
				"conflicts": PackedStringArray(tag_loader.conflicts.duplicate()),
				"post_count": -1,
				"related_tags": PackedStringArray(),
				"suggested_tags": PackedStringArray(tag_loader.suggestions.duplicate()),
				"category": tag_loader.category,
				"is_locked": false,
				"is_registered": true
			}
	
#	return_array.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	return return_dictionary


func get_tag_type(tag_name: String) -> Tagger.Categories:
	if has_tag(tag_name):
		return get_tag(tag_name).category
	else:
		return Tagger.Categories.GENERAL



