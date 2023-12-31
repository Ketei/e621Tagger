extends CenterContainer

@onready var hydrus_api_request: HydrusRequestAPI = $"../../HydrusAPIRequest"
@onready var port_box: SpinBox = $Hydrus/MarginContainer/VBoxContainer/Port/PortBox
@onready var key_line: LineEdit = $Hydrus/MarginContainer/VBoxContainer/Key/KeyLine

@onready var cancel_button: Button = $Hydrus/MarginContainer/VBoxContainer/Buttons/CancelButton
@onready var test_button: Button = $Hydrus/MarginContainer/VBoxContainer/Buttons/TestButton

@onready var error_label: Label = $Hydrus/MarginContainer/VBoxContainer/Notifications/ErrorLabel
@onready var remember_check: CheckBox = $Hydrus/MarginContainer/VBoxContainer/Buttons/RememberCheck
@onready var on_load_check: CheckBox = $Hydrus/MarginContainer/VBoxContainer/Buttons/OnLoadCheck
@onready var success_icon: TextureRect = $Hydrus/MarginContainer/VBoxContainer/Header/TextureRect



func _ready():
	hide()
	on_load_check.button_pressed = Tagger.settings.hydrus_connect_on_load
	cancel_button.pressed.connect(hide)
	test_button.pressed.connect(test_login)
	port_box.value = Tagger.settings.hydrus_port
	key_line.text = Tagger.settings.hydrus_key
	remember_check.button_pressed = Tagger.settings.hydrus_remember_data
	on_load_check.toggled.connect(on_load_button_pressed)
	remember_check.toggled.connect(on_remember_check_toggle)
	if on_load_check.button_pressed and remember_check.button_pressed:
		test_login()


func on_remember_check_toggle(is_toggled: bool) -> void:
	Tagger.settings.hydrus_remember_data = is_toggled


func on_load_button_pressed(is_toggled: bool) -> void:
	Tagger.settings.hydrus_connect_on_load = is_toggled


func test_login() -> void:
	@warning_ignore("narrowing_conversion")
	hydrus_api_request.set_data(port_box.value, key_line.text, false)
	test_button.disabled = true
	display_error("Please wait...")
	var is_logged_in: bool = await hydrus_api_request.verify_access_key()
	if is_logged_in:
		test_button.pressed.disconnect(test_login)
		test_button.pressed.connect(disconnect_api)
		success_icon.texture = load("res://Textures/CheckMark.svg")
		success_icon.self_modulate = Color8(120, 160, 95)
		if remember_check.button_pressed:
			Tagger.settings.hydrus_port = int(port_box.value)
			Tagger.settings.hydrus_key = key_line.text
			Tagger.settings.hydrus_remember_data = true
		else:
			Tagger.settings.hydrus_port = 0
			Tagger.settings.hydrus_key = ""
			Tagger.settings.hydrus_remember_data = false
		test_button.text = "Disconnect from Hydrus"
		display_error("Successfully connected to Hydrus")
	else:
		display_error("Couldn't connect to Hydrus")
		success_icon.texture = load("res://Textures/Cross.svg")
		success_icon.self_modulate = Color8(190, 60, 75)
	test_button.disabled = false


func disconnect_api() -> void:
	hydrus_api_request.reset_connection()
	test_button.pressed.disconnect(disconnect_api)
	test_button.pressed.connect(test_login)
	test_button.text = "Connect to Hydrus"


func display_error(error_text: String) -> void:
	error_label.text = error_text

