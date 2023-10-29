class_name LewdTextureRect
extends TextureRect

signal lewd_pic_pressed(image_texture)

@onready var button = $Button

func _ready():
	button.pressed.connect(button_pressed)


func button_pressed() -> void:
	lewd_pic_pressed.emit(self.texture)


func pause_texture(is_paused: bool) -> void:
	if texture is AnimatedTexture:
		if texture.pause != is_paused:
			texture.pause = is_paused
