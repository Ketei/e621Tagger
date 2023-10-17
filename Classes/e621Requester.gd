class_name e621Requester
extends Node

signal get_finished()
signal downloads_finished()
signal image_created(image_file)
signal image_skipped
	
enum Category {
	ANY = -1,
	GENERAL = 0,
	ARTIST = 1,
	COPYRIGHT = 3,
	CHARACTER = 4,
	SPECIES = 5,
	INVALID = 6,
	META = 7,
	LORE = 8,
}


@export var max_parallel_requests: int = 5
@export var progress_bar : ProgressBar
@export var timeout_time: float = 0.0


@export_group("Search")
@export var match_name: Array[String] = []
@export_range(1, 320, 1) var post_limit: int = 75
@export var page: int = 0
## If set to Before or After then "Page" will be considered a "Post ID" instead
@export_enum("Ignore", "Before", "After") var page_set: int = 0

@export_subgroup("Tag specific")
@export var match_category: Category = Category.ANY
@export_enum("date", "count", "name") var order: String = "date"

@export_subgroup("Post Specific")
@export var get_sample_if_available: bool = true

@onready var main_e621: e621Request = $main_E621

var response_array: Array = []
var response_array_unflipped: Array = []

var current_queue_index: int = 0
var queue_pictures: Array[e621Post] = []
var downloaded_pictures: Dictionary = {}

var http_requester_references: Array[e621Request] = []
var active_requesters: int = 0

var download_on_finish: bool = false

var main_active: bool = false

func _ready():
	main_e621.job_finished.connect(_get_finished)
	main_e621.timeout = timeout_time
	
	for gen in range(max_parallel_requests):
		var e6_request := e621Request.new()
		e6_request.is_post_downloader = false
		add_child(e6_request)
		http_requester_references.append(e6_request)


func get_posts() -> void:
	main_e621.request_mode = e621Request.RequestType.POST
	
	var _url: String = "https://e621.net/posts.json?"
	
	if post_limit != 75:
		_url += "limit=" + str(post_limit) + "&"
	if page_set == 0:
		_url += "page=" + str(page) + "&"
	else:
		if page_set == 1:
			_url += "page=b" + str(page) + "&"
		else:
			_url += "page=a" + str(page) + "&"
	if not match_name.is_empty():
		_url += "tags="
	
		for tag in match_name:
			_url += tag.strip_edges().replace(" ", "_") + "+"
		_url = _url.left(-1)

	if _url.ends_with("&"):
		_url = _url.left(-1)
	
	main_active = true
	
	main_e621.request(_url, Tagger.get_headers())


func get_tags() -> void:
	main_e621.request_mode = e621Request.RequestType.TAG
	
	var _url: String = "https://e621.net/tags.json?"
	
	if not match_name.is_empty():
		_url += "search[name_matches]=" + match_name.front().replace(" ", "_") + "&"
	if match_category != Category.ANY:
		_url += "search[category]=" + str(match_category) + "&"
	if order != "date":
		_url += "search[order]=" + order + "&"
	if post_limit != 75:
		_url += "limit=" + str(post_limit) + "&"
	if page_set == 0:
		_url += "page=" + str(page)
	else:
		if page_set == 1:
			_url += "page=b" + str(page)
		else:
			_url += "page=a" + str(page)
	
	if _url.ends_with("&"):
		_url = _url.left(-1)
	
	main_active = true
	
	main_e621.request(_url, Tagger.get_headers())


func _get_finished(requester: e621Request) -> void:
	response_array = requester.request_result.duplicate()
	response_array_unflipped = response_array.duplicate()
	response_array.reverse()
	get_finished.emit()
	
	if download_on_finish:
		download_pictures()
		download_on_finish = false
	
	main_active = false


func cancel_main_request() -> void:
	main_e621.cancel_request()
	main_active = false


