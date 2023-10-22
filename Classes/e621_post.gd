class_name e621Post
extends Resource


enum Rating{
	SAFE,
	QUESTIONABLE,
	EXPLICIT
}

var id: int = 0
var description: String = ""
var rating: Rating = Rating.SAFE
var score: Score = Score.new()
var file: File = File.new()
var preview: Preview = Preview.new()
var sample: Sample = Sample.new()
var tags: e6Tags = e6Tags.new()
var sources: Array = []
var pools: Array = []
var relationships: Relationships = Relationships.new()
var flags: Flags = Flags.new()
var fav_count: int = 0

var created_at: String = ""
var updated_at :String = ""

var duration: float = 0.0

func parse_tags(tag_list: Dictionary) -> void:
	for general_tag in tag_list.general:
		tags.general.append(general_tag.replace("_", " "))
	for artist_tag in tag_list.artist:
		tags.artists.append(artist_tag.replace("_", " "))
	for copyright_tag in tag_list.copyright:
		tags.copyright.append(copyright_tag.replace("_", " "))
	for chara_tag in tag_list.character:
		tags.characters.append(chara_tag.replace("_", " "))
	for species_tag in tag_list.species:
		tags.species.append(species_tag.replace("_", " "))
	for invalid_tag in tag_list.invalid:
		tags.invalid.append(invalid_tag.replace("_", " "))
	for meta_tag in tag_list.meta:
		tags.meta.append(meta_tag.replace("_", " "))
	for lore_tag in tag_list.lore:
		tags.lore.append(lore_tag.replace("_", " "))


func set_rating(rating_string: String) -> void:
	if rating_string.to_lower() == "s":
		rating = Rating.SAFE
	elif rating_string.to_lower() == "q":
		rating = Rating.QUESTIONABLE
	else:
		rating = Rating.EXPLICIT


class e6Tags:
	var general: Array[String] = []
	var artists: Array[String] = []
	var copyright: Array[String] = []
	var characters: Array[String] = []
	var species: Array[String] = []
	var meta: Array[String] = []
	var lore: Array[String] = []
	var invalid: Array[String] = []
	var locked: Array[String] = []


class Flags:
	var pending: bool = false
	var flagged: bool = false
	var note_locked: bool = false
	var status_locked: bool = false
	var rating_locked: bool = false
	var deleted: bool = false


class Score:
	var up: int = 0
	var down: int = 0
	var total: int = 0


class Relationships:
	var parent_id: int = 0
	var has_children: bool = false
	var has_active_children: bool = false
	var children: Array


class File:
	var width: int = 0
	var height: int = 0
	var extension: String = ""
	var size: int = 0
	var md5: String = ""
	var url: String = ""


class Preview:
	var width: int = 0
	var height: int = 0
	var url: String = ""


class Sample:
	var has_sample: bool = false
	var height: int = 0
	var width: int = 0
	var url: String = ""
	var alternates: Dictionary = {}
