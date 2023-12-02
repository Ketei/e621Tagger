extends PanelContainer


signal item_selected(tag_to_add: String)

var item_options: Dictionary = {
	"piercings":
			{
				"description": "Description for piercing",
				"image": "",
				"types": {
					"ring": {
						"tag": "tag ring",
						"description": "ring description",
						"image": ""
					},
					"another type": {
						"tag": "tag another type",
						"description": "another type description",
						"image": ""
					}
				}
			}
		}

@onready var image_texture: TextureRect = $GeneralContainer/PictureContainer/ImageTexture

@onready var general_item_options: OptionButton = $GeneralContainer/DataContainer/VBoxContainer/GeneralItemOptions
@onready var generic_item_desc: RichTextLabel = $GeneralContainer/DataContainer/VBoxContainer/GenericItemDesc
@onready var specific_item_button: OptionButton = $GeneralContainer/DataContainer/VBoxContainer/SpecificItemButton
@onready var specific_item_desc: RichTextLabel = $GeneralContainer/DataContainer/VBoxContainer/SpecificItemDesc

@onready var cancel_button: Button = $GeneralContainer/DataContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var accept_button: Button = $GeneralContainer/DataContainer/VBoxContainer/ButtonsContainer/AcceptButton


func _ready():
	general_item_options.item_selected.connect(on_gen_item_selected)
	specific_item_button.item_selected.connect(on_spec_item_selected)
	accept_button.pressed.connect(on_submit_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)
	general_item_options.get_popup().max_size.y = 144
	specific_item_button.get_popup().max_size.y = 144
	for gen_cat in item_options.keys():
		general_item_options.add_item(gen_cat)
	if 0 < general_item_options.item_count:
		general_item_options.select(0)
		general_item_options.item_selected.emit(0)


func on_gen_item_selected(_index_selected: int) -> void:
	var target_key: String = get_option_selected(general_item_options)
	var path_to_load: String = item_options[target_key]["image"]
	if not path_to_load.is_empty():
		image_texture.texture = load(path_to_load)
	specific_item_button.clear()
	generic_item_desc.text = item_options[target_key]["description"]
	for spec_item in item_options[target_key]["types"].keys():
		specific_item_button.add_item(spec_item)
	if 0 < specific_item_button.item_count:
		specific_item_button.select(0)
		specific_item_button.item_selected.emit(0)


func on_spec_item_selected(_index_selected: int) -> void:
	var gen_target_key: String = get_option_selected(general_item_options)
	var spec_target_key: String = get_option_selected(specific_item_button)
	specific_item_desc.text = item_options[gen_target_key]["types"][spec_target_key]["description"]
	var path_to_load: String = item_options[gen_target_key]["types"][spec_target_key]["image"]
	if not path_to_load.is_empty():
		image_texture.texture = load(path_to_load)


func on_submit_pressed() -> void:
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
	print(item_options
				[
					get_option_selected(general_item_options)
				][
					"types"
				][
					get_option_selected(specific_item_button)
				][
					"tag"
				])


func on_cancel_pressed() -> void:
	item_selected.emit("")


func get_option_selected(opt_button: OptionButton) -> String:
	return opt_button.get_item_text(opt_button.selected)

