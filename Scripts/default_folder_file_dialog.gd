extends FileDialog

@onready var settings = $".."

func _ready():
	current_path = Tagger.settings.default_save_path


func folder_selected(folder_path: String) -> void:
	if folder_path.is_empty():
		return
	
	if not folder_path.ends_with("/"):
		folder_path += "/"
	
	if DirAccess.dir_exists_absolute(folder_path):
		settings.set_default_save_path(folder_path)
		Tagger.settings.default_save_path = folder_path

