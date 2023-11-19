class_name e621Request
extends HTTPRequest


signal job_finished(reference) # Unused signal
signal parsed_result(e621_result)
signal job_failed

enum RequestType {POST, TAG}

enum RequestResult {
	SUCCESS,
	CHUNKED_BODY_SIZE_MISMATCH,
	CANT_CONNECT,
	CANT_RESOLVE,
	CONNECTION_ERROR,
	TLS_HANDSHAKE_ERROR,
	NO_RESPONSE,
	BODY_SIZE_LIMIT_EXCEEDED,
	BODY_DECOMPRESS_FAILED,
	REQUEST_FAILED,
	DOWNLOAD_FILE_CANT_OPEN,
	DOWNLOAD_FILE_WRITE_ERROR,
	REDIRECT_LIMIT_REACHED,
	TIMEOUT,
}

var request_mode: RequestType = RequestType.POST

var job_index: int = 0
var image_format: String = ""
var image_id: int = 0
var is_post_downloader: bool = true


func _ready():
	if is_post_downloader:
		self.request_completed.connect(_on_response)


func _on_response(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != 0:
		print_debug("Job finished with error: " + RequestResult.keys()[result])
		job_failed.emit()
		return

	if request_mode == RequestType.POST:
		var response_json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		
		var response_post_array: Array[e621Post] = []
		
		for post_index in range(response_json["posts"].size()):
			var _e6_post := e621Post.new()
		
			_e6_post.id = response_json["posts"][post_index]["id"]
			_e6_post.created_at = response_json["posts"][post_index]["created_at"]
			_e6_post.updated_at = response_json["posts"][post_index]["updated_at"]
			
			_e6_post.file.width = response_json["posts"][post_index]["file"]["width"]
			_e6_post.file.height = response_json["posts"][post_index]["file"]["height"]
			_e6_post.file.extension = response_json["posts"][post_index]["file"]["ext"]
			_e6_post.file.size = response_json["posts"][post_index]["file"]["size"]
			_e6_post.file.md5 = response_json["posts"][post_index]["file"]["md5"]
			_e6_post.file.url = response_json["posts"][post_index]["file"]["url"] if response_json["posts"][post_index]["file"]["url"] else ""
			
			_e6_post.preview.width = response_json["posts"][post_index]["preview"]["width"]
			_e6_post.preview.height = response_json["posts"][post_index]["preview"]["height"]
			_e6_post.preview.url = response_json["posts"][post_index]["preview"]["url"] if response_json["posts"][post_index]["preview"]["url"] else ""
			
			
			_e6_post.sample.has_sample = response_json["posts"][post_index]["sample"]["has"]
			_e6_post.sample.url = response_json["posts"][post_index]["sample"]["url"] if response_json["posts"][post_index]["sample"]["url"] else ""
			_e6_post.sample.height = response_json["posts"][post_index]["sample"]["height"]
			_e6_post.sample.width = response_json["posts"][post_index]["sample"]["width"]
			_e6_post.sample.alternates = response_json["posts"][post_index]["sample"]["alternates"]
		
			_e6_post.score.up = response_json["posts"][post_index]["score"]["up"]
			_e6_post.score.down = response_json["posts"][post_index]["score"]["down"]
			_e6_post.score.total = response_json["posts"][post_index]["score"]["total"]
			
			_e6_post.parse_tags(response_json["posts"][post_index]["tags"])
			
			_e6_post.flags.pending = response_json["posts"][post_index]["flags"]["pending"]
			_e6_post.flags.flagged = response_json["posts"][post_index]["flags"]["flagged"]
			_e6_post.flags.note_locked = response_json["posts"][post_index]["flags"]["note_locked"]
			_e6_post.flags.status_locked = response_json["posts"][post_index]["flags"]["status_locked"]
			_e6_post.flags.rating_locked = response_json["posts"][post_index]["flags"]["rating_locked"]
			_e6_post.flags.deleted = response_json["posts"][post_index]["flags"]["deleted"]
			
			_e6_post.set_rating(response_json["posts"][post_index]["rating"])
			_e6_post.fav_count = response_json["posts"][post_index]["fav_count"]
			
			_e6_post.sources.append_array(response_json["posts"][post_index]["sources"])
			_e6_post.pools.append_array(response_json["posts"][post_index]["pools"])
			
			_e6_post.relationships.parent_id = response_json["posts"][post_index]["relationships"]["parent_id"] if response_json["posts"][post_index]["relationships"]["parent_id"] else -1
			_e6_post.relationships.has_children = response_json["posts"][post_index]["relationships"]["has_children"]
			_e6_post.relationships.has_active_children = response_json["posts"][post_index]["relationships"]["has_active_children"]
			_e6_post.relationships.children = response_json["posts"][post_index]["relationships"]["children"]
			
			_e6_post.description = response_json["posts"][post_index]["description"]
			
			if response_json["posts"][post_index]["duration"]:
				_e6_post.duration = response_json["posts"][post_index]["duration"]
			else:
				_e6_post.duration = 0.0
			
			response_post_array.append(_e6_post)
			
		parsed_result.emit(response_post_array)
		
		
	elif request_mode == RequestType.TAG:
		var response_array = JSON.parse_string(body.get_string_from_utf8())
		
		if typeof(response_array) == TYPE_DICTIONARY:
			parsed_result.emit([]) # This is the correct signal
			return
		
		var tags_array: Array[e621Tag] = []
		
		for index in range(response_array.size()):
			var _e621_tag: e621Tag = e621Tag.new()
			_e621_tag.id = response_array[index]["id"]
			_e621_tag.tag_name = response_array[index]["name"].replace("_", " ")
			_e621_tag.post_count = response_array[index]["post_count"]
			_e621_tag.set_related_tags(response_array[index]["related_tags"])
			_e621_tag.category = response_array[index]["category"]
			_e621_tag.is_locked = response_array[index]["is_locked"]
			tags_array.append(_e621_tag)
		
		parsed_result.emit(tags_array)

