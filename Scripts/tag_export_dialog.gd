class_name TagFileDialog
extends FileDialog


var tag_string: String = ""
var default_filename: String = ""
var default_path: String = ""


func _ready():
	current_path = Tagger.settings.default_save_path


func show_dialog() -> void:
	if not default_path.is_empty() and DirAccess.dir_exists_absolute(default_path):
		current_path = default_path
	elif not Tagger.settings.default_save_path.is_empty() and DirAccess.dir_exists_absolute(Tagger.settings.default_save_path):
		current_path = Tagger.settings.default_save_path
	current_file = default_filename
	show()


func file_saved(path: String) -> void:
	var folder_path: String = path.get_base_dir()
	if not folder_path.ends_with("/"):
		folder_path += "/"
	var file_name: String = path.get_file().validate_filename()
	
	var test_file = FileAccess.open(folder_path + file_name, FileAccess.WRITE)
	if test_file != null:
		test_file.store_string(tag_string)
	else:
		print_debug("Couldn't create file. Error: " + str(FileAccess.get_open_error()))
	
	test_file.close()
	
	if default_path != folder_path:
		default_path = folder_path
	if default_filename != file_name:
		default_filename = file_name
	default_filename = file_name

