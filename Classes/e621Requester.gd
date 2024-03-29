class_name e621Requester
extends Node

signal get_finished(response_data)
signal downloads_finished()
signal image_created(image_file)
signal image_skipped
signal images_saved
signal posts_found(amount)
signal request_timed_out
	
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

var current_queue_index: int = 0
var queue_pictures: Array[e621Post] = []

var http_requester_references: Array[e621Request] = []
var active_requesters: int = 0

var active_download_requesters: int = 0
var current_download_index: int = 0
var download_on_finish: bool = false
var save_on_finish: bool = false
var path_to_save_to: String = ""
var queue_downloads: Array[e621Post] = []

var main_active: bool = false


func _ready():
	main_e621.parsed_result.connect(_get_finished)
	main_e621.timeout = timeout_time
	main_e621.job_failed.connect(failed_task)
	
	for gen in range(max_parallel_requests):
		var e6_request := e621Request.new()
		e6_request.is_post_downloader = false
		e6_request.timeout = 20
		add_child(e6_request)
		http_requester_references.append(e6_request)
		#e6_request.job_finished.connect(request_timeout)


func failed_task() -> void:
	get_finished.emit([])


#func request_timeout() -> void:
	#image_skipped.emit()


func get_posts() -> void:
	print_debug("\n- Calling API for posts -\nHTTPClient status: {0} (Should be \"0\")".format([main_e621.get_http_client_status()]))
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
	
	var error = main_e621.request(_url, Tagger.get_headers(), HTTPClient.METHOD_GET)
	print_debug("\nTag HTTPRequest error code: {0} (Should be \"0\")\nURL:{1}".format([error, _url]))
	if error != OK:
		failed_task()


func get_tags() -> void:
	print_debug("\n- Calling API for tags -\nHTTPClient status: {0} (Should be \"0\")".format([main_e621.get_http_client_status()]))
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
	
	var error = main_e621.request(_url, Tagger.get_headers(), HTTPClient.METHOD_GET)
	print_debug("\nTag HTTPRequest error code: {0} (Should be \"0\")\nURL:{1}".format([error, _url]))
	if error != OK:
		failed_task()


func save_image(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, requester: e621Request) -> void:
	if result != 0:
		return
	
	var _new_image := Image.new()
	
	if requester.image_format == "jpg":
		_new_image.load_jpg_from_buffer(body)
		_new_image.save_jpg(path_to_save_to + str(requester.image_id) + ".jpg", 1.0)
	elif requester.image_format == "png":
		_new_image.load_png_from_buffer(body)
		_new_image.save_png(path_to_save_to + str(requester.image_id) + ".png")
	else:
		print_debug("\nUnsupporded format. Skipping")
	
	await get_tree().create_timer(2.0).timeout
	next_download_in_queue(requester)


func next_download_in_queue(requester) -> void:
	if queue_downloads.is_empty():
		active_requesters -= 1
		requester.request_completed.disconnect(save_image)
		print_debug("\n- API responded with array: [] -")
		get_finished.emit([])
		return
	
	var _request_data: e621Post = queue_downloads.pop_front()
	requester.job_index = current_queue_index
	current_queue_index += 1
	
	requester.image_id = _request_data.id
	if _request_data.sample.has_sample and get_sample_if_available and not _request_data.sample.url.is_empty():
		requester.image_format = "jpg"
		requester.request(_request_data.sample.url, Tagger.get_headers())
	elif not _request_data.file.url.is_empty():
		requester.image_format = _request_data.file.extension
		requester.request(_request_data.file.url, Tagger.get_headers())
	else:
		next_download_in_queue(requester)


func save_posts_to_path(e621_data_array: Array = []) -> void:
	if path_to_save_to.is_empty():
		get_finished.emit(e621_data_array)
		return
	
	for machine in http_requester_references:
		if not machine.request_completed.is_connected(save_image):
			machine.request_completed.connect(save_image.bind(machine))
	
	active_download_requesters = 0
	current_download_index = 0
	queue_downloads.clear()
	
	for post_object in e621_data_array:
		if post_object is e621Post:
			queue_downloads.append(post_object)
	
	for requester in http_requester_references:
		if not queue_downloads.is_empty():
			next_download_in_queue(requester)
			active_requesters += 1


func _get_finished(e621_data_array: Array) -> void:
	main_active = false
	
	if download_on_finish:
		download_on_finish = false
		posts_found.emit(e621_data_array.size())
		download_pictures(e621_data_array)
	elif save_on_finish:
		save_on_finish = false
		save_posts_to_path(e621_data_array)
	else:
		print_debug("\n- API responded with array: {0} -".format([str(e621_data_array)]))
		get_finished.emit(e621_data_array)
		

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
		if http_requester.request_completed.is_connected(save_image):
			http_requester.request_completed.disconnect(save_image)
	
	active_requesters = 0


func get_posts_and_download() -> void:
	download_on_finish = true
	get_posts()


# ------------------- Pic download functions -----------------
## Gets the pictures if there are any in the response array
func download_pictures(data_array: Array = []):
	for machine in http_requester_references:
		if not machine.request_completed.is_connected(_create_image):
			machine.request_completed.connect(_create_image.bind(machine))
	
	active_requesters = 0
	current_queue_index = 0
	queue_pictures.clear()
	
	for post_object in data_array:
		if post_object is e621Post:
			queue_pictures.append(post_object)

	for requester in http_requester_references:
		if not queue_pictures.is_empty():
			_next_in_queue(requester)
			active_requesters += 1


func disable_bar():
	progress_bar.visible = false


func _next_in_queue(requester: e621Request) -> void:
	if queue_pictures.is_empty():
		active_requesters -= 1
		requester.request_completed.disconnect(_create_image)
		if active_requesters == 0:
			print_debug("\n- API responded with array: [] -")
			get_finished.emit([])
		return
	
	var _request_data: e621Post = queue_pictures.pop_front()
	requester.job_index = current_queue_index
	current_queue_index += 1
	
	if _request_data.sample.has_sample and get_sample_if_available and not _request_data.sample.url.is_empty():
		requester.image_format = "jpg"
		requester.request(_request_data.sample.url, Tagger.get_headers())
	elif not _request_data.file.url.is_empty():
		requester.image_format = _request_data.file.extension
		requester.request(_request_data.file.url, Tagger.get_headers())
	else:
		image_skipped.emit()
		_next_in_queue(requester)
	
	
func _create_image(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, requester: e621Request) -> void:
	if result != 0:
		return
	
	var _new_image := Image.new()
	var new_texture : ImageTexture
	
	if requester.image_format == "jpg":
		_new_image.load_jpg_from_buffer(body)
		new_texture = ImageTexture.create_from_image(_new_image)
		image_created.emit(new_texture)
	elif requester.image_format == "png":
		_new_image.load_png_from_buffer(body)
		new_texture = ImageTexture.create_from_image(_new_image)
		image_created.emit(new_texture)
	elif requester.image_format == "gif":
		var new_animated: AnimatedTexture = GifManager.animated_texture_from_buffer(body, 256)
		image_created.emit(new_animated)
	else:
		image_skipped.emit()
		print_debug("\nUnsupporded format. Skipping")
	
	if not queue_pictures.is_empty():
		await get_tree().create_timer(1.0).timeout
		_next_in_queue(requester)
		
		
func cancel_all_requests() -> void:
	cancel_main_request()
	cancel_side_requests()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		cancel_all_requests()
		get_finished.emit([])
