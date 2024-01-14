extends RichTextLabel


signal search_in_wiki(tag_to_search)
signal search_for_special(tag_to_search)

@export var is_on_wiki: bool = false


func _ready():
	meta_clicked.connect(meta_signal_emitted)


func meta_signal_emitted(meta_data) -> void:
	var meta_string: String = str(meta_data)
	if is_on_wiki:
		if meta_string.begins_with("http://") or meta_string.begins_with("https://"):
			OS.shell_open(meta_string)
		elif Tagger.tag_manager.has_tag(meta_string):
			search_in_wiki.emit(meta_string)
		elif meta_string.begins_with("#") or meta_string.begins_with("*") or meta_string.ends_with("*"):
			search_for_special.emit(meta_string)
