class_name MainTagger
extends Control

@onready var menu = %Menu
@onready var tagger = $Tagger
@onready var list_loader = $ListLoader
@onready var settings = $Settings
@onready var tag_creator = $TagCreator
@onready var tag_reviewer = $"TagReviewer"
@onready var tag_category_searcher = $TagCategorySearcher

@onready var e_621_requester_quick_search = $Tagger/AddAutoComplete/QuickSearch/e621RequesterQuickSearch
@onready var tag_reviewer_requester = $TagReviewer/TagReviewerRequester
@onready var e_621_requester = %e621Requester


var current_menu: int = 0


func _ready():
	
	tag_reviewer.parents_item_list.create_tag.connect(go_to_create_tag)
	tag_reviewer.tag_suggestion_list.create_tag.connect(go_to_create_tag)
	tag_creator.tag_created.connect(load_tag_if_added)
	
	menu.id_pressed.connect(trigger_options)
	
	list_loader.visible = false
	tag_creator.visible = false
	tag_reviewer.visible = false
	settings.visible = false
	tagger.visible = true
	current_menu = 0


func trigger_options(id: int) -> void:
	if id == current_menu:
		return
	
	current_menu = id
	
	if id == 0:
		list_loader.visible = false
		settings.visible = false
		tag_creator.visible = false
		tag_reviewer.visible = false
		tag_category_searcher.hide()
		tagger.visible = true
	elif id == 2:
		tagger.visible = false
		settings.visible = false
		tag_creator.visible = false
		tag_reviewer.visible = false
		tag_category_searcher.hide()
		list_loader.visible = true
	elif id == 3:
		tagger.visible = false
		list_loader.visible = false
		tag_creator.visible = false
		tag_reviewer.visible = false
		tag_category_searcher.hide()
		settings.visible = true
	elif id == 5:
		tagger.visible = false
		list_loader.visible = false
		tag_creator.visible = false
		settings.visible = false
		tag_category_searcher.hide()
		tag_reviewer.visible = true
	elif  id == 6:
		tagger.hide()
		list_loader.hide()
		tag_creator.hide()
		settings.hide()
		tag_reviewer.hide()
		tag_category_searcher.show()
		
	elif id == 4:
		tagger.visible = false
		list_loader.visible = false
		settings.visible = false
		tag_reviewer.visible = false
		tag_category_searcher.hide()
		tag_creator.visible = true
		
	elif id == 1:
		quit_app()


func go_to_create_tag(tag_to_create: String) -> void:
	tag_creator.clear_menu_items("", false)
	tag_creator.tag_to_add_line_edit.text = tag_to_create
	tag_creator.tag_to_add_line_edit.text_changed.emit(tag_to_create)
	trigger_options(4)
	

func go_to_edit_tag(tag_to_edit: String) -> void:
	tag_reviewer.search_for_tag(tag_to_edit)
	trigger_options(5)


func load_tags(tags_array: Array, replace: bool) -> void:
	tagger.load_tags(tags_array, replace)


func load_tag_if_added(tag_to_add: String) -> void:
	if tagger.is_tag_added(tag_to_add):
		tagger.load_tags([tag_to_add], false)


func quit_app() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		e_621_requester_quick_search.cancel_main_request()
		e_621_requester_quick_search.cancel_side_requests()
		
		tag_creator.e621_samples_downloader.cancel_main_request()
		tag_creator.e621_samples_downloader.cancel_side_requests()
		
		tag_reviewer.e_621_samples_dl_review.cancel_main_request()
		tag_reviewer.e_621_samples_dl_review.cancel_side_requests()
		
		tag_reviewer_requester.cancel_main_request()
		tag_reviewer_requester.cancel_side_requests()
		
		e_621_requester.cancel_main_request()
		e_621_requester.cancel_side_requests()
		
		Tagger.settings.save()
		Tagger.site_settings.save()
		Tagger.settings_lists.save()
		Tagger.alias_database.save()
		
		if is_instance_valid(tag_reviewer.thread) and tag_reviewer.thread.is_started():
			tag_reviewer.thread_interrupt = true
			tag_reviewer.thread.wait_to_finish()
		
		get_tree().quit()

