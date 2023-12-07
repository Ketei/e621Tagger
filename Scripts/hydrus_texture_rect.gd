class_name HydrusTextureRect
extends TextureRect


signal thumbnail_pressed(picture_id)

var picture_id: int = 0


func _ready():
	gui_input.connect(gui_input_received)


func gui_input_received(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		thumbnail_pressed.emit(picture_id)


func pause_texture(is_paused: bool) -> void:
	if texture is AnimatedTexture:
		if texture.pause != is_paused:
			texture.pause = is_paused