func cancel_side_requests() -> void:
	if 0 == active_requesters:
		return
	
	for http_requester in http_requester_references:
		http_requester.cancel_request()
		if http_requester.request_completed.is_connected(_create_image):
			http_requester.request_completed.disconnect(_create_image)
	
	active_requesters = 0


func get_posts_and_download() -> void:
	download_on_finish = true
	get_posts()


# ------------------- Pic download functions -----------------
## Gets the pictures if there are any in the response array
func download_pictures():
	downloaded_pictures.clear()
	
	for machine in http_requester_references:
		if not machine.request_completed.is_connected(_create_image):
			machine.request_completed.connect(_create_image.bind(machine))
	
	active_requesters = 0
	current_queue_index = 0
	queue_pictures.clear()
	
	for post_object in response_array:
		if post_object is e621Post:
			queue_pictures.append(post_object)
	
#	if progress_bar:
#		progress_bar.max_value = queue_pictures.size()
#		progress_bar.visible = true
	
	for requester in http_requester_references:
		if not queue_pictures.is_empty():
			_next_in_queue(requester)
			active_requesters += 1
			current_queue_index += 1
#			var _request_data: e621Post = queue_pictures.pop_back()
#
#			requester.job_index = current_queue_index
#
#			if _request_data.sample.has_sample and get_sample_if_available and not _request_data.sample.url.is_empty():
#				if _request_data.sample.url.is_empty():
#					continue
#				requester.image_format = "jpg"
#				requester.request(_request_data.sample.url, Tagger.get_headers())
#			elif not _request_data.file.url.is_empty():
#				requester.image_format = _request_data.file.extension
#				requester.request(_request_data.file.url, Tagger.get_headers())
#			else:
#				pass


func disable_bar():
	progress_bar.visible = false


func create_textures() -> Array[ImageTexture]:
	var item_count: Array = []
	
	if 1 < max_parallel_requests:
		for pic_key in downloaded_pictures.keys():
			item_count.append(int(pic_key))
		item_count.sort()
	else:
		item_count = downloaded_pictures.keys()
	
#	if progress_bar:
#		var _tween :Tween = create_tween()
#		_tween.tween_property(progress_bar, "self_modulate", Color.TRANSPARENT, 2.0)
#		_tween.finished.connect(disable_bar)
		
	var _return_array: Array[ImageTexture] = []
	
	for index in item_count:
	
		var _new_text := ImageTexture.new()
		_new_text = ImageTexture.create_from_image(downloaded_pictures[str(index)])
		_return_array.append(_new_text)
	
	return _return_array


func _next_in_queue(requester: e621Request) -> void:
	if queue_pictures.is_empty():
		active_requesters -= 1
		requester.request_completed.disconnect(_create_image)
		if active_requesters == 0:
			downloads_finished.emit()
		return
	
	var _request_data: e621Post = queue_pictures.pop_back()
	current_queue_index += 1
	requester.job_index = current_queue_index
	
	
	if _request_data.sample.has_sample and get_sample_if_available and not _request_data.sample.url.is_empty():
		requester.image_format = "jpg"
		requester.request(_request_data.sample.url, Tagger.get_headers())
	elif not _request_data.file.url.is_empty():
		requester.image_format = _request_data.file.extension
		requester.request(_request_data.file.url, Tagger.get_headers())
	else:
#		progress_bar.value += 1
		image_skipped.emit()
		_next_in_queue(requester)
	
	
func _create_image(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, requester: e621Request) -> void:
	if progress_bar:
		progress_bar.value += 1
	
	if result != 0:
		return
	
	var _new_image := Image.new()
	
	if requester.image_format == "jpg":
		_new_image.load_jpg_from_buffer(body)
		downloaded_pictures[str(requester.job_index)] = _new_image
		image_created.emit(_new_image)
	elif requester.image_format == "png":
		_new_image.load_png_from_buffer(body)
		downloaded_pictures[str(requester.job_index)] = _new_image
		image_created.emit(_new_image)
	else:
		image_skipped.emit()
		print_debug("Unsupporded format. Skipping")
	
	_next_in_queue(requester)
	
