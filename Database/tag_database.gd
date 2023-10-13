class_name TagDatabase
extends Node

@export var data_dict: Dictionary = {}


static func load_database() -> TagDatabase:
	#if ResourceLoader.exists("user://database/tag_database.tres", "TagDatabase"):
	#	return ResourceLoader.load("user://database/tag_database.tres")
	
	var _new_database: TagDatabase = TagDatabase.new()
	
	# ---------- Loading the default tags ----------
	var _file_list: PackedStringArray = DirAccess.get_files_at("res://Database/tags/")
	
	for base_tag in _file_list:
		var _new_res: Tag = ResourceLoader.load("res://Database/tags/" + base_tag, "Tag")
		if not _new_res:
			continue
		_new_database.register_tag(_new_res)
	# -----------------------------------------------
	
	# ----------- Loading external tags -------------
	_file_list = DirAccess.get_files_at("user://database/tags")

	for tag_name in _file_list:
		var tag_resource: Tag = ResourceLoader.load("user://database/tags/" + tag_name)
		if not tag_resource:
			continue
		
		_new_database.register_tag(tag_resource)
	# -----------------------------------------------
	
	return _new_database


func register_tag(tag_to_register: Tag) -> void:
	if not data_dict.has(tag_to_register.tag.left(1)):
		data_dict[tag_to_register.tag.left(1)] = {}
	
	data_dict[tag_to_register.tag.left(1)][tag_to_register.tag] = tag_to_register


func has_tag(tag_name: String) -> bool:
	return data_dict.has(tag_name.left(1)) and data_dict[tag_name.left(1)].has(tag_name)


func load_tag(tag_name: String) -> void:
	if not ResourceLoader.exists("user://database/tags/" + tag_name + ".tres", "Tag"):
		return
	
	var _tag_object: Tag = ResourceLoader.load("user://database/tags/" + tag_name + ".tres")
	
	if not data_dict.has(_tag_object.tag.left(1).to_lower()):
		data_dict[_tag_object.tag.left(1).to_lower()] = {}
	
	data_dict[_tag_object.tag.left(1).to_lower()][_tag_object.tag] = _tag_object


func get_tag(tag_name: String) -> Tag:
	tag_name = tag_name.to_lower()
	return data_dict[tag_name.left(1)][tag_name]


func mass_update_tags(tag_parent: String, tag_children: Array[String]) -> void:
	var _new_tag: Tag
	
	if not has_tag(tag_parent):
		_new_tag = Tag.new()
		_new_tag.tag = tag_parent
		_new_tag.save()
	
	for child in tag_children:
		if has_tag(child):
			if not get_tag(child).parents.has(child):
				get_tag(child).parents.append(tag_parent)
		else:
			_new_tag = Tag.new()
			_new_tag.tag = child
			_new_tag.parents.append(tag_parent)
			_new_tag.save()

