extends Node


signal register_aliases(old_alias, new_alias)
signal reload_prompts

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
	LOCATION,
	FURNITURE,
	LORE,
}
const CategorySorting: Array = [
	Categories.GENERAL,
	Categories.ARTIST,
	Categories.COPYRIGHT,
	Categories.CHARACTER,
	Categories.SPECIES,
	Categories.GENDER,
	Categories.BODY_TYPES,
	Categories.ANATOMY,
	Categories.MARKINGS,
	Categories.POSES_AND_STANCES,
	Categories.ACTIONS_AND_INTERACTIONS,
	Categories.SEX_AND_POSITIONS,
	Categories.PENETRATION,
	Categories.FLUIDS,
	Categories.EXPRESSIONS,
	Categories.COLORS,
	Categories.OBJECTS,
	Categories.CLOTHING,
	Categories.ACCESSORIES,
	Categories.FURNITURE,
	Categories.PROFESSION,
	Categories.LOCATION,
	Categories.META,
	Categories.LORE,
]


enum Sites {
	E621,
	POSTYBIRB,
	HYDRUS,
}

enum Notifications {
	SITES_UPDATED,
}


var e6_headers_data: Dictionary = {
	"User-Agent": "TaglistMaker/1.1.0 (by Ketei)",
}

const valid_textures: Array[String] = ["jpg", "png", "gif"]
const valid_videos: Array[String] = ["ogv"]

var implications_path: String = "user://database/implications/"
var tags_path: String = "user://database/tags/"
var tag_images_path: String = "user://database/tag_images/"
var templates_path: String = "user://database/templates/"
var lists_path: String = "user://database/lists.tres"
var site_settings_path: String = "user://database/sites.tres"
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
var prompt_resources: PromptTagResource

func _init():
	settings = UserSettings.load_settings()
	
	implications_path = settings.database_location + "implications/"
	tags_path = settings.database_location + "tags/"
	tag_images_path = settings.database_location + "tag_images/"
	templates_path = settings.database_location + "templates/"
	lists_path = settings.database_location + "lists.tres"
	site_settings_path = settings.database_location + "sites.tres"
	
	verify_folder_structure()
	
	tag_manager = TagManager.load_database(implications_path)
	site_settings = SiteSettings.load_settings(settings.database_location + "sites.tres")
	alias_database = AliasDatabase.load_database(settings.database_location)
	settings_lists = SettingLists.load_database(settings.database_location + "lists.tres")
	
	if ResourceLoader.exists(settings.database_location + "prompt_tags.tres", "PromptTagResource"):
		prompt_resources = ResourceLoader.load(settings.database_location + "prompt_tags.tres")
		prompt_resources.verify_prompt_list_structure()
	else:
		prompt_resources = PromptTagResource.new()
		ResourceSaver.save(prompt_resources, settings.database_location + "prompt_tags.tres")
	
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
	
	if not DirAccess.dir_exists_absolute(templates_path):
		DirAccess.make_dir_absolute(templates_path)


func get_headers() -> Array:
	var return_headers: Array = []
	for header_type in e6_headers_data.keys():
		return_headers.append(header_type + ": " + e6_headers_data[header_type])
	return return_headers


func implication_reload() -> void:
	tag_manager = TagManager.load_database(implications_path)

