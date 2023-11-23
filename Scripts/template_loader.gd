class_name TemplateItemContainer
extends VBoxContainer

signal template_selected(temp_name, tags, suggestions)

var template_name: String = ""
var template_tags: String = ""
var template_suggestions: String = ""

var array_tags := PackedStringArray()
var suggestion_tags := PackedStringArray()

@onready var template_name_le: LineEdit = $TempName/TemplateName
@onready var template_tags_le: LineEdit = $TempTags/TemplateTags
@onready var suggestion_tags_le: LineEdit = $TempSuggestions/SuggestionTags
@onready var load_button: Button = $LoadButton


func _ready():
	template_name_le.text = template_name
	template_tags_le.text = template_tags
	template_tags_le.tooltip_text = template_tags
	suggestion_tags_le.text = template_suggestions
	suggestion_tags_le.tooltip_text = template_suggestions
	load_button.pressed.connect(select_button_pressed)


func set_template(temp_name: String, tags: PackedStringArray, suggestions: PackedStringArray) -> void:
	template_name = temp_name
	array_tags = tags.duplicate()
	suggestion_tags = suggestions.duplicate()
	
	template_tags = Utils.array_to_string(Array(tags))
	template_suggestions = Utils.array_to_string(Array(suggestions))


func select_button_pressed() -> void:
	template_selected.emit(template_name, array_tags, suggestion_tags)


