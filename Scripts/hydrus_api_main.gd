extends Node


const api_address: String = "http://127.0.0.1:{0}/"
const search_endpoint: String = "get_files/search_files?"
const thumbnail_endpoint: String = "get_files/thumbnail?"
const file_endpoint: String = "get_files/file?"
const verify_access_endpoint: String = "verify_access_key"

var api_key: String = ""
var api_port: String = ""

var valid_api: bool = false

@onready var request_api: HTTPRequest = $RequestAPI
@onready var picture_downloader: HTTPRequest = $PictureDownloader


func _ready():
	valid_api = await verify_access_key()
	if valid_api:
		print(await search_for_tags(["bear", "cum"], 264))


func verify_access_key() -> bool:
	if api_port.is_empty() or api_key.is_empty():
		return false
	
	var access_string = api_address.format([api_port]) + verify_access_endpoint
	request_api.request(access_string, build_headers())
	var response: Array = await request_api.request_completed

	var headers = headers_parse(response[2])

	if response[0] != OK:
		print_debug("API responded with: " + str(response[0]))
		return false
	else:
		if headers.server.begins_with("client api"):
			
			var json = JSON.new()
			json.parse(response[3].get_string_from_utf8())
			var parsed = json.get_data()
			
			if response[1] == 200:
				if parsed["basic_permissions"].has(3.0):
					return true
				else:
					print_debug("Key doesn't have Search/Fetch permission(3)")
					return false
			else:
				print_debug(parsed["error"])
				print_debug(parsed["exception_type"])
				return false
		else:
			return false


func headers_parse(headers_array: Array) -> Dictionary:
	var _headers: Dictionary = {}
	for item in headers_array:
		var elements = item.split(":")
		_headers[elements[0].strip_edges().to_lower()] = elements[1].strip_edges()
	return _headers


func build_headers() -> Array:
	return ["Hydrus-Client-API-Access-Key:{0}".format([api_key])]


func verify_response(response: int) -> bool:
	return response == OK


func search_for_tags(tags_array: Array, tag_count: int) -> Array:
	if not valid_api:
		return []
	
	var request_url: String = api_address.format([api_port]) + search_endpoint
	
	if not tags_array.is_empty():
		request_url += "tags="
		var tags_to_format: String = "["
		for tag:String in tags_array:
			var tag_to_check = Tagger.alias_database.get_alias(tag.strip_edges())
			if Tagger.tag_manager.has_tag(tag_to_check):
				var tag_class: Tagger.Categories = Tagger.tag_manager.get_tag_type(tag_to_check)
				if tag_class == Tagger.Categories.ARTIST:
					tag_to_check = "creator:" + tag_to_check
				elif tag_class == Tagger.Categories.SPECIES:
					tag_to_check = "species:" + tag_to_check
				elif tag_class == Tagger.Categories.COPYRIGHT:
					tag_to_check = "series:" + tag_to_check
				elif tag_class == Tagger.Categories.CHARACTER:
					tag_to_check = "character:" + tag_to_check
				elif tag_class == Tagger.Categories.META:
					tag_to_check = "meta:" + tag_to_check
				elif tag_class == Tagger.Categories.LORE:
					tag_to_check = "lore:" + tag_to_check
			tags_to_format += "\"" +  tag_to_check.strip_edges() + "\","
		tags_to_format += "\"system:limit={0}\",".format([str(tag_count)])
		tags_to_format += "\"system:filetype=image,gif\","
		tags_to_format += "\"system:archive\""
		tags_to_format += "]"
		request_url += tags_to_format.uri_encode() + "&"
	
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

