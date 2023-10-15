class_name SiteSettings
extends Resource


@export var target_site: Tagger.Sites = Tagger.Sites.E621:
	set(new_target):
		target_site = new_target
		whitespace_char = _site_formatting[str(new_target)].whitespace
		tag_separator = _site_formatting[str(new_target)].separator

@export var _site_formatting: Dictionary = {
	"0": {
		"whitespace": "_",
		"separator": " "
		},
	"1": {
		"whitespace": " ",
		"separator": ", "
	},
	"2": {
		"whitespace": " ",
		"separator": "\n"
	},
}


@export var whitespace_char: String = "_"
@export var tag_separator: String = " "


static func load_settings() -> SiteSettings:
	var site_formatting_settings: Dictionary = {
		"0": {
			"whitespace": "_",
			"separator": " "
			},
		"1": {
			"whitespace": " ",
			"separator": ", "
		},
		"2": {
			"whitespace": " ",
			"separator": "\n"
		},
	}

	if ResourceLoader.exists("user://site_settings.tres", "SiteSettings"):
		var loaded_settings: SiteSettings = ResourceLoader.load("user://site_settings.tres")
		for site_key in site_formatting_settings.keys():
			if not loaded_settings._site_formatting.has(site_key):
				loaded_settings._site_formatting[site_key] = site_formatting_settings[site_key].duplicate()
				loaded_settings.save()
		return loaded_settings
	else:
		return SiteSettings.new()


func save() -> void:
	ResourceSaver.save(self, "user://site_settings.tres")
