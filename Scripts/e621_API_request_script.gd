extends Node
class_name E621API

enum SEARCH_TYPES {
	TAG,
	POST,
	DOWNLOAD,
}

# {"tag_name": {type: "post"/"tag", "limit","request_node": node_reference}}
@onready var tag_request_timer: Timer = $APICooldown
@onready var tag_requester: e621Requester = $e621ImageDownloader
var tag_search_queue: Array[Dictionary] = []
var is_api_active: bool = false

@onready var api_cooldown: Timer = $APICooldown


func add_to_queue(tags_to_search: Array, limit: int, search_type:SEARCH_TYPES, node_reference: Node, download_path: String = "") -> void:
	tag_search_queue.append(
		{
			"tags": tags_to_search,
			"type": search_type,
			"limit": limit,
			"reference": node_reference,
			"path": download_path
		}
	)
	
	if not is_api_active:
		next_in_queue()


func next_in_queue() -> void:
	if not is_api_active:
		is_api_active = true
	tag_requester.match_name.clear()
	var queued_call: Dictionary = tag_search_queue.pop_front()
	print(queued_call)
	tag_requester.match_name.append_array(queued_call["tags"])
	tag_requester.post_limit = queued_call["limit"]
	tag_requester.path_to_save_to = queued_call["path"]
	tag_requester.save_on_finish = false
	
	if queued_call["type"] == SEARCH_TYPES.TAG:
		tag_requester.get_tags()
	else:
		if queued_call["type"] == SEARCH_TYPES.DOWNLOAD:
			tag_requester.save_on_finish = true
		tag_requester.get_posts()
	
	var response: Array = await tag_requester.get_finished
	
	print(response)
	queued_call["reference"].api_response(response)
	
	tag_request_timer.start()
	
	await tag_request_timer.timeout
	
	if tag_search_queue.is_empty():
		is_api_active = false
	else:
		next_in_queue()


func remove_from_queue(dict_to_remove: Dictionary) -> void:
	var target_index: int = tag_search_queue.find(dict_to_remove)
	if target_index != -1:
		tag_search_queue.remove_at(target_index)

