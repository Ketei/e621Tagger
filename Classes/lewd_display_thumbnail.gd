class_name LewdTextureRect
extends TextureRect

signal lewd_pic_pressed(image_texture)


func _ready():
	gui_input.connect(gui_input_received)


func gui_input_received(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		lewd_pic_pressed.emit(self.texture)


func pause_texture(is_paused: bool) -> void:
	if texture is AnimatedTexture:
		if texture.pause != is_paused:
			texture.pause = is_paused

