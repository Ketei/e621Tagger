class_name Tag
extends Resource


@export var tag: String = "":
	set(new_name):
		tag = new_name.to_lower()
@export var file_name: String = ""
@export var tag_priority: int = 0
@export var category: Tagger.Categories = Tagger.Categories.GENERAL
@export var parents: Array = []
@export var conflicts: Array[String] = []
@export var suggestions: Array[String] = []
@export var has_pictures: bool = true
@export var variants: Dictionary = {}

@export var wiki_entry: String = ""


func save() -> String:
	if file_name.is_empty():
		file_name = tag + ".tres"
		if not file_name.is_valid_filename():
			file_name = file_name.validate_filename()
	
	ResourceSaver.save(self, "user://database/tags/" + file_name)
	return file_name


func get_tag() -> String:
	if variants.has(str(Tagger.settings.target_site)):
		return variants[Tagger.settings.target_site]
	else:
		return tag

