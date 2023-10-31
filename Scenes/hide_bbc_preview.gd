extends Control

@onready var close_preview_button:Button = $ClosePreviewButton

func _ready():
	close_preview_button.pressed.connect(hide)
