extends Control

signal _finished_loading_local()
signal tag_updated

@onready var tag_search_line_edit: LineEdit = $VBoxContainer/HBoxContainer/VBoxContainer/TagSearcher
@onready var wiki_edit: RichTextLabel = $VBoxContainer/HBoxContainer/VBoxContainer/WikiDisplayRTLabel

@onready var lewd_pic_container: GridContainer = $VBoxContainer/HBoxContainer/Imeges/ScrollContainer/LewdPicsContainer
@onready var preview_progress_load: ProgressBar = $VBoxContainer/HBoxContainer/Imeges/PreviewProgressLoad

@onready var full_screen_display = $FullScreenDisplay
@onready var wiki_image_requester = $WikiImageRequester
@onready var wiki_popup_menu: PopupMenu = $"../MenuBar/Wiki"
@onready var main_application = $".."

var lewd_display = preload("res://Scenes/lewd_pic_display.tscn")

var images_to_display: Array[ImageTexture] = []

#var thread: Thread

var thread_interrupt: bool = false

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


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel") and full_screen_display.visible:
		full_screen_display.hide_window()


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
	for child in lewd_pic_container.get_children():
		child.lewd_pic_pressed.disconnect(display_big_pic)
		child.queue_free()
	tag_search_line_edit.clear()
	tag_search_line_edit.placeholder_text = "Search in Wiki"
	wiki_edit.text = ""
	wiki_popup_menu.set_item_disabled(
			wiki_popup_menu.get_item_index(1),
			true
	)


func search_for_tag(new_text: String) -> void:
	clear_wiki()
	
	lewd_pic_container.columns = Tagger.settings.picture_columns_to_search
	
	if new_text.is_empty():
		return
	
	new_text = new_text.to_lower().strip_edges()
	new_text = Tagger.alias_database.get_alias(new_text)
	
	if not Tagger.tag_manager.has_tag(new_text):
		return
	
	wiki_popup_menu.set_item_disabled(
			wiki_popup_menu.get_item_index(1),
			false
	)
	
	current_search = new_text
	var _tag: Tag = Tagger.tag_manager.get_tag(new_text)
	var bbc_text: String = "[font_size=30][color={1}]{0}[/color][/font_size]\n".format([_tag.tag.capitalize(), Tagger.settings.category_color_code[Tagger.Categories.keys()[_tag.category]]])
	tag_search_line_edit.placeholder_text = _tag.tag
	
	bbc_text += "[color=29b8e7][b]Category: [/b] {0}[/color]\n\n".format([Tagger.Categories.keys()[_tag.category].capitalize()])
	
	if not _tag.parents.is_empty():
		bbc_text += "[color=8eef97][b]Parents: [/b]"
		for parent_tag in _tag.parents:
			if Tagger.tag_manager.has_tag(parent_tag):
				bbc_text += "[url]{0}[/url], ".format([parent_tag])
			else:
				bbc_text += parent_tag + ", "
		bbc_text = bbc_text.left(-2)
		bbc_text += "[/color]"
		bbc_text += "\n"
	if not _tag.conflicts.is_empty():
		bbc_text += "[color=8eef97][b]Conflicts: [/b]"
		for suggested_tag in _tag.conflicts:
			if Tagger.tag_manager.has_tag(suggested_tag):
				bbc_text += "[url]{0}[/url], ".format([suggested_tag])
			else:
				bbc_text += suggested_tag + ", "
		bbc_text = bbc_text.left(-2)
		bbc_text += "[/color]"
		bbc_text += "\n"
	
	bbc_text += "\n"
	bbc_text += _tag.wiki_entry
	
	wiki_edit.text = bbc_text
	
	preview_progress_load.max_value = 0
	preview_progress_load.value = 0
	
	var file_names: Array = []
	var final_file_names: Array = []
		
	for file_name in DirAccess.get_files_at(Tagger.tag_images_path + _tag.file_name.get_basename()):
		
		var file_extension: String = file_name.get_extension()
		
		if file_extension != "png" and file_extension != "jpg" and file_extension != "gif":
			continue
		
		if file_extension == "gif":
			if Tagger.settings.load_local_gifs:
				file_names.append(file_name)
		else:
			file_names.append(file_name)
	
	if _tag.has_pictures and Tagger.settings.can_load_from_local():
		if DirAccess.dir_exists_absolute(Tagger.tag_images_path + _tag.file_name.get_basename()):
			if Tagger.settings.local_review_amount < file_names.size():
				for ignored in range(Tagger.settings.local_review_amount):
					var tag_to_transfer = file_names.pick_random()
					final_file_names.append(tag_to_transfer)
					file_names.erase(tag_to_transfer)
			else:
				final_file_names = file_names
			
			preview_progress_load.max_value += final_file_names.size()
			
			if _tag.has_pictures and Tagger.settings.can_load_from_e6():
				preview_progress_load.max_value += Tagger.settings.e621_review_amount
			
			get_local_images(_tag.file_name.get_basename(), final_file_names)

	if _tag.has_pictures and Tagger.settings.can_load_from_e6():
		search_web_images(_tag.tag)


