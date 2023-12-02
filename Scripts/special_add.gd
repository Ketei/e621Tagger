class_name PromptAddTag
extends PanelContainer


signal item_selected(tag_to_add: String)

var item_options: Dictionary = {}

@onready var image_texture: TextureRect = $GeneralContainer/PictureContainer/ImageTexture

@onready var general_item_options: OptionButton = $GeneralContainer/DataContainer/VBoxContainer/GeneralItemOptions
@onready var generic_item_desc: RichTextLabel = $GeneralContainer/DataContainer/VBoxContainer/GenericItemDesc
@onready var specific_item_button: OptionButton = $GeneralContainer/DataContainer/VBoxContainer/SpecificItemButton
@onready var specific_item_desc: RichTextLabel = $GeneralContainer/DataContainer/VBoxContainer/SpecificItemDesc

@onready var cancel_button: Button = $GeneralContainer/DataContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var accept_button: Button = $GeneralContainer/DataContainer/VBoxContainer/ButtonsContainer/AcceptButton


func _ready():
	item_options = Tagger.prompt_resources.prompt_list
	general_item_options.item_selected.connect(on_gen_item_selected)
	specific_item_button.item_selected.connect(on_spec_item_selected)
	accept_button.pressed.connect(on_submit_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)
	for gen_cat in item_options.keys():
		general_item_options.add_item(gen_cat)
	general_item_options.get_popup().max_size = Vector2(350, 144)
	specific_item_button.get_popup().max_size = Vector2(350, 144)
	general_item_options.select(-1)


func on_gen_item_selected(_index_selected: int) -> void:
	image_texture.texture = null
	var define_pic: String = ""
	var target_key: String = get_option_selected(general_item_options)
	generic_item_desc.get_v_scroll_bar().value = 0
	specific_item_desc.clear()
	if  not item_options[target_key]["image_tag"].is_empty():
		for extension in Tagger.valid_textures:
			if FileAccess.file_exists(Tagger.tag_images_path + item_options[target_key]["image_tag"] + "/define." + extension):
				define_pic = "define." + extension
				break
	var image_path: String = Tagger.tag_images_path +\
			item_options[target_key]["image_tag"] +\
			"/" + define_pic
	if not define_pic.is_empty():
		if define_pic.get_extension() == "gif":
			var gif: AnimatedTexture = GifManager.animated_texture_from_file(image_path, 256)
			image_texture.texture = gif
		else:
			var image := Image.load_from_file(image_path)
			image_texture.texture = ImageTexture.create_from_image(image)
	specific_item_button.clear()
	generic_item_desc.text = item_options[target_key]["desc"]
	for spec_item in item_options[target_key]["types"].keys():
		specific_item_button.add_item(spec_item)
	if 0 < specific_item_button.item_count:
		specific_item_button.select(-1)


func on_spec_item_selected(_index_selected: int) -> void:
	image_texture.texture = null
	specific_item_desc.get_v_scroll_bar().value = 0
	var define_pic: String = ""
	var gen_target_key: String = get_option_selected(general_item_options)
	var spec_target_key: String = get_option_selected(specific_item_button)
	specific_item_desc.text = item_options[gen_target_key]["types"][spec_target_key]["desc"]

	if  not item_options[gen_target_key]["types"][spec_target_key]["tag"].is_empty():
		for extension in Tagger.valid_textures:
			if FileAccess.file_exists(Tagger.tag_images_path + item_options[gen_target_key]["types"][spec_target_key]["tag"] + "/define." + extension):
				define_pic = "define." + extension
				break
	
	var image_path: String = Tagger.tag_images_path +\
			item_options[gen_target_key]["types"][spec_target_key]["tag"] +\
			"/" + define_pic
	
	if not define_pic.is_empty():
		if define_pic.get_extension() == "gif":
			var gif: AnimatedTexture = GifManager.animated_texture_from_file(image_path, 256)
			image_texture.texture = gif
		else:
			var image := Image.load_from_file(image_path)
			image_texture.texture = ImageTexture.create_from_image(image)


func on_submit_pressed() -> void:
	if is_selection_valid():
		item_selected.emit(
			item_options
					[
						get_option_selected(general_item_options)
					][
						"types"
					][
						get_option_selected(specific_item_button)
					][
						"tag"
					])
	else:
		item_selected.emit("")
	image_texture.texture = null


func on_cancel_pressed() -> void:
	item_selected.emit("")
	image_texture.texture = null


func get_option_selected(opt_button: OptionButton) -> String:
	return opt_button.get_item_text(opt_button.selected)


func is_selection_valid() -> bool:
	return general_item_options.selected != -1 and specific_item_button.selected != -1


func reset_selections() -> void:
	general_item_options.select(-1)
	specific_item_button.select(-1)
	generic_item_desc.clear()
	specific_item_desc.clear()
	image_texture.texture = null


