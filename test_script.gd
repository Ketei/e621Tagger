extends Control

@export_enum("Posts", "Tags") var download_mode: int = 0

var post_array_test: Array
var picture_request: HTTPRequest

var picture_format: String = ""
var picture_queue: Array = []
var pictures_array: Array = []

var e621_requester: e621Requester

@onready var grid_container = $ScrollContainer/GridContainer
@onready var progress_bar = $ProgressBar

func _ready():
	e621_requester = $e621Requester
	e621_requester.get_finished.connect(finish_get)
	e621_requester.downloads_finished.connect(create_textures)
	
	if download_mode == 0:
		e621_requester.get_posts()
	else:
		e621_requester.get_tags()


func finish_get() -> void:
	print("Finish Get")
	e621_requester.download_pictures()


func create_textures() -> void:
	print("FinishDownload")
	for texture in e621_requester.create_textures():
		var _new_rect := NinePatchRect.new()
		_new_rect.custom_minimum_size = Vector2(
				472,
				floori((((472 * 100) / float(texture.get_width())) / 100.0) * texture.get_height()))
		_new_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_new_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_new_rect.texture = texture
		grid_container.add_child(_new_rect)



func get_finished() -> void:
	var tag_info: e621Tag = e621_requester.response_array.front()
	print("ID: " + str(tag_info.id))
	print("Name: " + tag_info.tag_name)
	print("Post count: " + str(tag_info.post_count))
	print("Related tags: " + str(tag_info.related_tags))
	print("Category: " + str(e621Tag.Category.keys()[tag_info.category].to_pascal_case()))
	print("Locked: " + str(tag_info.is_locked))
	
	var strength_aray: Array = tag_info.get_tags_with_strenght()
	print(strength_aray)
	
