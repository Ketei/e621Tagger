class_name AliasDatabase
extends Resource


@export var aliases: Dictionary = {}


static func load_database(database_path: String) -> AliasDatabase:
	if ResourceLoader.exists(database_path + "aliases.tres", "AliasDatabase"):
		return ResourceLoader.load(database_path + "aliases.tres", "AliasDatabase")
	else:
		return AliasDatabase.new()


func save() -> void:
	ResourceSaver.save(self, Tagger.settings.database_location + "aliases.tres")


func add_alias(old_name: String, new_name: String):
	aliases[old_name] = new_name


func has_alias(tag_name: String) -> bool:
	return aliases.has(tag_name)


func get_alias(tag_name: String, _starting_tag: String = "") -> String:
	if _starting_tag.is_empty():
		_starting_tag = tag_name
	
	if aliases.has(tag_name):
		if aliases.has(aliases[tag_name]):
			if aliases[tag_name] == _starting_tag:
				return tag_name
			else:
				return get_alias(aliases[tag_name], _starting_tag)
		else:
			return aliases[tag_name]
	else:
		return tag_name


func get_alias_dictionary() -> Dictionary:
	var _return_dict: Dictionary = {}

	for correct in aliases.values():
		if not _return_dict.has(correct):
			_return_dict[correct] = []
	var sorted_aliases: Array = aliases.keys()
	
	sorted_aliases.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	for old_name in sorted_aliases:
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
	
	
