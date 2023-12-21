class_name UserSettings
extends Resource

@export var target_site: Tagger.Sites = Tagger.Sites.E621
@export var suggestion_strength: float = 50.0

## A blacklist of tags to ignore. Examples are "hi_res" or "animated"

@export var search_suggested: bool = true
@export var load_suggested: bool = true

@export var tag_search_setting: int = 0

@export var load_review_images: bool = false

@export var load_review_e621: bool = false
@export var e621_review_amount: int = 2

@export var load_review_local: bool = false
@export var local_review_amount: int = 6

@export var load_wiki_hydrus: bool = false
@export var hydrus_review_amount: int = 6
@export var load_hydrus_gifs: bool = false

@export var hydrus_remember_data: bool = false
@export var hydrus_port: int = 0
@export var hydrus_key: String = ""

@export var hydrus_connect_on_load: bool = false

@export var remove_prompt_sugg_on_use: bool = true

@export var file_version: String = "1.0"

@export var open_tag_folder_on_creation: bool = false

@export var load_web_gifs: bool = false
@export var load_local_gifs: bool = true
@export_range(1, 3, 1) var picture_columns_to_search: int = 2

@export var delete_with_pictures: bool = false
@export var category_color_code: Dictionary = {
	"GENERAL": "cccccc",
	"ARTIST": "f2ac08",
	"COPYRIGHT": "e769e6",
	"CHARACTER": "00b900",
	"SPECIES": "ed5d1f",
	"GENDER": "3478d6",
	"BODY_TYPES": "cccccc",
	"ANATOMY": "cccccc",
	"MARKINGS": "cccccc",
	"POSES_AND_STANCES": "cccccc",
	"ACTIONS_AND_INTERACTIONS": "cccccc",
	"SEX_AND_POSITIONS": "cccccc",
	"PENETRATION": "cccccc",
	"FLUIDS": "cccccc",
	"EXPRESSIONS": "cccccc",
	"COLORS": "cccccc",
	"OBJECTS": "cccccc",
	"CLOTHING": "cccccc",
	"ACCESSORIES": "cccccc",
	"PROFESSION": "cccccc",
	"INVALID": "cccccc",
	"META": "ffffff",
}

@export var default_save_path: String = ""

@export var database_location: String = "user://database/"


static var settings_version: String = "1.0" 


func can_load_from_e6() -> bool:
	return load_review_e621 and load_review_images


func can_load_from_local() -> bool:
	return load_review_local and load_review_images


static func load_settings() -> UserSettings:
	var settings_load: UserSettings
	
	if ResourceLoader.exists("user://user_settings.tres", "UserSettings"):
		settings_load = ResourceLoader.load("user://user_settings.tres", "UserSettings")
		for color_cat in Tagger.Categories.keys():
			if settings_load.category_color_code.has(color_cat):
				if not Color.html_is_valid(settings_load.category_color_code[color_cat]):
					settings_load.category_color_code[color_cat] = "cccccc"
			else:
				settings_load.category_color_code[color_cat] = "cccccc"
		if not DirAccess.dir_exists_absolute(settings_load.default_save_path) or settings_load.default_save_path.is_empty():
			settings_load.default_save_path = ProjectSettings.globalize_path(Tagger.tag_exports_folder)
		if not settings_load.default_save_path.ends_with("/"):
			settings_load.default_save_path += "/"
	else:
		settings_load = UserSettings.new()
	
	return settings_load


func save() -> void:
	ResourceSaver.save(self, "user://user_settings.tres")
	
