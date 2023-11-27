class_name TaglistResource
extends Resource

@export var template_name: String = ""
@export var template_tags := PackedStringArray()
@export var template_suggestions := PackedStringArray()


func save() -> void:
	var filename: String = template_name
	
	if not filename.ends_with(".tres"):
		filename += ".tres"
	
	if not filename.is_valid_filename():
		filename = template_name.validate_filename()
	
	ResourceSaver.save(self, Tagger.templates_path + filename)
