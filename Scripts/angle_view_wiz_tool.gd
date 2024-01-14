extends HBoxContainer

var bird_view = preload("res://Textures/AngleHeads/bird.png")
var worm_view = preload("res://Textures/AngleHeads/worm.png")

var angle_textures: Dictionary = {
	"regular_view": {
		"front": [
			preload("res://Textures/AngleHeads/regular-front.png"),
			preload("res://Textures/AngleHeads/regular-34.png")
		],
		"back": [
			preload("res://Textures/AngleHeads/regular-back.png"),
			preload("res://Textures/AngleHeads/regular-back-34.png")
			],
		"side": [preload("res://Textures/AngleHeads/regular-side.png")]
		
	},
	"high-angle": {
		"front": [
			preload("res://Textures/AngleHeads/up-front.png"),
			preload("res://Textures/AngleHeads/up-34.png")
		],
		"back": [
			preload("res://Textures/AngleHeads/up-back.png"),
			preload("res://Textures/AngleHeads/up-back-34.png")
			],
		"side": [preload("res://Textures/AngleHeads/up-side.png")]
	},
	"low-angle": {
		"front": [
			preload("res://Textures/AngleHeads/low-fromt.png"),
			preload("res://Textures/AngleHeads/low-34.png")
		],
		"back": [
			preload("res://Textures/AngleHeads/low-back.png"),
			preload("res://Textures/AngleHeads/low-back-34.png")
			],
		"side": [preload("res://Textures/AngleHeads/low-side.png")]
	},
	"bird": {
		"front": [
			bird_view,
			bird_view
		],
		"back": [
			bird_view,
			bird_view
			],
		"side": [bird_view]
	},
	"worm": {
		"front": [
			worm_view,
			worm_view
		],
		"back": [
			worm_view,
			worm_view
			],
		"side": [worm_view]
	}
}

var current_texture_dict: Dictionary = {}

@onready var height_view: OptionButton = $HeigthView
@onready var angle_view_option_button: OptionButton = $AngleViewOptionButton
@onready var texture_rect: TextureRect = $TextureRect
@onready var rear_view_check_button: CheckButton = $VBoxContainer/RearViewCheckButton
@onready var multiple_angles = $MultipleAngles


func _ready():
	height_view.item_selected.connect(height_selected)
	angle_view_option_button.item_selected.connect(update_angle)
	rear_view_check_button.toggled.connect(rear_toggled)


func height_selected(item_index: int) -> void:
	var box_id: int = height_view.get_item_id(item_index)
	
	if box_id != 6 and multiple_angles.visible:
		multiple_angles.visible = false
		texture_rect.show()
		angle_view_option_button.show()
		rear_view_check_button.show()
	
	if box_id == 0:
		current_texture_dict = angle_textures["regular_view"]
	elif box_id == 1:
		current_texture_dict = angle_textures["worm"]
	elif box_id == 2:
		current_texture_dict = angle_textures["low-angle"]
	elif box_id == 3:
		current_texture_dict = angle_textures["high-angle"]
	elif box_id == 4:
		current_texture_dict = angle_textures["bird"]
	elif box_id == 5:
		texture_rect.texture = angle_textures["regular_view"]["front"][0]
	elif  box_id == 6:
		if not multiple_angles.visible:
			multiple_angles.show()
			texture_rect.hide()
			angle_view_option_button.hide()
			rear_view_check_button.hide()
	
	if box_id != 5 and box_id != 6:
		update_angle()


func rear_toggled(_is_toggled: bool) -> void:
	update_angle()


func update_angle(_index_select: int = 0) -> void:
	if height_view.get_selected_id() == 5 or height_view.get_selected_id() == 6:
		return
	
	var angle_id = angle_view_option_button.get_selected_id()
	
	if angle_id == 1: # Front
		if rear_view_check_button.button_pressed:
			texture_rect.texture = current_texture_dict["back"][0]
		else:
			texture_rect.texture = current_texture_dict["front"][0]
	elif angle_id == 2: #3/4
		if rear_view_check_button.button_pressed:
			texture_rect.texture = current_texture_dict["back"][1]
		else:
			texture_rect.texture = current_texture_dict["front"][1]
	elif angle_id == 3: #side:
		texture_rect.texture = current_texture_dict["side"][0]


func clean_pls():
	height_view.select(0)
	angle_view_option_button.select(0)
	rear_view_check_button.set_pressed_no_signal(false)
	texture_rect.texture = angle_textures["regular_view"]["front"][0]
	multiple_angles.deselect_all()
	if not texture_rect.visible:
		multiple_angles.hide()
		texture_rect.show()
		angle_view_option_button.show()


func on_menu_changed() -> void:
	pass
