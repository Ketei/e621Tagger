extends Control

signal finished_loading_local()
signal tag_updated

@onready var tag_search_line_edit: LineEdit = $VBoxContainer/HBoxContainer/VBoxContainer/TagSearcher
@onready var wiki_edit: RichTextLabel = $VBoxContainer/HBoxContainer/VBoxContainer/WikiDisplayRTLabel

@onready var lewd_pic_container: GridContainer = $VBoxContainer/HBoxContainer/Imeges/ScrollContainer/LewdPicsContainer
@onready var preview_progress_load: ProgressBar = $VBoxContainer/HBoxContainer/Imeges/PreviewProgressLoad
@onready var wiki_search_cooldown: Timer = $WikiSearchCooldown

@onready var full_screen_display = $FullScreenDisplay
@onready var wiki_image_requester = $WikiImageRequester
@onready var wiki_popup_menu: PopupMenu = $"../MenuBar/Wiki"
@onready var main_application = $".."
@onready var video_player = $VideoPlayer

var lewd_display = preload("res://Scenes/lewd_pic_display.tscn")
var video_thumbnails = preload("res://Scenes/video_thumbnail.tscn")

var images_to_display: Array[ImageTexture] = []
var videos_to_display: Array[String] = []

#var thread: Thread

var thread_interrupt: bool = false
var thread_working: bool = false
var mutex := Mutex.new()

var is_local_loading_done: bool = false
var is_web_loading_done: bool = false

var amount_vs_resolution: Dictionary = {
	"1": 630,
	"2": 312, # 6px separator
	"3": 208, # 6px separator
}

var current_search: String = ""


func _ready():
	wiki_edit.search_in_wiki.connect(search_for_tag)
	full_screen_display.display_hidden.connect(play_all_gifs)
	tag_search_line_edit.text_submitted.connect(search_for_tag)
	wiki_popup_menu.id_pressed.connect(activate_menu_option)
	wiki_image_requester.image_created.connect(display_image)
	wiki_image_requester.image_skipped.connect(increase_progress)
	wiki_image_requester.posts_found.connect(web_progress_set)


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		if full_screen_display.visible:
			full_screen_display.hide_window()
		if video_player.visible:
			video_player.hide_window()
			play_all_gifs()


func set_new_picture_columns(columns_to_display: int) -> void:
	Tagger.settings.picture_columns_to_search = columns_to_display
	lewd_pic_container.columns = Tagger.settings.picture_columns_to_search
	
	if 1 < lewd_pic_container.columns:
		lewd_pic_container.add_theme_constant_override("h_separation", 6)
		lewd_pic_container.add_theme_constant_override("v_separation", 8)


func activate_menu_option(id_option: int) -> void:
	if id_option == 0:
		search_for_tag(current_search)
	elif id_option == 1:
		main_application.go_to_edit_tag(current_search)


func hide_node() -> void:
	pause_all_gifs()
	hide()


func show_node() -> void:
	play_all_gifs()
	show()


func clear_wiki() -> void:
	current_search = ""
	images_to_display.clear()
	videos_to_display.clear()
	for child in lewd_pic_container.get_children():
		if child is LewdTextureRect:
			child.lewd_pic_pressed.disconnect(display_big_pic)
		elif child is VideoThumbnail:
			child.thumbnail_clicked.disconnect(display_vid_player)
		child.queue_free()
	wiki_edit.text = ""
	wiki_popup_menu.set_item_disabled(
			wiki_popup_menu.get_item_index(1),
			true
	)
	preview_progress_load.value = 0
	preview_progress_load.max_value = 1


func search_for_tag(new_text: String) -> void:
	tag_search_line_edit.release_focus()
	
	if not tag_search_line_edit.editable:
		return
	
	clear_wiki()
	
	lewd_pic_container.columns = Tagger.settings.picture_columns_to_search
	
	if new_text.is_empty():
		tag_search_line_edit.clear()
		return
	
	new_text = new_text.to_lower().strip_edges()
	new_text = Tagger.alias_database.get_alias(new_text)
	
	if not Tagger.tag_manager.has_tag(new_text):
		tag_search_line_edit.clear()
		return
	
	tag_search_line_edit.editable = false
	
	wiki_popup_menu.set_item_disabled(
			wiki_popup_menu.get_item_index(1),
			false
	)
	
	current_search = new_text
	var _tag: Tag = Tagger.tag_manager.get_tag(new_text)
	wiki_edit.text = build_wiki_entry(_tag)
	
	preview_progress_load.max_value = 0
	preview_progress_load.value = 0
	
	var local_image_data: Dictionary = get_local_filenames(_tag)
	
	if 0 < local_image_data["count"]:
		is_local_loading_done = false
		preview_progress_load.max_value += local_image_data["count"]
		get_local_images(local_image_data["folder"], local_image_data["files"])
	else:
		is_local_loading_done = true

	if _tag.has_pictures and Tagger.settings.can_load_from_e6():
		is_web_loading_done = false
		search_web_images(_tag.tag)
	else:
		is_web_loading_done = true

	if is_web_loading_done and is_local_loading_done:
		tag_search_line_edit.editable = true


