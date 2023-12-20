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
	
	print_debug("\nSuccessfully added {0} to queue with priority \"{1}\"".format([str(tags_to_search), str(is_priority)]))
	print_debug(
		"\nLimit: {0}\nSearch type: {1}\nReference node: {2}\nDownload path: \"{3}\"".format(
			[
				str(limit),
				str(search_type),
				node_reference.get_path(),
				download_path
			]
		)
		)
	
	if is_api_active == false:
		print_debug("\n- Starting e621 API queue -")
		is_api_active = true
		next_in_queue()


func next_in_queue() -> void:
	if tag_search_queue.is_empty() and prio_search_queue.is_empty():
		print_debug("\n- e621 API queue empty, finishing -")
		is_api_active = false
		return
	
	print_debug(
		"\n- Remaining queues -\nPriority: {0}\nRegular: {1}".format(
			[
				str(prio_search_queue),
				str(tag_search_queue)
			]))
	
	tag_requester.match_name.clear()
	
	var queued_call: Dictionary = {}
	
	if not prio_search_queue.is_empty():
		queued_call = prio_search_queue.pop_front()
	else:
		queued_call = tag_search_queue.pop_front()
	
	tag_requester.match_name.append_array(queued_call["tags"])
	tag_requester.post_limit = queued_call["limit"]
	tag_requester.path_to_save_to = queued_call["path"]
	
	if tag_requester.save_on_finish:
		tag_requester.save_on_finish = false
	if tag_requester.download_on_finish:
		tag_requester.download_on_finish = false
	
	if queued_call["type"] == SEARCH_TYPES.TAG:
		tag_requester.get_tags()
	else:
		if queued_call["type"] == SEARCH_TYPES.DOWNLOAD:
			tag_requester.save_on_finish = true
		tag_requester.get_posts()
	
	print_debug("\nAwaiting on tags: " + str(queued_call["tags"]))
	print_debug("Full data: " + str(queued_call))
	var response: Array = await tag_requester.get_finished
	print("\n- Successful response -")
	
	if is_instance_valid(queued_call["reference"]):
		print_debug("\nSending response to node: " + str(queued_call["reference"].get_path()))
		queued_call["reference"].api_response(
				{
					"tags": queued_call["tags"],
					"response": response
				})
	else:
		print_debug("\nRequester node is no longer in memory. Skipping request for: " + str(queued_call["tags"]))
	
	print_debug("\n- e621 API cooldown started -")
	api_cooldown.start()
	
	await api_cooldown.timeout
	print_debug("\n- e621 API cooldown finished -")
	
	next_in_queue()


func remove_from_queue(dict_to_remove: Dictionary, is_prio := false) -> void:
	var target_index: int = 0
	
	if is_prio:
		target_index = prio_search_queue.find(dict_to_remove)
		print_debug("Trying to remove priority queue element: " + str(target_index))
		if target_index != -1:
			prio_search_queue.remove_at(target_index)
	else:
		target_index = tag_search_queue.find(dict_to_remove)
		print_debug("Trying to remove queue element: " + str(target_index))
		if target_index != -1:
			tag_search_queue.remove_at(target_index)

