class_name FullScreenDisplay
extends Control

@onready var lewd_texture: TextureRect = $ScrollContainer/LewdTexture


func _ready():
	lewd_texture.hide_lewd_image.connect(hide_window)
	self.hide()


func show_picture(texture_for_rect: ImageTexture) -> void:
	lewd_texture.texture = texture_for_rect
	if lewd_texture.expand_mode != TextureRect.EXPAND_IGNORE_SIZE:
		lewd_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	show()


func hide_window() -> void:
	self.visible = false
