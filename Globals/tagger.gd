extends Node

enum Categories {
	GENERAL,
	ARTIST,
	COPYRIGHT,
	CHARACTER,
	SPECIES,
	GENDER,
	BODY_TYPES,
	ANATOMY,
	MARKINGS,
	POSES_AND_STANCES,
	ACTIONS_AND_INTERACTIONS,
	SEX_AND_POSITIONS,
	PENETRATION,
	FLUIDS,
	EXPRESSIONS,
	COLORS,
	OBJECTS,
	CLOTHING,
	ACCESSORIES,
	PROFESSION,
	META,
}

enum Sites {
	E621,
	POSTYBIRB,
	HYDRUS,
}

enum Notifications {
	SITES_UPDATED,
}


var e6_headers_data: Dictionary = {
	"User-Agent": "TaglistMaker/0.9.7 (by Ketei)",
}


var implications_path: String = "user://database/implications/"
var tags_path: String = "user://database/tags/"
var tag_images_path: String = "user://database/tag_images/"
const api_file_path: String = "user://e621_key.txt"
const tag_exports_folder: String = "user://tag_exports/"


var alias_database: AliasDatabase
var settings: UserSettings
var site_settings: SiteSettings
var tag_manager: TagManager
var settings_lists: SettingLists
var headers_ini: ConfigFile

var common_thread: Thread

var available_sites: Array[String] = []


func _init():
	settings = UserSettings.load_settings()
	
	implications_path = settings.database_location + "implications/"
	tags_path = settings.database_location + "tags/"
	tag_images_path = settings.database_location + "tag_images/"
	
	verify_folder_structure()
	
	tag_manager = TagManager.load_database(implications_path)
	site_settings = SiteSettings.load_settings()
	alias_database = AliasDatabase.load_database(settings.database_location)
	settings_lists = SettingLists.load_database()
	
	for site in site_settings.valid_sites.keys():
		available_sites.append(site)


func _ready():
	common_thread = Thread.new()


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
	
	if not DirAccess.dir_exists_absolute(tag_exports_folder):
		DirAccess.make_dir_absolute(tag_exports_folder)


func get_headers() -> Array:
	var return_headers: Array = []
	for header_type in e6_headers_data.keys():
		return_headers.append(header_type + ": " + e6_headers_data[header_type])
	return return_headers

