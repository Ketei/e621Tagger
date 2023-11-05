extends RichTextLabel


signal search_in_wiki(tag_to_search)


func _ready():
	meta_clicked.connect(meta_signal_emitted)


func meta_signal_emitted(meta_data) -> void:
	var meta_string: String = str(meta_data)
	
	if meta_string.begins_with("http://") or meta_string.begins_with("https://"):
		OS.shell_open(meta_string)
	elif Tagger.tag_manager.has_tag(meta_string):
		search_in_wiki.emit(meta_string)

