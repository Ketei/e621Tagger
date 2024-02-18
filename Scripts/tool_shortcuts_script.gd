extends VBoxContainer

@onready var shortcuts_container_vbox: VBoxContainer = $ScrollContainer/ShortcutsContainerVBox
@onready var create_shortcut_button: Button = $HBoxContainer/CreateShortcutButton

@onready var new_short_shortcut_le: LineEdit = $HBoxContainer/HBoxContainer/NewShortShortcutLE
@onready var new_short_turns_le: LineEdit = $HBoxContainer/HBoxContainer/NewShortTurnsLE

var shortcut_tag_scene = preload("res://Scenes/shortcut_container.tscn")
#
func _ready():
	for shortcut in Tagger.settings_lists.shortcuts.keys():
		var new_shortcut: ShortcutContainer = shortcut_tag_scene.instantiate()
		new_shortcut.set_shortcut(shortcut, Tagger.settings_lists.shortcuts[shortcut])
		shortcuts_container_vbox.add_child(new_shortcut)
	
	create_shortcut_button.pressed.connect(create_shortcut)


func create_shortcut() -> void:
	var _shortcut: String = new_short_shortcut_le.text.strip_edges().to_lower()
	var _turns_into: String = new_short_turns_le.text.strip_edges().to_lower()
	
	new_short_shortcut_le.clear()
	new_short_turns_le.clear()
	
	if _shortcut.is_empty() or _turns_into.is_empty() or Tagger.settings_lists.shortcuts.has(_shortcut):
		return
	
	Tagger.settings_lists.shortcuts[_shortcut] = _turns_into
	Tagger.settings_lists.sort_shortcuts()
	
	var new_short_display: ShortcutContainer = shortcut_tag_scene.instantiate()
	new_short_display.set_shortcut(_shortcut, _turns_into)
	
	shortcuts_container_vbox.add_child(new_short_display)
	create_shortcut_button.release_focus()
