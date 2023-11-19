extends FileDialog


@onready var warning_rect = $"../WarningRect"


func folder_selected(directory_selected: String) -> void:
	warning_rect.new_database_path = directory_selected
	warning_rect.show()

