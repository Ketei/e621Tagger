extends Control


signal template_selected(temp_name, tag_pcksarray, sugs_pcksarray)

var template_item_scene = preload("res://Scenes/template_item_container.tscn")

@onready var items_container: VBoxContainer = $VBoxContainer/ScrollContainer/ItemsContainer
@onready var cancel_load_button: Button = $VBoxContainer/CancelLoadButton


func _ready():
	cancel_load_button.pressed.connect(hide)


func load_templates() -> void:
	for child in items_container.get_children():
		child.template_selected.disconnect(on_template_selected)
		child.queue_free()
	
	for file in DirAccess.get_files_at(Tagger.templates_path):
		var loaded_file: TaglistResource = ResourceLoader.load(Tagger.templates_path + file, "TaglistResource")
		
		if not loaded_file:
			continue
		
		var new_template: TemplateItemContainer = template_item_scene.instantiate()
		new_template.set_template(loaded_file.template_name, loaded_file.template_tags, loaded_file.template_suggestions)
		new_template.template_selected.connect(on_template_selected)
		items_container.add_child(new_template)


func on_template_selected(template_name: String, tags: PackedStringArray, suggestions: PackedStringArray) -> void:
	template_selected.emit(template_name, tags, suggestions)

