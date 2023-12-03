class_name FullScreenDisplay
extends Control

signal display_hidden

@onready var lewd_texture: TextureRect = $ScrollContainer/LewdTexture


func _ready():
	lewd_texture.hide_lewd_image.connect(hide_window)
	self.hide()


func show_picture(texture_for_rect: Texture2D) -> void:
	var texture_resolution: Vector2 = texture_for_rect.get_size()
	lewd_texture.texture = texture_for_rect
	lewd_texture.max_h_range = texture_resolution.x - 1280
	lewd_texture.max_v_range = texture_resolution.y - 720 
	
	lewd_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	if texture_resolution.x < 1280 and texture_resolution.y < 720:
#		lewd_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lewd_texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	else:
#		lewd_texture.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		lewd_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if lewd_texture.texture is AnimatedTexture:
		lewd_texture.texture.pause = false
	show()


func hide_window() -> void:
	lewd_texture.texture = null
	display_hidden.emit()
	self.visible = false
