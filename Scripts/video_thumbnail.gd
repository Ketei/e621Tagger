class_name VideoThumbnail
extends TextureRect


signal thumbnail_clicked(path_to_file: String, reference)

var video_path: String = ""


func _ready():
	gui_input.connect(gui_input_received)


func gui_input_received(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		thumbnail_clicked.emit(video_path, self)
		#print("Click")
		
