extends Node
class_name E621API

enum SEARCH_TYPES {
	TAG,
	POST,
	DOWNLOAD,
}


@onready var api_cooldown: Timer = $APICooldown
@onready var tag_requester: e621Requester = $e621ImageDownloader
var tag_search_queue: Array[Dictionary] = []
var prio_search_queue: Array[Dictionary] = []
var is_api_active: bool = false


func add_to_queue(tags_to_search: Array, limit: int, search_type:SEARCH_TYPES, node_reference: Node, download_path: String = "", is_priority := false) -> void:
	if is_priority:
		prio_search_queue.append(
		{
			"tags": tags_to_search,
			"type": search_type,
			"limit": limit,
			"reference": node_reference,
			"path": download_path
		})
	else:
		tag_search_queue.append(
		{
			"tags": tags_to_search,
			"type": search_type,
			"limit": limit,
			"reference": node_reference,
			"path": download_path
		})
	
	if not is_api_active:
		next_in_queue()


func next_in_queue() -> void:
	if not is_api_active:
		is_api_active = true
	
	tag_requester.match_name.clear()
	
	var queued_call: Dictionary = {}
	
	if not prio_search_queue.is_empty():
		queued_call = prio_search_queue.pop_front()
	else:
		queued_call = tag_search_queue.pop_front()
	
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
	
	if is_instance_valid(queued_call["reference"]):
		queued_call["reference"].api_response(
				{
					"tags": queued_call["tags"],
					"response": response
				})
	
	api_cooldown.start()
	
	await api_cooldown.timeout
	
	if tag_search_queue.is_empty() and prio_search_queue.is_empty():
		is_api_active = false
	else:
		next_in_queue()


func remove_from_queue(dict_to_remove: Dictionary, is_prio := false) -> void:
	var target_index: int = 0
	
	if is_prio:
		target_index = prio_search_queue.find(dict_to_remove)
		if target_index != -1:
			prio_search_queue.remove_at(target_index)
	else:
		target_index = tag_search_queue.find(dict_to_remove)
		if target_index != -1:
			tag_search_queue.remove_at(target_index)

