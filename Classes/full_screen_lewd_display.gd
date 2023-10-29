class_name FullScreenDisplay
extends Control

signal display_hidden

@onready var lewd_texture: TextureRect = $ScrollContainer/LewdTexture


func _ready():
	lewd_texture.hide_lewd_image.connect(hide_window)
	self.hide()


func show_picture(texture_for_rect: Texture2D) -> void:
	lewd_texture.texture = texture_for_rect
	
	lewd_texture.max_h_range = texture_for_rect.get_width() - 1280
	lewd_texture.max_v_range = texture_for_rect.get_height() - 720 
	
	
	if lewd_texture.expand_mode != TextureRect.EXPAND_IGNORE_SIZE:
		lewd_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	if lewd_texture.texture is AnimatedTexture:
		lewd_texture.texture.pause = false
	show()


func hide_window() -> void:
	display_hidden.emit()
	self.visible = false
