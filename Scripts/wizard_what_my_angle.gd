extends Control


@onready var high_front: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/HighAngle/HighFront
@onready var highthrefour: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/HighAngle/Highthrefour
@onready var high_side: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/HighAngle/HighSide
@onready var high_back_three_four: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/HighAngle/HighBackThreeFour
@onready var high_back: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/HighAngle/HighBack
@onready var normal_front: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/RegularAngle/NormalFront
@onready var normalthrefour: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/RegularAngle/Normalthrefour
@onready var normal_side: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/RegularAngle/NormalSide
@onready var normal_back_three_four: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/RegularAngle/NormalBackThreeFour
@onready var normal_back: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/RegularAngle/NormalBack
@onready var low_front: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/LowAngle/LowFront
@onready var low_three_four: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/LowAngle/LowThreefour
@onready var low_side: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/LowAngle/LowSide
@onready var low_back_three_four: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/LowAngle/LowBackThreeFour
@onready var low_back: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/LowAngle/LowBack
@onready var worm: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/ExtremeAngles/Worm
@onready var bird: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/ExtremeAngles/Bird
@onready var accept_angle_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/AcceptAngleButton
@onready var cancel_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/CancelButton

@onready var worm_box: CheckBox = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/AbgleTyles/WormBox"
@onready var low_box: CheckBox = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/AbgleTyles/LowBox"
@onready var high_box: CheckBox = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/AbgleTyles/HighBox"
@onready var bird_box: CheckBox = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/AbgleTyles/BirdBox"
@onready var front_box: CheckBox = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/ViewTypes/FrontBox"
@onready var side_box: CheckBox = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/ViewTypes/SideBox"
@onready var three_fourths_box: CheckBox = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/ViewTypes/34Box"
@onready var rear_box: CheckBox = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/ViewTypes/RearBox"

@onready var multiple_angles = $"../MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles"

func _ready():
	hide()
	accept_angle_button.pressed.connect(on_accept_button_pressed)
	cancel_button.pressed.connect(on_cancel_button_pressed)

func clean_presses() -> void:
	high_front.set_pressed_no_signal(false)
	highthrefour.set_pressed_no_signal(false)
	high_side.set_pressed_no_signal(false)
	high_back_three_four.set_pressed_no_signal(false)
	high_back.set_pressed_no_signal(false)
	normal_front.set_pressed_no_signal(false)
	normalthrefour.set_pressed_no_signal(false)
	normal_side.set_pressed_no_signal(false)
	normal_back_three_four.set_pressed_no_signal(false)
	normal_back.set_pressed_no_signal(false)
	low_front.set_pressed_no_signal(false)
	low_three_four.set_pressed_no_signal(false)
	low_side.set_pressed_no_signal(false)
	low_back_three_four.set_pressed_no_signal(false)
	low_back.set_pressed_no_signal(false)
	worm.set_pressed_no_signal(false)
	bird.set_pressed_no_signal(false)


func on_accept_button_pressed() -> void:
	multiple_angles.deselect_all()
	if normal_front.button_pressed or high_front.button_pressed or low_front.button_pressed:
		front_box.button_pressed = true
		if high_front.button_pressed:
			high_box.button_pressed = true
		if low_front.button_pressed:
			low_box.button_pressed = true
	if highthrefour.button_pressed or normalthrefour.button_pressed or low_three_four.button_pressed:
		three_fourths_box.button_pressed = true
		if highthrefour.button_pressed:
			high_box.button_pressed = true
		if low_three_four.button_pressed:
			low_box.button_pressed = true
	if normal_side.button_pressed or low_side.button_pressed or high_side.button_pressed:
		side_box.button_pressed = true
		if high_side.button_pressed:
			high_box.button_pressed = true
		if low_side.button_pressed:
			low_box.button_pressed = true
	if normal_back_three_four.button_pressed or high_back_three_four.button_pressed or low_back_three_four.button_pressed:
		three_fourths_box.button_pressed = true
		rear_box.button_pressed = true
		if high_back_three_four.button_pressed:
			high_box.button_pressed = true
		if low_back_three_four.button_pressed:
			low_box.button_pressed = true
	if high_back.button_pressed or normal_back.button_pressed or low_back.button_pressed:
		rear_box.button_pressed = true
		if high_back.button_pressed:
			high_box.button_pressed = true
		if low_back.button_pressed:
			low_box.button_pressed = true
	if worm.button_pressed:
		worm_box.button_pressed = true
	if bird.button_pressed:
		bird_box.button_pressed = true
	clean_presses()
	hide()


func on_cancel_button_pressed() -> void:
	clean_presses()
	hide()
