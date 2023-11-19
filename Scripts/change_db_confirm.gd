extends Control


var new_database_path: String = ""

@onready var confirm_button: Button = $Warning/ChangeDBControl/VBoxContainer/HBoxContainer/ConfirmButton
@onready var cancel_button: Button = $Warning/ChangeDBControl/VBoxContainer/HBoxContainer/CancelButton
@onready var main_application = $"../.."


func _ready():
	confirm_button.pressed.connect(confirm_database_change)
	cancel_button.pressed.connect(cancel_database_change)


func confirm_database_change() -> void:
	if not new_database_path.ends_with("/"):
		new_database_path += "/"
	
	Tagger.settings.database_location = new_database_path
	
	main_application.quit_app()


func cancel_database_change() -> void:
	hide()

