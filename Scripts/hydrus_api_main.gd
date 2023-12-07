class_name HydrusRequestAPI
extends Node


signal thumbnail_created(texture_data, file_id)
signal image_created(texture_data, file_id)
signal thumbnails_grabbed
signal file_grabbed
signal thread_finished

const api_address: String = "http://127.0.0.1:{0}/"
const search_endpoint: String = "get_files/search_files?"
const thumbnail_endpoint: String = "get_files/thumbnail?"
const file_endpoint: String = "get_files/file?"
const verify_access_endpoint: String = "verify_access_key"

enum TextureMode {
	THUMBNAIL,
	FILE,
}

var api_key: String = ""
var api_port: int = 0
var texture_mode: TextureMode = TextureMode.FILE

var valid_api: bool = false

var _current_id: int = 0

@onready var request_api: HTTPRequest = $RequestAPI
@onready var picture_downloader: HTTPRequest = $PictureDownloader


func _ready():
	picture_downloader.request_completed.connect(_on_picture_found)


func set_data(port: int, key: String, verify_immediatly := false) -> void:
	api_port = port
	api_key = key
	if verify_immediatly:
		verify_access_key()


func reset_connection() -> void:
	api_port = 0
	api_key = ""
	valid_api = false


func verify_access_key() -> bool:
	if api_key.is_empty():
		valid_api = false
		return false
	
	var access_string = api_address.format([api_port]) + verify_access_endpoint
	request_api.request(access_string, build_headers())
	var response: Array = await request_api.request_completed

	var headers = headers_parse(response[2])

	if response[0] != OK:
		print_debug("API responded with: " + str(response[0]))
		valid_api = false
		return false
	else:
		if headers.server.begins_with("client api"):
			
			var json = JSON.new()
			json.parse(response[3].get_string_from_utf8())
			var parsed = json.get_data()
			
			if response[1] == 200:
				if parsed["basic_permissions"].has(3.0):
					valid_api = true
					return true
				else:
					print_debug("Key doesn't have Search/Fetch permission(3)")
					valid_api = false
					return false
			else:
				print_debug(parsed["error"])
				print_debug(parsed["exception_type"])
				valid_api = false
				return false
		else:
			valid_api =false
			return false


func headers_parse(headers_array: Array) -> Dictionary:
	var _headers: Dictionary = {}
	for item in headers_array:
		var elements = item.split(":")
		_headers[elements[0].strip_edges().to_lower()] = elements[1].strip_edges()
	return _headers


func build_headers() -> Array:
	return ["Hydrus-Client-API-Access-Key:{0}".format([api_key])]


func is_valid_headers(header_data: Dictionary) -> bool:
	if header_data.has("server"):
		if typeof(header_data.server) == 4:
			if header_data.server.begins_with("client api"):
				return true
	return false


func to_valid_system_tag(input_tag: String) -> String:
	var final_tag: String = ""
	
	if input_tag.begins_with("-"):
		input_tag = input_tag.trim_prefix("-")
		final_tag += "-"
	
	var aliased_tag = Tagger.alias_database.get_alias(input_tag)
	
	if Tagger.tag_manager.has_tag(aliased_tag):
		var tag_class: Tagger.Categories = Tagger.tag_manager.get_tag_type(aliased_tag)
		if tag_class == Tagger.Categories.ARTIST:
			final_tag += "creator:" + aliased_tag
		elif tag_class == Tagger.Categories.SPECIES:
			final_tag += "species:" + aliased_tag
		elif tag_class == Tagger.Categories.COPYRIGHT:
			final_tag += "series:" + aliased_tag
		elif tag_class == Tagger.Categories.CHARACTER:
			final_tag += "character:" + aliased_tag
		elif tag_class == Tagger.Categories.META:
			final_tag += "meta:" + aliased_tag
		elif tag_class == Tagger.Categories.LORE:
			final_tag += "lore:" + aliased_tag
		else:
			final_tag += aliased_tag
	else:
		final_tag += aliased_tag
	
	return final_tag


