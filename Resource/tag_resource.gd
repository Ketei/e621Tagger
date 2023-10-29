extends Resource
class_name Tag
## A resource that holds all informationa bout a tag.   
## Characters shouldn't never hold the gender as a parent or the species as 
## parent if the character has multiple forms.

## The name of the tag. Please note that whitespaces in tags should be a
## whitespace and not any other symbol like "_" or "-".
@export var tag: String = "":
	set(new_name):
		tag = new_name.to_lower()

## The name of the file the tag has. This is because some tags have symbols that
## are invalid in filenames like "?" and "<".
@export var file_name: String = ""

## The priority of the tag. A higher priority means it'll be added to the list
## earlier.
@export var tag_priority: int = 0

## Useful for searching tag types and warnings.
@export var category: Tagger.Categories = Tagger.Categories.GENERAL

## The tags that this tag SHOULD go along with. Ex. "male/male" should go with
## "male".
@export var parents: Array = []

## The tags that this tag SHOULDN'T be used along with. Ex. "solo" shouldn't go
## with "duo". This will only show on look-up.
@export var conflicts: Array[String] = []

## The tags that this tag is likely to go along with. Ex. "Vaporeon"s USUALLY
## have "blue body"s.
@export var suggestions: Array[String] = []

## If true the reviewer will look for pictures to load. If false it won't bother
## looking for files.
@export var has_pictures: bool = true

## Unused for now. Planed for different sites but will likely be removed.
@export var variants: Dictionary = {}

## A short description to be showed on hovering the tag on the tagger window.
@export var tooltip: String = ""

## Information about the tag. This is for people to read at review.
@export var wiki_entry: String = ""

## Saves the resource to user path.
func save() -> String:
	if file_name.is_empty():
		file_name = tag + ".tres"
		if not file_name.is_valid_filename():
			file_name = file_name.validate_filename()
	
	ResourceSaver.save(self, "user://database/tags/" + file_name)
	return file_name

## Gets the tag name appropiate for the site selected. Will be removed most likely.
func get_tag() -> String:
	if variants.has(str(Tagger.settings.target_site)):
		return variants[Tagger.settings.target_site]
	else:
		return tag

