extends OptionButton

@onready var final_tag_list: TextEdit = $"../FinalTagList"
@onready var tag_list_generator = %TagListGenerator

func _ready():
	item_selected.connect(change_platform)


func change_platform(index_value: int) -> void:
	Tagger.site_settings.target_site = get_item_id(index_value) as Tagger.Sites
	if not final_tag_list.text.is_empty():
		final_tag_list.text = tag_list_generator.get_tag_list()
