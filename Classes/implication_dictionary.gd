class_name ImplicationDictionary
extends Resource

## The first letter that the tags have
@export var implication_index: String = ""
## The tag name and it's path
@export var tag_implications: Dictionary = {}
## The name of this file. Be sure it's a valid name AND it ends in ".tres"
@export var file_name: String = ""


func has_implication(tag_name: String) -> bool:
	return tag_implications.has(tag_name)


func get_resource(tag_name: String) -> Tag:
	if ResourceLoader.exists(tag_implications[tag_name], "Tag"):
		return ResourceLoader.load(tag_implications[tag_name], "Tag")
	else:
		return null


static func create_implication(implication_filename: String, index_string: String) -> ImplicationDictionary:
	var _implication = ImplicationDictionary.new()
	var _filename: String = implication_filename
	
	if not _filename.ends_with(".tres"):
		_filename += ".tres"
	
	if not _filename.is_valid_filename():
		_filename = _filename.validate_filename()
	
	_implication.file_name = _filename
	_implication.implication_index = index_string
	
	return _implication
	

func save(save_to_local: bool = false) -> void:
	if not save_to_local:
		ResourceSaver.save(self, Tagger.implications_path + file_name)
	else:
		ResourceSaver.save(self, Tagger.implications_path + file_name)


func save_with_path(path_name: String) -> void:
	ResourceSaver.save(self, path_name)
