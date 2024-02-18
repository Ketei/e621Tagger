class_name ShortcutContainer
extends Control

var shortcut: String = ""
var turns_into: String = ""

@onready var shortcut_char_line_edit: LineEdit = $HBoxContainer/ShortcutCharLineEdit
@onready var turns_into_line_edit: LineEdit = $HBoxContainer/TurnsIntoLineEdit
@onready var edit_shortcut_button: Button = $HBoxContainer/EditShortcutButton
@onready var remove_shortcut_button: Button = $HBoxContainer/RemoveShortcutButton


func set_shortcut(input: String, transforms: String) -> void:
	shortcut = input
	turns_into = transforms


func _ready():
	shortcut_char_line_edit.text = shortcut
	turns_into_line_edit.text = turns_into
	remove_shortcut_button.pressed.connect(remove_shortcut)
	edit_shortcut_button.pressed.connect(update_shortcut)


func update_shortcut() -> void:
	turns_into = turns_into_line_edit.text
	Tagger.settings_lists.shortcuts[shortcut] = turns_into
	edit_shortcut_button.disabled = true
	edit_shortcut_button.text = "Done!"
	await get_tree().create_timer(1.0).timeout
	edit_shortcut_button.text = "Save"
	edit_shortcut_button.disabled = false


func remove_shortcut() -> void:
	Tagger.settings_lists.shortcuts.erase(shortcut)
	Tagger.settings_lists.sort_shortcuts()
	queue_free()

