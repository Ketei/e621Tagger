extends Control

var template_tags: Array = []
var template_suggestions: Array = []

var template_resource: TaglistResource

@onready var template_name: LineEdit = $VBoxContainer/Name/LineEdit

@onready var tag_list: ItemList = $VBoxContainer/ListContainer/TagsContainer/ItemList
@onready var tag_line: LineEdit = $VBoxContainer/ListContainer/TagsContainer/Menus/LineEdit
@onready var clear_tags_btn: Button = $VBoxContainer/ListContainer/TagsContainer/Menus/Button

@onready var suggestion_list: ItemList = $VBoxContainer/ListContainer/SuggestionsContainer/ItemList
@onready var suggestion_line: LineEdit = $VBoxContainer/ListContainer/SuggestionsContainer/Menus/LineEdit
@onready var clear_suggestions_button: Button = $VBoxContainer/ListContainer/SuggestionsContainer/Menus/Button
@onready var template_loader = $TemplateLoader
@onready var load_template_button: Button = $VBoxContainer/Name/Button
@onready var save_template_button: Button = $VBoxContainer/Button
@onready var open_folder_button: Button = $VBoxContainer/Name/OpenFolderButton


func _ready():
	template_loader.template_selected.connect(load_template)
	load_template_button.pressed.connect(search_for_templates)
	tag_line.text_submitted.connect(tag_submitted)
	suggestion_line.text_submitted.connect(suggestion_submitted)
	clear_suggestions_button.pressed.connect(clear_suggestions)
	clear_tags_btn.pressed.connect(clear_tags)
	save_template_button.pressed.connect(save_template)
	open_folder_button.pressed.connect(open_template_folder)


func search_for_templates() -> void:
	template_loader.load_templates()
	template_loader.show()


func tag_submitted(tag_text: String) -> void:
	tag_line.clear()
	
	tag_text = tag_text.strip_edges().to_lower()
	tag_text = Tagger.alias_database.get_alias(tag_text)
	
	var index_search: int = template_tags.find(tag_text)
	
	if index_search != -1:
		tag_list.select(index_search)
	
	template_tags.append(tag_text)
	tag_list.add_item(tag_text)


func suggestion_submitted(tag_text: String) -> void:
	suggestion_line.clear()
	
	tag_text = tag_text.strip_edges().to_lower()
	tag_text = Tagger.alias_database.get_alias(tag_text)
	
	var index_search: int = template_suggestions.find(tag_text)
	
	if index_search != -1:
		suggestion_list.select(index_search)
	
	template_suggestions.append(tag_text)
	suggestion_list.add_item(tag_text)


func load_template(temp_name: String, temp_tags: PackedStringArray, temp_suggestions: PackedStringArray) -> void:
	template_name.text = temp_name
	
	template_tags.clear()
	tag_list.clear()
	for tag in temp_tags:
		template_tags.append(tag)
		tag_list.add_item(tag)
	
	template_suggestions.clear()
	suggestion_list.clear()
	for sug in temp_suggestions:
		template_suggestions.append(sug)
		suggestion_list.add_item(sug)
	
	template_loader.hide()


func save_template() -> void:
	save_template_button.disabled = true
	template_resource = TaglistResource.new()
	template_resource.template_name = template_name.text.strip_edges()
	template_resource.template_tags = PackedStringArray(template_tags)
	template_resource.template_suggestions = PackedStringArray(template_suggestions)
	template_resource.save()
	clear_tags()
	clear_suggestions()
	template_name.clear()
	save_template_button.text = "Done!"
	await get_tree().create_timer(2).timeout
	save_template_button.text = "Save"
	save_template_button.disabled = false

func clear_tags() -> void:
	template_tags.clear()
	tag_list.clear()


func clear_suggestions() -> void:
	template_suggestions.clear()
	suggestion_list.clear()


func open_template_folder() -> void:
	OS.shell_open(ProjectSettings.globalize_path(Tagger.templates_path))

