extends VBoxContainer

@onready var aliases_tree: Tree = $AliasesTree
@onready var old_alias: LineEdit = $AliasesLineEdits/OldAlias
@onready var new_alias: LineEdit = $AliasesLineEdits/NewAlias
@onready var remove_alias_button: Button = $AliasesButtons/RemoveAliasButton
@onready var add_alias_button: Button = $AliasesButtons/AddAliasButton


func _ready():
	old_alias.text_changed.connect(old_alias_update)
	new_alias.text_changed.connect(new_alias_update)
	remove_alias_button.pressed.connect(on_remove_alias_pressed)
	add_alias_button.pressed.connect(on_add_alias_pressed)
	
	old_alias.text_submitted.connect(submit_old_alias)
	new_alias.text_submitted.connect(submit_new_alias)


func on_add_alias_pressed() -> void:
	add_alias(old_alias.text, new_alias.text, false)


func on_remove_alias_pressed() -> void:
	remove_alias(old_alias.text)


func submit_new_alias(text_submitted: String) -> void:
	if not add_alias_button.disabled:
		add_alias(old_alias.text, text_submitted)


func submit_old_alias(text_submitted: String) -> void:
	if not remove_alias_button.disabled:
		remove_alias(text_submitted)


func old_alias_update(new_text: String) -> void:
	if new_text != "":
		if remove_alias_button.disabled:
			remove_alias_button.disabled = false
		if new_alias.text != "" and add_alias_button.disabled:
			add_alias_button.disabled = false
	elif new_text == "":
		if not remove_alias_button.disabled:
			remove_alias_button.disabled = true
		if not add_alias_button.disabled:
			add_alias_button.disabled = true
		

func new_alias_update(new_text: String) -> void:
	if old_alias.text != "" and new_text != "" and add_alias_button.disabled:
		add_alias_button.disabled = false
	elif (old_alias.text == "" or new_text == "") and not add_alias_button.disabled:
		add_alias_button.disabled = true


func add_alias(_old_string: String, _new_string: String, add_from_signal := false) -> void:
	_old_string = _old_string.strip_edges().to_lower()
	_new_string = _new_string.strip_edges().to_lower()
	
	if _old_string.is_empty() or _new_string.is_empty():
		if not add_from_signal:
			old_alias.clear()
			new_alias.clear()
		return

	if Tagger.alias_database.alias_exitst(_old_string, _new_string):
		if not add_from_signal:
			old_alias.clear()
			new_alias.clear()
		return
	
	if Tagger.alias_database.aliases.values().has(_new_string): # Level exists
		var _target_branch = _new_string
		
		var _root: TreeItem = aliases_tree.get_root()
		var _current_branch: TreeItem = _root.get_first_child()
		
		for ignored in range(_root.get_child_count()):
			if _target_branch == _current_branch.get_text(0):
				aliases_tree.create_tree_item(_old_string, _current_branch)
				break
			else:
				_current_branch = _current_branch.get_next()
	else: # Level doesn't exist
		aliases_tree.create_item_and_subitem(_new_string, aliases_tree.get_root(), _old_string)
	
	Tagger.alias_database.add_alias(_old_string, _new_string)
	if not add_from_signal:
		old_alias.clear()
		new_alias.clear()


func remove_alias(_old_string: String) -> void:
	_old_string = old_alias.text.strip_edges().to_lower()
	
	if _old_string.is_empty():
		old_alias.clear()
		return

	if not Tagger.alias_database.has_alias(_old_string):
		old_alias.clear()
		return
	
	var _target_branch = Tagger.alias_database.get_alias(_old_string)
	var _root: TreeItem = aliases_tree.get_root()
	var _level: TreeItem = _root.get_first_child()
	
	for index in range(_root.get_child_count()):
		if _target_branch == _level.get_text(0):
			var _aliases_list = _level.get_first_child()
			
			for ignore in range(_level.get_child_count()):
				if _aliases_list.get_text(0) == _old_string:
					_aliases_list.free()
					if _level.get_child_count() == 0:
						_level.free()
					break
				else:
					_aliases_list = _aliases_list.get_next()
			break
		else:
			_level = _level.get_next()
	
	Tagger.alias_database.remove_alias(_old_string)
	old_alias.clear()

