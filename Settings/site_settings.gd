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


static func load_settings(site_settings_path: String) -> SiteSettings:
	if ResourceLoader.exists(site_settings_path, "SiteSettings"):
		var loaded_settings: SiteSettings = ResourceLoader.load(site_settings_path)
		for site_key in loaded_settings.valid_sites.keys():
			if not loaded_settings.valid_sites[site_key].has("separator") or not loaded_settings.valid_sites[site_key].has("whitespace"):
				loaded_settings.valid_sites.erase(site_key)

		if loaded_settings.valid_sites.is_empty():
			loaded_settings.valid_sites = default_sites.duplicate()
		return loaded_settings
	else:
		return SiteSettings.new()


func save() -> void:
	ResourceSaver.save(self, Tagger.site_settings_path)
