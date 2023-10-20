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
	POSTYBIRB,
	HYDRUS,
}


var e6_headers_data: Dictionary = {
	"User-Agent": "TaglistMaker/0.5.1 (by Ketei)",
}


const implications_path: String = "user://database/implications/"
const tags_path: String = "user://database/tags/"
const tag_images_path: String = "user://database/tag_images/"
const api_file_path: String = "user://e621_key.txt"

var alias_database: AliasDatabase
var settings: UserSettings
var site_settings: SiteSettings
var tag_manager: TagManager
var settings_lists: SettingLists
var headers_ini: ConfigFile


func _init():
	verify_folder_structure()
	tag_manager = TagManager.load_database()
	settings = UserSettings.load_settings()
	site_settings = SiteSettings.load_settings()
	alias_database = AliasDatabase.load_database()
	settings_lists = SettingLists.load_database()


func verify_folder_structure() -> void:
	# Check if the database folder exists
	if not DirAccess.dir_exists_absolute("user://database"):
		DirAccess.make_dir_absolute("user://database")
	
	if not DirAccess.dir_exists_absolute(tags_path):
		DirAccess.make_dir_absolute(tags_path)
	
	if not DirAccess.dir_exists_absolute(implications_path):
		DirAccess.make_dir_absolute(implications_path)
	
	if not DirAccess.dir_exists_absolute(tag_images_path):
		DirAccess.make_dir_absolute(tag_images_path)
		

func get_headers() -> Array:
	var return_headers: Array = []
	for header_type in e6_headers_data.keys():
		return_headers.append(header_type + ": " + e6_headers_data[header_type])
	return return_headers