func get_local_filenames(target_tag: Tag) -> Dictionary:
	var file_names: Array = []
	var final_file_names: Array = []
	
	var return_dictionary: Dictionary = {}
	for file_name in DirAccess.get_files_at(Tagger.tag_images_path + target_tag.file_name.get_basename()):
		var file_extension: String = file_name.get_extension()
		if file_extension != "png" and file_extension != "jpg" and file_extension != "gif" and file_extension != "ogv":
			continue
		if file_extension == "gif":
			if Tagger.settings.load_local_gifs:
				file_names.append(file_name)
		else:
			file_names.append(file_name)

	if target_tag.has_pictures and Tagger.settings.can_load_from_local():
		if DirAccess.dir_exists_absolute(Tagger.tag_images_path + target_tag.file_name.get_basename()):
			if Tagger.settings.local_review_amount < file_names.size():
				for ignored in range(Tagger.settings.local_review_amount):
					var tag_to_transfer = file_names.pick_random()
					final_file_names.append(tag_to_transfer)
					file_names.erase(tag_to_transfer)
			else:
				final_file_names = file_names
			
#			if 0 < array_size:
#				get_local_images(target_tag.file_name.get_basename(), final_file_names)
	
	return_dictionary["folder"] = target_tag.file_name.get_basename()
	return_dictionary["files"] = final_file_names
	return_dictionary["count"] = final_file_names.size()
	
	return return_dictionary


func build_wiki_entry(target_tag: Tag) -> String:
	var html_text: String = Tagger.settings.category_color_code[Tagger.Categories.keys()[target_tag.category]]
	
	if not Color.html_is_valid(html_text):
		html_text = "cccccc"
	
	var bbc_text: String = "[font_size=30][color={1}]{0}[/color][/font_size]\n".format([target_tag.tag.capitalize(), html_text])

	bbc_text += "[color=29b8e7][b]Category: [/b] {0}[/color]\n\n".format([Tagger.Categories.keys()[target_tag.category].capitalize()])
	
	if not target_tag.parents.is_empty():
		bbc_text += "[color=8eef97][b]Parents: [/b]"
		for parent_tag in target_tag.parents:
			if Tagger.tag_manager.has_tag(parent_tag):
				bbc_text += "[url]{0}[/url], ".format([parent_tag])
			else:
				bbc_text += parent_tag + ", "
		bbc_text = bbc_text.left(-2)
		bbc_text += "[/color]"
		bbc_text += "\n"
	if not target_tag.conflicts.is_empty():
		bbc_text += "[color=8eef97][b]Conflicts: [/b]"
		for suggested_tag in target_tag.conflicts:
			if Tagger.tag_manager.has_tag(suggested_tag):
				bbc_text += "[url]{0}[/url], ".format([suggested_tag])
			else:
				bbc_text += suggested_tag + ", "
		bbc_text = bbc_text.left(-2)
		bbc_text += "[/color]"
		bbc_text += "\n"
	
	bbc_text += "\n"
	bbc_text += target_tag.wiki_entry
	
	return bbc_text
	

func load_local_images(final_file_names: Array, folder_name) -> void:
	for file_name in final_file_names:
		
		mutex.lock()
		var should_exit = thread_interrupt
		mutex.unlock()
		
		if should_exit:
			break
		
		var tempstring: String = file_name
		
		var file_extension = tempstring.get_extension()
		
		if file_extension != "png" and file_extension != "jpg" and file_extension != "gif" and file_extension != "ogv":
			preview_progress_load.call_deferred("set_value", preview_progress_load.value + 1)
			continue
		if file_extension == "gif":
			var new_gif_display: AnimatedTexture = GifManager.animated_texture_from_file(Tagger.tag_images_path + folder_name + "/" + file_name, 256)
			new_gif_display.pause = false
			display_image.call_deferred(new_gif_display)
		elif  file_extension == "ogv":
			display_video.call_deferred(Tagger.tag_images_path + folder_name + "/" + file_name)
		else:
			var _new_image := Image.load_from_file(Tagger.tag_images_path + folder_name + "/" + file_name)
			_new_image.generate_mipmaps()
			var _new_texture := ImageTexture.create_from_image(_new_image)
			display_image.call_deferred(_new_texture)

	merge_thread.call_deferred()


