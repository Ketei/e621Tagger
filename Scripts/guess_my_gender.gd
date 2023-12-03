extends Control

@onready var penis_check_box: CheckBox = $VBoxContainer/Genitals/HBoxContainer/PenisCheckBox
@onready var vagina_check_box: CheckBox = $VBoxContainer/Genitals/HBoxContainer/VaginaCheckBox
@onready var masc_check_box: CheckBox = $VBoxContainer/BodyTypes/BodyTypesChecks/MascCheckBox
@onready var fem_check_box: CheckBox = $VBoxContainer/BodyTypes/BodyTypesChecks/FemCheckBox
@onready var breasts_check_box: CheckBox = $VBoxContainer/OtherFeatures/HBoxContainer/BreastsCheckBox
@onready var cancel_button: Button = $VBoxContainer/HBoxContainer/CancelButton
@onready var submit_button: Button = $VBoxContainer/HBoxContainer/SubmitButton
@onready var gender_result_label: Label = $VBoxContainer/GenderResult/GenderResult
@onready var dim_lights: ColorRect = $"../DimLights"


func _ready():
	hide()
	dim_lights.hide()
	submit_button.pressed.connect(calculate_gender)
	cancel_button.pressed.connect(on_close_button)


func clear_fields() -> void:
	gender_result_label.text = ""
	penis_check_box.button_pressed = false
	vagina_check_box.button_pressed = false
	masc_check_box.button_pressed = false
	fem_check_box.button_pressed = false
	breasts_check_box.button_pressed = false


func calculate_gender() -> void:
	var gender_result: String = "I have NO idea! (Pls report)"
	if penis_check_box.button_pressed and not vagina_check_box.button_pressed:
		if breasts_check_box.button_pressed:
			gender_result = "Gynomorph"
		else:
			gender_result = "Male"
	elif not penis_check_box.button_pressed and vagina_check_box.button_pressed:
		if breasts_check_box.button_pressed:
			gender_result = "Female"
		else:
			if masc_check_box.button_pressed:
				gender_result = "Andromorph"
			else:
				gender_result = "Female"
	elif penis_check_box.button_pressed and vagina_check_box.button_pressed:
		if breasts_check_box.button_pressed:
			gender_result = "Herm"
		else:
			if masc_check_box.button_pressed:
				gender_result = "Maleherm"
			else:
				gender_result = "Herm"
	else:
		if breasts_check_box.button_pressed:
			gender_result = "Female"
		else:
			if masc_check_box.button_pressed and not fem_check_box.button_pressed:
				gender_result = "Male"
			elif fem_check_box.button_pressed and not masc_check_box.button_pressed:
				gender_result = "Female"
			else:
				gender_result = "Ambiguous gender"
	gender_result_label.text = gender_result


func on_close_button() -> void:
	hide()
	dim_lights.hide()

