class_name MainTagger
extends Control

@onready var menu = %Menu
@onready var tagger = $NewTagger
@onready var list_loader = $ListLoader
@onready var settings = $Settings
@onready var tag_creator = $TagCreator
@onready var tag_reviewer = $"TagReviewer"
@onready var tag_category_searcher = $TagCategorySearcher
@onready var wiki = $Wiki

#@onready var e_621_requester_quick_search = $Tagger/AddAutoComplete/QuickSearch/e621RequesterQuickSearch
@onready var e_621_requester = %e621Requester
@onready var menu_bar: MenuBar = $MenuBar

var current_menu: int = -1


func _ready():
	menu_bar.set_menu_hidden(1, false) # Tagger
	menu_bar.set_menu_hidden(2, true) # Tag Creator
	menu_bar.set_menu_hidden(3, true) # Review
	menu_bar.set_menu_hidden(4, true) # Review
	menu_bar.set_menu_hidden(5, true) # Settings
	
	tag_reviewer.tag_updated.connect(load_tag_if_added)
	tag_reviewer.parents_item_list.create_tag.connect(go_to_create_tag)
	tag_reviewer.tag_suggestion_list.create_tag.connect(go_to_create_tag)
	tag_creator.tag_created.connect(load_tag_if_added)
	
	menu.id_pressed.connect(trigger_options)
	
	trigger_options(0)


func trigger_options(id: int) -> void:
	if id == current_menu:
		return
	
	current_menu = id
	
	if id == 0:
		list_loader.visible = false
		settings.visible = false
		tag_creator.visible = false
		tag_reviewer.hide()
		tag_category_searcher.hide()
		wiki.hide_node()
		menu_bar.set_menu_hidden(1, false) # Tagger
		menu_bar.set_menu_hidden(2, true) # Tag Creator
		menu_bar.set_menu_hidden(3, true) # Review
		menu_bar.set_menu_hidden(4, true) # Wiki
		menu_bar.set_menu_hidden(5, true) # Settings
		tagger.visible = true
	elif id == 7:
		tagger.visible = false
		settings.visible = false
		tag_creator.visible = false
		tag_reviewer.hide()
		tag_category_searcher.hide()
		menu_bar.set_menu_hidden(1, true) # Tagger
		menu_bar.set_menu_hidden(2, true) # Tag Creator
		menu_bar.set_menu_hidden(3, true) # Review
		menu_bar.set_menu_hidden(4, false) # Wiki
		menu_bar.set_menu_hidden(5, true) # Settings
		wiki.show_node()
	elif id == 2:
		tagger.visible = false
		settings.visible = false
		tag_creator.visible = false
		tag_reviewer.hide()
		tag_category_searcher.hide()
		wiki.hide_node()
		menu_bar.set_menu_hidden(1, true) # Tagger
		menu_bar.set_menu_hidden(2, true) # Tag Creator
		menu_bar.set_menu_hidden(3, true) # Review
		menu_bar.set_menu_hidden(4, true) # Wiki
		menu_bar.set_menu_hidden(5, true) # Settings
		list_loader.visible = true
	elif id == 3:
		tagger.visible = false
		list_loader.visible = false
		tag_creator.visible = false
		tag_reviewer.hide()
		tag_category_searcher.hide()
		wiki.hide_node()
		menu_bar.set_menu_hidden(1, true) # Tagger
		menu_bar.set_menu_hidden(2, true) # Tag Creator
		menu_bar.set_menu_hidden(3, true) # Review
		menu_bar.set_menu_hidden(4, true) # Wiki
		menu_bar.set_menu_hidden(5, false) # Settings
		settings.visible = true
	elif id == 5:
		tagger.visible = false
		list_loader.visible = false
		tag_creator.visible = false
		settings.visible = false
		tag_category_searcher.hide()
		wiki.hide_node()
		menu_bar.set_menu_hidden(1, true) # Tagger
		menu_bar.set_menu_hidden(2, true) # Tag Creator
		menu_bar.set_menu_hidden(3, false) # Review
		menu_bar.set_menu_hidden(4, true) # Wiki
		menu_bar.set_menu_hidden(5, true) # Settings
		tag_reviewer.show()
	elif  id == 6:
		tagger.hide()
		list_loader.hide()
		tag_creator.hide()
		settings.hide()
		tag_reviewer.hide()
		wiki.hide_node()
		menu_bar.set_menu_hidden(1, true) # Tagger
		menu_bar.set_menu_hidden(2, true) # Tag Creator
		menu_bar.set_menu_hidden(3, true) # Review
		menu_bar.set_menu_hidden(4, true) # Wiki
		menu_bar.set_menu_hidden(5, true) # Settings
		tag_category_searcher.show()
		
	elif id == 4:
		tagger.visible = false
		list_loader.visible = false
		settings.visible = false
		tag_reviewer.hide()
		tag_category_searcher.hide()
		wiki.hide_node()
		menu_bar.set_menu_hidden(1, true) # Tagger
		menu_bar.set_menu_hidden(2, false) # Tag Creator
		menu_bar.set_menu_hidden(3, true) # Review
		menu_bar.set_menu_hidden(4, true) # Wiki
		menu_bar.set_menu_hidden(5, true) # Settings
		tag_creator.visible = true
		
	elif id == 1:
		quit_app()


func go_to_create_tag(tag_to_create: String, parent_tags: Array = [], suggestion_tags: Array = [], category := Tagger.Categories.GENERAL) -> void:
	tag_creator.clear_menu_items("", false)
	tag_creator.tag_to_add_line_edit.text = tag_to_create
	tag_creator.tag_to_add_line_edit.text_changed.emit(tag_to_create)
	for tag in suggestion_tags:
		if tag != tag_to_create:
			tag_creator.add_suggestion(tag)
	for tag in parent_tags:
		if tag != tag_to_create:
			tag_creator.add_parent(tag)
	tag_creator.categories_menu.select(category)
	trigger_options(4)


func go_to_edit_tag(tag_to_edit: String) -> void:
	tag_reviewer.search_for_tag(tag_to_edit)
	trigger_options(5)


func load_tags(tags_array: Array) -> void:
	tagger.load_tags(tags_array)


func load_tag_if_added(tag_to_add: String) -> void:
	tagger.update_tag(tag_to_add)


func quit_app() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
#		e_621_requester_quick_search.cancel_main_request()
#		e_621_requester_quick_search.cancel_side_requests()
		
		tag_creator.e621_samples_downloader.cancel_main_request()
		tag_creator.e621_samples_downloader.cancel_side_requests()
		
		tag_reviewer.e621_samples_dl_review.cancel_main_request()
		tag_reviewer.e621_samples_dl_review.cancel_side_requests()
		
		wiki.wiki_image_requester.cancel_main_request()
		wiki.wiki_image_requester.cancel_side_requests()
		
		e_621_requester.cancel_main_request()
		e_621_requester.cancel_side_requests()
		
		Tagger.settings.save()
		Tagger.site_settings.save()
		Tagger.settings_lists.save()
		Tagger.alias_database.save()
		
		if is_instance_valid(wiki.thread) and wiki.thread.is_started():
			wiki.thread_interrupt = true
			wiki.thread.wait_to_finish()
		
		get_tree().quit()

