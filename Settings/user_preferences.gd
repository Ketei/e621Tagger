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
@export var e621_review_amount: int = 4

@export var load_review_local: bool = false
@export var local_review_amount: int = 4

@export var file_version: String = "1.0"

static var settings_version: String = "1.0" 


func can_load_from_e6() -> bool:
	return load_review_e621 and load_review_images


func can_load_from_local() -> bool:
	return load_review_local and load_review_images


static func load_settings() -> UserSettings:
	var settings_load: UserSettings
	
	if ResourceLoader.exists("user://user_settings.tres", "UserSettings"):
		var quick_load = ResourceLoader.load("user://user_settings.tres")
		if quick_load.file_version != UserSettings.settings_version:
			settings_load = UserSettings.new()
		else:
			settings_load = quick_load
	else:
		settings_load = UserSettings.new()
	
	return settings_load


func save() -> void:
	ResourceSaver.save(self, "user://user_settings.tres")

