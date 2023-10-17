class_name LewdTextureRect
extends TextureRect

signal lewd_pic_pressed(image_texture)

@onready var button = $Button

func _ready():
	button.pressed.connect(button_pressed)


func button_pressed() -> void:
	print("Button Pressed!!!")
	lewd_pic_pressed.emit(self.texture)
