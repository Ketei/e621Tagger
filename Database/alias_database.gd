class_name AliasDatabase
extends Resource


@export var aliases: Dictionary = {}


static func load_database() -> AliasDatabase:
	if ResourceLoader.exists("user://database/aliases.tres", "AliasDatabase"):
		return ResourceLoader.load("user://database/aliases.tres", "AliasDatabase")
	else:
		return AliasDatabase.new()


func save() -> void:
	ResourceSaver.save(self, "user://database/aliases.tres")


func add_alias(old_name: String, new_name: String):
	aliases[old_name] = new_name


func has_alias(tag_name: String) -> bool:
	return aliases.has(tag_name)


func get_alias(tag_name: String) -> String:
	if aliases.has(tag_name):
		if aliases.has(aliases[tag_name]):
			return get_alias(aliases[tag_name])
		else:
			return aliases[tag_name]
	else:
		return tag_name


func get_alias_dictionary() -> Dictionary:
	var _return_dict: Dictionary = {}

	for correct in aliases.values():
		if not _return_dict.has(correct):
			_return_dict[correct] = []
	
	for old_name in aliases.keys():
		_return_dict[aliases[old_name]].append(old_name)
	
	return _return_dict
	
	
func remove_alias(alias_name: String) -> void:
	aliases.erase(alias_name)


func alias_exitst(old_name: String, new_name: String) -> bool:
	if not aliases.has(old_name):
		return false
	
	if aliases[old_name] != new_name:
		return false
	
	return true
	
	
