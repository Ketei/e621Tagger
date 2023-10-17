class_name TagManager
extends Node


var relation_database: Dictionary = {}

var relation_paths: Dictionary = {}


static func load_database() -> TagManager:
	var _relation_return: TagManager = TagManager.new()
	
	for local_resource in DirAccess.get_files_at("res://database/implications/"):
		var _res_load: ImplicationDictionary = ResourceLoader.load("res://database/implications/" + local_resource)
		if _res_load:
			_relation_return.relation_database[_res_load.implication_index] = _res_load.tag_implications
			_relation_return.relation_paths[_res_load.implication_index] = "res://Database/implications/" + local_resource


	for external_resource in DirAccess.get_files_at(Tagger.implications_path):
		if external_resource.get_extension() != "tres":
			continue
		
		var _resource: ImplicationDictionary = ResourceLoader.load(Tagger.implications_path + external_resource, "ImplicationDictionary")
		if _resource:
			_relation_return.relation_database[_resource.implication_index] = _resource.tag_implications
			_relation_return.relation_paths[_resource.implication_index] = Tagger.implications_path + external_resource
	
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
	return relation_database.has(tag_implication.left(1)) and relation_database[tag_implication.left(1)].has(tag_implication)


func get_tag(tag_name: String) -> Tag:
	if ResourceLoader.exists(relation_database[tag_name.left(1)][tag_name], "Tag"):
		return ResourceLoader.load(relation_database[tag_name.left(1)][tag_name])
	else:
		return null


func recreate_implications() -> void:
	var sorted_files = {}
	
	for tag in DirAccess.get_files_at(Tagger.tags_path):
		
		if not sorted_files.has(tag.left(1).to_lower()):
			sorted_files[tag.left(1).to_lower()] = []
		
		sorted_files[tag.left(1).to_lower()].append(tag)
		
		
	for chara in sorted_files.keys():
		var _implication: ImplicationDictionary
		
		if relation_paths.has(chara):
			_implication = ResourceLoader.load(relation_paths[chara])
		else:
			var imp_file: String = chara + ".tres"
			if not imp_file.is_valid_filename():
				imp_file = str(randi_range(0, 9999)) + "_" + imp_file.validate_filename()
			_implication = ImplicationDictionary.create_implication(imp_file, chara)
		
		for tag_filename in sorted_files[chara]:
			if tag_filename.get_extension() != "tres":
				continue
			
			if not DirAccess.dir_exists_absolute(Tagger.tag_images_path + tag_filename.get_basename()):
				DirAccess.make_dir_absolute(Tagger.tag_images_path + tag_filename.get_basename())
			
			var _valid_tag: Tag = ResourceLoader.load(Tagger.tags_path + tag_filename)
			
			if _valid_tag:
				_implication.tag_implications[_valid_tag.tag] = Tagger.tags_path + tag_filename
				
				if not relation_database.has(chara):
					relation_database[chara] = {}
				
				relation_database[chara][_valid_tag.tag] = Tagger.tags_path + tag_filename
		
		relation_paths[chara] = Tagger.implications_path + _implication.file_name
		_implication.save()
		

func get_implication(implication_key: String) -> ImplicationDictionary:
	if not relation_database.has(implication_key):
		return null
	
	return ResourceLoader.load(relation_paths[implication_key])
	

func search_with_prefix(prefix_search: String) -> Array[String]:
	prefix_search = prefix_search.strip_edges().to_lower()
	
	var return_array: Array[String] = []
	
	if prefix_search.is_empty() or not relation_database.has(prefix_search.left(1)):
		return return_array
	
	var tags_array: Array = relation_database[prefix_search.left(1)].keys()
	
	for tag in tags_array:
		if tag.begins_with(prefix_search):
			return_array.append(tag)
	
	return_array.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	return return_array


func search_with_suffix(suffix_search: String) -> Array[String]:
	suffix_search = suffix_search.strip_edges().to_lower()
	var all_tag_list: Array = []
	var return_array: Array[String] = []
	
	for key_char in relation_database.keys():
		all_tag_list.append_array(relation_database[key_char].keys())
	
	for tag in all_tag_list:
		if tag.ends_with(suffix_search):
			return_array.append(tag)
	
	return_array.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	return return_array
	

func search_for_content(contain_search: String) -> Array[String]:
	contain_search = contain_search.strip_edges().to_lower()
#	print("Tag to search for: " + contain_search)
	var all_tag_list: Array = []
	var return_array: Array[String] = []
	
	for keychar in relation_database.keys():
		all_tag_list.append_array(relation_database[keychar].keys())
	
#	print("Searching in: " + str(all_tag_list))
	
	for tag in all_tag_list:
#		print("Comparing \"" + tag + "\" with: " + contain_search)
		if tag.contains(contain_search):
			return_array.append(tag)
	
	return_array.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	return return_array
	
	