func search_for_tags(tags_array: Array, tag_count: int) -> Array:
	if not valid_api:
		return []
	
	var request_url: String = api_address.format([api_port]) + search_endpoint
	
	if not tags_array.is_empty():
		request_url += "tags="
		var tags_to_format: String = "["
		for tag:String in tags_array:
			var tag_to_check = to_valid_system_tag(tag.strip_edges())
			tags_to_format += "\"" +  tag_to_check.strip_edges() + "\","
		tags_to_format += "\"system:limit={0}\",".format([str(tag_count)])
		tags_to_format += "\"system:filetype=image"
		if Tagger.settings.load_hydrus_gifs: # Load gifs
			tags_to_format += ",gif"
		tags_to_format += "\","
		tags_to_format += "\"system:archive\""
		tags_to_format += "]"
		request_url += tags_to_format.uri_encode() + "&"
		print(tags_to_format)
	request_url += "file_sort_type=4"
	request_api.request(request_url, build_headers())
	var response = await request_api.request_completed
	
	if response[0] != OK or response[1] != 200:
		print_debug("API response was not 0/200")
		return[]
	
	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	var parsed = json.get_data()
	
	return parsed["file_ids"]


func get_thumbnails(ids_array: Array) -> void:
	if not valid_api:
		return
	
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		Tagger.common_thread.wait_to_finish()
		
	texture_mode = TextureMode.THUMBNAIL
	
	var url_building: String = api_address.format([api_port]) + thumbnail_endpoint
	
	for pic_id in ids_array:
		_current_id = pic_id
		picture_downloader.request(
				url_building + "file_id=" + str(pic_id),
				build_headers())
		await thread_finished
	
	thumbnails_grabbed.emit()


func _on_picture_found(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if not valid_api:
		thread_finished.emit()
		return
	
	if result != OK:
		print_debug("File got {0} as result".format([str(result)]))
		thread_finished.emit()
		return

	if response_code != 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var parsed = json.data
		print_debug("File got {0} as response".format([str(response_code)]))
		print_debug("Error: " + parsed["error"])
		print_debug("Exception type: " + parsed["exception_type"])
		thread_finished.emit()
		return
	
	var header_data = headers_parse(headers)
	
	if not is_valid_headers(header_data):
		print_debug("Headers don't match with Hydrus API")
		thread_finished.emit()
		return

	Tagger.common_thread.start(create_texture.bind(body, header_data["content-type"].split("/")[1]))


func create_texture(image_data: PackedByteArray, image_format: String) -> void:
	var image := Image.new()
	var texture: ImageTexture
	var anim_texture: AnimatedTexture
	if image_format == "jpeg" or image_format == "jpg":
		image.load_jpg_from_buffer(image_data)
		texture = ImageTexture.create_from_image(image)
		if texture_mode == TextureMode.FILE:
			call_deferred("emit_signal", "image_created", texture, _current_id)
		elif texture_mode == TextureMode.THUMBNAIL:
			call_deferred("emit_signal", "thumbnail_created", texture, _current_id)
	elif image_format == "png":
		image.load_png_from_buffer(image_data)
		texture = ImageTexture.create_from_image(image)
		if texture_mode == TextureMode.FILE:
			call_deferred("emit_signal", "image_created", texture, _current_id)
		elif texture_mode == TextureMode.THUMBNAIL:
			call_deferred("emit_signal", "thumbnail_created", texture, _current_id)
	elif image_format == "gif":
		anim_texture = GifManager.animated_texture_from_buffer(image_data, 256)
		if texture_mode == TextureMode.FILE:
			call_deferred("emit_signal", "image_created", anim_texture, _current_id)
		elif texture_mode == TextureMode.THUMBNAIL:
			call_deferred("emit_signal", "thumbnail_created", anim_texture, _current_id)
	clean_thread.call_deferred()


func clean_thread() -> void:
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		Tagger.common_thread.wait_to_finish()
	thread_finished.emit()


func get_file(file_id: int) -> void:
	if not valid_api:
		return
	
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		Tagger.common_thread.wait_to_finish()
	
	texture_mode = TextureMode.FILE
	
	var url_building: String = api_address.format([api_port]) + file_endpoint
	
	picture_downloader.request(
			url_building + "file_id=" + str(file_id), 
			build_headers())
	
	await thread_finished
	
	file_grabbed.emit()

