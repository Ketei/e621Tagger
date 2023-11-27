extends Control

@export var aliases_vbox: VBoxContainer

@onready var strength_slider = $SettingsContainer/SettingsSets/SuggestionStrength/HSlider
@onready var recreate_database_btn = $SettingsContainer/SettingsSets/UtilityButtons/RecreateDatabaseBtn
@onready var str_percentage_spinbox: SpinBox = $SettingsContainer/SettingsSets/SuggestionStrength/PercentageSpinBox

@onready var open_tags_button = $SettingsContainer/SettingsSets/UtilityButtons/OpenTagsButton
@onready var settings_bar: PopupMenu = $"../MenuBar/API"
@onready var save_path_line_edit: LineEdit = $SettingsContainer/SettingsSets/DefaultPathContainer/SavePathLineEdit
@onready var default_folder_file_dialog = $DefaultFolderFileDialog

@onready var select_folder_button: Button = $SettingsContainer/SettingsSets/DefaultPathContainer/SelectFolderButton
@onready var api_loader = $APILoader

@onready var database_path_line_edit: LineEdit = $SettingsContainer/SettingsSets/DatabaseLocation/DatabasePathLineEdit
@onready var select_db_path_button: Button = $SettingsContainer/SettingsSets/DatabaseLocation/SelectDBPathButton

@onready var database_location_file_dialog: FileDialog = $DatabaseLocationFileDialog


func _ready():
	hide()
	
	select_db_path_button.pressed.connect(database_location_file_dialog.show)
	database_path_line_edit.text = Tagger.settings.database_location
	
	select_folder_button.pressed.connect(show_folder_dialog)
	save_path_line_edit.text = Tagger.settings.default_save_path
		
	settings_bar.id_pressed.connect(settings_menu_press)
	
	open_tags_button.pressed.connect(open_tags_folder)
	strength_slider.value = Tagger.settings.suggestion_strength
	str_percentage_spinbox.value = Tagger.settings.suggestion_strength
	recreate_database_btn.pressed.connect(__recreate_database)


func settings_menu_press(button_id: int) -> void:
	if button_id == 0:
		api_loader.show()


func open_api_screen() -> void:
	api_loader.visible = true


func open_tags_folder() -> void:
	OS.shell_open(ProjectSettings.globalize_path(Tagger.tags_path))


func __recreate_database() -> void:
	recreate_database_btn.disabled = true
	recreate_database_btn.text = "Please wait"
	await get_tree().create_timer(1).timeout
	Tagger.tag_manager.recreate_implications()
	recreate_database_btn.text = "Done!"
	await get_tree().create_timer(2).timeout
	recreate_database_btn.disabled = false
	recreate_database_btn.text = "Recreate tag registry"


func set_default_save_path(new_path: String) -> void:
	save_path_line_edit.text = new_path


func show_folder_dialog() -> void:
	default_folder_file_dialog.show()


func register_alias(old_name: String, new_name: String) -> void:
	aliases_vbox.add_alias(old_name, new_name, true)

