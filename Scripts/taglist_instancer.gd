extends Control

var tagger_preload = preload("res://Scenes/tagger_instance.tscn")
var instance_dictionary: Dictionary = {}
@onready var main_application = $".."
@onready var tagger_popup_menu: PopupMenu = $"../MenuBar/Tagger"
@onready var instances_tab_bar: TabBar = $InstancesTabBar
@onready var instance_holder = $InstanceHolder
@onready var new_instance_window = $NewInstanceWindow

var active_instance: String = ""

@onready var e_621api_request: E621API = $"../e621APIRequest"


func add_to_api_queue(tag_name: String, tag_amount: int, node_ref: Node) -> void:
	e_621api_request.add_to_queue([tag_name], tag_amount, E621API.SEARCH_TYPES.TAG, node_ref)


func add_to_api_prio_queue(tag_name: String, tag_amount: int, node_ref: Node) -> void:
	e_621api_request.add_to_queue([tag_name], tag_amount, E621API.SEARCH_TYPES.TAG, node_ref, "", true)


func remove_from_api_prio_queue(tag_to_remove: String, reference_node: Node, tag_amount: int) -> void:
	var dictionary_to_search: Dictionary = {
		"tags": [tag_to_remove],
		"type": E621API.SEARCH_TYPES.TAG,
		"limit": tag_amount,
		"reference": reference_node,
		"path": ""
		}
	e_621api_request.remove_from_queue(dictionary_to_search, true)


func remove_from_api_queue(tag_to_remove: String, reference_node: Node, tag_amount: int) -> void:
	var dictionary_to_search: Dictionary = {
		"tags": [tag_to_remove],
		"type": E621API.SEARCH_TYPES.TAG,
		"limit": tag_amount,
		"reference": reference_node,
		"path": ""
		}
	e_621api_request.remove_from_queue(dictionary_to_search)


func _ready():
	tagger_popup_menu.set_item_checked(tagger_popup_menu.get_item_index(2), Tagger.settings.search_suggested)
	tagger_popup_menu.set_item_checked(tagger_popup_menu.get_item_index(3), Tagger.settings.load_suggested)
	
	tagger_popup_menu.id_pressed.connect(tagger_menu_activated)
	instances_tab_bar.tab_changed.connect(switch_active_instance)
	instances_tab_bar.tab_close_pressed.connect(close_new_tagger)


func tagger_menu_activated(id_selected: int) -> void:
	var item_index: int = tagger_popup_menu.get_item_index(id_selected)
	
	if id_selected == 7:
		new_instance_window.show_and_focus()
	elif id_selected == 2: # Online Suggestions
		tagger_popup_menu.toggle_item_checked(item_index)
		Tagger.settings.search_suggested = tagger_popup_menu.is_item_checked(item_index)
	elif id_selected == 3:
		tagger_popup_menu.toggle_item_checked(item_index) # Offline Suggestions
		Tagger.settings.load_suggested = tagger_popup_menu.is_item_checked(item_index)


func switch_active_instance(tab_int: int) -> void:
	active_instance = instances_tab_bar.get_tab_title(tab_int)
	for instance in instance_dictionary.keys():
		if instance == active_instance:
			instance_dictionary[instance].show()
		else:
			instance_dictionary[instance].hide()


func create_new_tagger(unique_name: String) -> void:
	if instance_dictionary.has(unique_name) or unique_name.is_empty():
		return
	
	instances_tab_bar.add_tab(unique_name)
	instances_tab_bar.current_tab = instances_tab_bar.tab_count - 1
	
	var new_tagger_instance = tagger_preload.instantiate()
	new_tagger_instance.main_application = main_application
	new_tagger_instance.tagger_menu_bar = tagger_popup_menu
	new_tagger_instance.tag_holder = self
	new_tagger_instance.instance_name = unique_name
	instance_holder.add_child(new_tagger_instance)
	instance_dictionary[unique_name] = new_tagger_instance
	update_menus()


func load_tags(tags_array: Array, tagger_name: String = "") -> void:
	if tagger_name.is_empty():
		var new_tab_name: String = "loaded_"
		var int_value: String = str(randi_range(0, 9999))
		
		while instance_dictionary.has(new_tab_name + int_value):
			int_value = str(randi_range(0, 9999))
		
		tagger_name = new_tab_name + int_value
	
	if instance_dictionary.has(tagger_name):
		instance_dictionary[tagger_name].load_tag_list(tags_array, false)
	else:
		create_new_tagger(tagger_name)
		instance_dictionary[tagger_name].load_tag_list(tags_array, true)


func close_new_tagger(tab_id: int) -> void:
	var instance_name: String = instances_tab_bar.get_tab_title(tab_id)
	instances_tab_bar.remove_tab(tab_id)
	
	if not instance_dictionary.has(instance_name):
		return
		
	var instance_reference = instance_dictionary[instance_name]
	
	instance_dictionary.erase(instance_name)
	instance_reference.disconnect_and_free()
	update_menus()


func update_menus() -> void:
	if instance_dictionary.is_empty():
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(8),
			true)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(0),
			true)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(1),
			true)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(4),
			true)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(9),
			true)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(11),
			true)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(12),
			true)
	else:
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(8),
			false)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(0),
			false)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(1),
			false)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(4),
			false)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(9),
			false)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(11),
			false)
		tagger_popup_menu.set_item_disabled(
			tagger_popup_menu.get_item_index(12),
			false)


func can_create_instance(instance_name: String) -> bool:
	instance_name = instance_name.strip_edges().strip_escapes().to_lower()
	return not instance_name.is_empty()


func update_tag(tag_to_update: String) -> void:
	for instance in instance_dictionary:
		instance_dictionary[instance].update_tag(tag_to_update)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		for instance in instance_dictionary.keys():
			instance_dictionary[instance].disconnect_and_free()
		instance_dictionary.clear()
		instances_tab_bar.clear_tabs()