func get_local_images(folder_name: String, file_name_array: Array) -> void:
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		Tagger.common_thread.wait_to_finish()
	
	Tagger.common_thread.start(load_local_images.bind(file_name_array, folder_name))


func increase_progress() -> void:
	preview_progress_load.value += 1
	if preview_progress_load.value == preview_progress_load.max_value:
		finished_loading_local.emit()
		if wiki_search_cooldown.is_stopped():
			await wiki_search_cooldown.timeout
		tag_search_line_edit.editable = true


func create_and_display_image(image_file: Texture2D) -> void:
#	var _new_texture := ImageTexture.create_from_image(image_file)
	display_image(image_file)


func display_image(image_texture: Texture2D):
	var new_child_thumb: LewdTextureRect = lewd_display.instantiate()
	new_child_thumb.texture = image_texture

	var texture_size: Vector2 = image_texture.get_size()
	
	var new_heigth: float = (texture_size.y / texture_size.x) * amount_vs_resolution[str(Tagger.settings.picture_columns_to_search)]
	
	new_child_thumb.custom_minimum_size = Vector2(amount_vs_resolution[str(Tagger.settings.picture_columns_to_search)], new_heigth)
	
	new_child_thumb.pause_texture(not self.visible)
	
	lewd_pic_container.add_child(new_child_thumb)
	new_child_thumb.lewd_pic_pressed.connect(display_big_pic)
	increase_progress()


func display_video(path_to_vid: String) -> void:
	var vid_thumbnail: VideoThumbnail = video_thumbnails.instantiate()
	vid_thumbnail.video_path = path_to_vid
	#vid_thumbnail.texture = load()
	vid_thumbnail.thumbnail_clicked.connect(display_vid_player)
	vid_thumbnail.custom_minimum_size = Vector2(amount_vs_resolution[str(Tagger.settings.picture_columns_to_search)], amount_vs_resolution[str(Tagger.settings.picture_columns_to_search)])
	vid_thumbnail.tooltip_text = path_to_vid.get_file().get_basename()
	lewd_pic_container.add_child(vid_thumbnail)
	increase_progress()


func merge_thread():
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		Tagger.common_thread.wait_to_finish()
	thread_working = false
	thread_interrupt = false
	is_local_loading_done = true
	
	if is_local_loading_done and is_web_loading_done:
		tag_search_line_edit.editable = true


func web_progress_set(amount: int) -> void:
	preview_progress_load.max_value += amount
	if amount == 0:
		is_web_loading_done = true
	
	if is_local_loading_done and is_web_loading_done:
		tag_search_line_edit.editable = true


func search_web_images(tag_names: String) -> void:
	wiki_image_requester.post_limit = Tagger.settings.e621_review_amount
	
	if tag_names.is_empty():
		tag_names = "vaporeon -female -ambiguous_gender rating:explicit"
	
	var search_tags: Array[String] = ["~type:jpg", "~type:png", "order:score"]
	
	if Tagger.settings.load_web_gifs:
		search_tags.append("~type:gif")
	
	search_tags.append(tag_names)
	
	for blacklist_tag in Tagger.settings_lists.suggestion_review_blacklist:
		if search_tags.has(blacklist_tag):
			continue
		search_tags.append("-" + blacklist_tag)
	
	wiki_image_requester.match_name = search_tags.duplicate()
	wiki_image_requester.get_posts_and_download()
	wiki_search_cooldown.start()


func display_big_pic(texture_to_load: Texture2D) -> void:
	pause_all_gifs()
	full_screen_display.show_picture(texture_to_load)


func display_vid_player(path_to_vid: String, node_reference: TextureRect) -> void:
	pause_all_gifs()
	video_player.play_video_stream(path_to_vid, node_reference)


func pause_all_gifs() -> void:
	for child in lewd_pic_container.get_children():
		if child is LewdTextureRect:
			child.pause_texture(true)


func play_all_gifs() -> void:
	for child in lewd_pic_container.get_children():
		if child is LewdTextureRect:
			child.pause_texture(false)


