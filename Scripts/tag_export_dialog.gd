class_name TagFileDialog
extends FileDialog


var tag_string: String = ""
var default_filename: String = ""
var default_path: String = ""


func _ready():
	current_path = Tagger.settings.default_save_path


func show_dialog() -> void:
	if not Tagger.settings.default_save_path.is_empty() and DirAccess.dir_exists_absolute(Tagger.settings.default_save_path):
		current_path = Tagger.settings.default_save_path
	current_file = default_filename
	show()


func file_saved(path: String) -> void:
	var test_file = FileAccess.open(path, FileAccess.WRITE)
	test_file.store_string(tag_string)
	test_file.close()
	
	default_path = path.get_base_dir() + "/"
	default_filename = path.get_file().get_basename()

