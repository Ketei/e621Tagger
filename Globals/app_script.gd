class_name MainTagger
extends Control

@onready var menu = %Menu
@onready var tagger = $Tagger
@onready var list_loader = $ListLoader
@onready var settings = $Settings
@onready var tag_creator = $TagCreator
@onready var tag_reviewer = $"TagReviewer"

var current_menu: int = 0


func _ready():
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
		tagger.visible = true
	elif id == 2:
		tagger.visible = false
		settings.visible = false
		tag_creator.visible = false
		tag_reviewer.visible = false
		list_loader.visible = true
	elif id == 3:
		tagger.visible = false
		list_loader.visible = false
		tag_creator.visible = false
		tag_reviewer.visible = false
		settings.visible = true
	elif id == 5:
		tagger.visible = false
		list_loader.visible = false
		tag_creator.visible = false
		settings.visible = false
		tag_reviewer.visible = true
	elif id == 4:
		tagger.visible = false
		list_loader.visible = false
		settings.visible = false
		tag_reviewer.visible = false
		tag_creator.visible = true
		
	elif id == 1:
		quit_app()


func load_tags(tags_array: Array, replace: bool) -> void:
	tagger.load_tags(tags_array, replace)


func quit_app() -> void:
	Tagger.settings.save()
	Tagger.site_settings.save()
	#Tagger.alias_database.save()
	get_tree().quit()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_app()

