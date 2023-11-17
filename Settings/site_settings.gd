class_name SiteSettings
extends Resource


@export var default_site: String = ""

@export var valid_sites: Dictionary = {
	"e621": {
		"separator": " ",
		"whitespace": "_"
	},
	"postybirb": {
		"separator": ", ",
		"whitespace": " "
	},
	"hydrus": {
		"separator": "\n",
		"whitespace": " "
	}
}


static var default_sites: Dictionary = {
	"e621": {
		"separator": " ",
		"whitespace": "_"
	},
	"postybirb": {
		"separator": ", ",
		"whitespace": " "
	},
	"hydrus": {
		"separator": "\n",
		"whitespace": " "
	}
}


static func load_settings() -> SiteSettings:

	if ResourceLoader.exists("user://site_settings.tres", "SiteSettings"):
		var loaded_settings: SiteSettings = ResourceLoader.load("user://site_settings.tres")
		
		for site_key in loaded_settings.valid_sites.keys():
			if not loaded_settings.valid_sites.has("separator") or not loaded_settings.valid_sites.has("whitespace"):
				loaded_settings.valid_sites.erase(site_key)
			
		if loaded_settings.valid_sites.is_empty():
			loaded_settings.valid_sites = default_sites.duplicate()
			
		return loaded_settings
	else:
		return SiteSettings.new()


func save() -> void:
	ResourceSaver.save(self, "user://site_settings.tres")