func load_local_images(final_file_names: Array, folder_name) -> void:
	for file_name in final_file_names:
		if thread_interrupt:
			break
		
		var tempstring: String = file_name
		
		var file_extension = tempstring.get_extension()

		if file_extension != "png" and file_extension != "jpg" and file_extension != "gif":
			preview_progress_load.call_deferred("set_value", preview_progress_load.value + 1)
			continue
		
		if file_extension == "gif":
			var new_gif_display: AnimatedTexture = GifManager.animated_texture_from_file(Tagger.tag_images_path + folder_name + "/" + file_name, 256)
			new_gif_display.pause = false
			display_image.call_deferred(new_gif_display)
		else:
			var _new_image := Image.load_from_file(Tagger.tag_images_path + folder_name + "/" + file_name)
			_new_image.generate_mipmaps()
			var _new_texture := ImageTexture.create_from_image(_new_image)
			display_image.call_deferred(_new_texture)
	display_images.call_deferred()


func get_local_images(folder_name: String, file_name_array: Array) -> void:
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		thread_interrupt = true
		Tagger.common_thread.wait_to_finish()
	
	if thread_interrupt:
		thread_interrupt = false
	
	Tagger.common_thread.start(load_local_images.bind(file_name_array, folder_name))


func increase_progress() -> void:
	preview_progress_load.value += 1


func create_and_display_image(image_file: Texture2D) -> void:
#	var _new_texture := ImageTexture.create_from_image(image_file)
	display_image(image_file)


func display_image(image_texture: Texture2D):
	preview_progress_load.value += 1
	
	var new_child_thumb: LewdTextureRect = lewd_display.instantiate()
	new_child_thumb.texture = image_texture
	
	var texture_size: Vector2 = image_texture.get_size()
	
	var new_heigth: float = (texture_size.y / texture_size.x) * amount_vs_resolution[str(Tagger.settings.picture_columns_to_search)]
	
	new_child_thumb.custom_minimum_size = Vector2(amount_vs_resolution[str(Tagger.settings.picture_columns_to_search)], new_heigth)
	
	new_child_thumb.pause_texture(not self.visible)
	
	lewd_pic_container.add_child(new_child_thumb)
	new_child_thumb.lewd_pic_pressed.connect(display_big_pic)


func display_images():
	Tagger.common_thread.wait_to_finish()


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


func create_download_textures() -> void:
	for index in wiki_image_requester.downloaded_pictures.keys():
		var _new_texture := ImageTexture.create_from_image(wiki_image_requester.downloaded_pictures[index])
		var new_lewd_child: LewdTextureRect = lewd_display.instantiate()
		new_lewd_child.texture = _new_texture
		new_lewd_child.lewd_pic_pressed.connect(display_big_pic)
		lewd_pic_container.add_child(new_lewd_child)


func display_big_pic(texture_to_load: Texture2D) -> void:
	pause_all_gifs()
	full_screen_display.show_picture(texture_to_load)


func pause_all_gifs() -> void:
	for child in lewd_pic_container.get_children():
		child.pause_texture(true)


func play_all_gifs() -> void:
	for child in lewd_pic_container.get_children():
		child.pause_texture(false)

