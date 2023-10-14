extends Node

enum Categories {
	GENERAL,
	ARTIST,
	SERIES,
	CHARACTER,
	SPECIES,
	GENDER,
	LORE,
	GENITALS,
	OBJECTS,
	CLOTHING,
	ACCESSORIES,
}

enum Sites {
	E621,
	POSTYBIRB
}


var alias_database: AliasDatabase
var settings: UserSettings
var site_settings: SiteSettings
var tag_manager: TagManager

const e6_headers: Array = ["User-Agent: Taglist Maker/v0.2.0 (by Ketei)"] 
const implications_path: String = "user://database/implications/"
const tags_path: String = "user://database/tags/"

func _init():
	verify_folder_structure()
	tag_manager = TagManager.load_database()
	settings = UserSettings.load_settings()
	site_settings = SiteSettings.load_settings()
	alias_database = AliasDatabase.load_database()


func verify_folder_structure() -> void:
	# Check if the database folder exists
	if not DirAccess.dir_exists_absolute("user://database"):
		DirAccess.make_dir_absolute("user://database")
	
	if not DirAccess.dir_exists_absolute("user://database/tags"):
		DirAccess.make_dir_absolute("user://database/tags")
	
	if not DirAccess.dir_exists_absolute("user://database/implications"):
		DirAccess.make_dir_absolute("user://database/implications")

