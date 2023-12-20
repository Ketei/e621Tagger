class_name PromptTagResource
extends Resource

@export var prompt_list: Dictionary = {
	"Backgrounds": {
		"desc": "For all items that are displayed behind the characters/focus in the picture",
		"image_tag": "",
		"types": {
			"Colors": {
				"desc": "The colors that a background can have.",
				"image_tag": "",
				"types": {
					"Black": {
						"desc": "Images with a black background.",
						"tag": "black background"
					},
					"Blue": {
						"desc": "Images with a blue background.",
						"tag": "blue background"
					},
					"Brown": {
						"desc": "Images with a brown background.",
						"tag": "brown background"
					},
					"Green": {
						"desc": "Images with a green background.",
						"tag": "green background"
					},
					"Grey": {
						"desc": "Images with a grey background.",
						"tag": "grey background"
					},
					"Orange": {
						"desc": "Images with an orange background.",
						"tag": "orange background"
					},
					"Pink": {
						"desc": "Images with a pink background.",
						"tag": "pink background"
					},
					"Rainbow": {
						"desc": "Images with a rainbow-colored background.",
						"tag": "rainbow background"
					},
					"Red": {
						"desc": "Images with a red background.",
						"tag": "red background"
					},
					"Tan": {
						"desc": "Images with a tan background.",
						"tag": "tan background"
					},
					"Transparent": {
						"desc": "A background that is transparent or matches the color of whatever it is placed over. This effect is created using an alpha channel (PNG) or a simple transparency (GIF).",
						"tag": "transparent background"
					},
					"White": {
						"desc": "Images with a white background. ",
						"tag": "white background"
					},
					"Yellow": {
						"desc": "Images with a yellow background.",
						"tag": "yellow background"
					}
				}
			},
			"Detailed": {
				"desc": "Any background detailed enough to place the scene in a clearly defined location.",
				"image_tag": "detailed_background",
				"types": {
					"Detailed": {
						"desc": "A background detailed enough to place the scene in a clearly defined location.",
						"tag": "detailed background"
					},
					"Extremely Detailed": {
						"desc": "For images where the background is detailed to an incredible level, where almost no details are lost on distant objects. Comparable to an HD photograph in levels of detail.",
						"tag": "amazing background"
					}
				}
			},
			"Simple": {
				"desc": "Images where the background is simplistic and there [b]ISN'T[/b] enough scenery that you can discern the location. Generally just a single color or shape.",
				"image_tag": "simple background",
				"types": {
					"Abstract background": {
						"desc": "Images or animations that don't feature a distinct background. It usually entails having a solid color background with some formless, artistic design or possibly a kind of abstract imagery.",
						"tag": "abstract background"
					},
					"Geometric background": {
						"desc": "A background that primarily consists of simple geometric shapes (Circles, polygons, parallelograms, hearts, stars, etc.). It can be one or many.",
						"tag": "geometric background"
					},
					"Gradient background": {
						"desc": "A background in which is generally a single color which slowly fades or transitions into a different color, usually black, white, or a deeper shade of the primary color. Sometimes multiple fades or transitions are visible.",
						"tag": "gradient background"
					},
					"Monotone background": {
						"desc": "A background consisting of a single, solid(no shades) colour with no details, shapes or patterns.",
						"tag": "monotone background"
					},
					"Pattern background": {
						"desc": "A background that has a repeated pattern on it, usualy seen as dots, squares(checkered), lines(stripped), or a pattern that fades/shrinks into a normal unpatterned background(halftone)",
						"tag": "pattern background"
					},
					"Textured background": {
						"desc": "Images with a non-repeating, non-geometric pattern for background. Usually seen as textures",
						"tag": "textured background"
					}
				}
			}
		}
	},
	"Characters": {
		"desc": "Tags related to the characters themselves.",
		"image_tag": "",
		"types": {
			"Genders": {
				"desc": "The biological gender of the character displayed.",
				"image_tag": "",
				"types": {
					"Ambiguous gender": {
						"desc": "Used when the gender of a character in the image is not apparent from the image (no genitals or other clues are visible), and/or when there are mixed signs as to whether the character is male or female (wide hips plus broad shoulders, etc.).",
						"tag": "ambiguous gender"
					},
					"Andromorph": {
						"desc": "An intersex character with a masculine body type, a pussy, but without breasts.\nMasculine characteristics may include wide shoulders, narrow hips, musculature, jaw line, facial hair, and so on. Not to be confused with flat-chested female characters.",
						"tag": "andromorph"
					},
					"Female": {
						"desc": "If a character [b]only[/b] has apparent female genitalia or otherwise exclusively female physical traits that are in some way visible, or traits befitting of its species (ex. breasts/teats, pseudo-penis, eyelashes...) regardless the body appearance (tomboy).",
						"tag": "female"
					},
					"Gynomorph": {
						"desc": "An intersex character with a feminine body type, penis / balls, breasts, but no pussy.\nFeminine characteristics may include wide hips, eyelashes, lack of facial hair, and so on. Not to be confused with a herm, who has a pussy in addition to a penis.",
						"tag": "gynomorph"
					},
					"Hermaphrodite": {
						"desc": "An intersex character with feminine body type and [b]BOTH[/b] a penis and a pussy. Generally they also have breasts",
						"tag": "herm"
					},
					"Male": {
						"desc": "If a character only has apparent [b]male[/b] genitalia or otherwise exclusivly male physical traits that are in some way visible, traits befitting of its species( ex. mane, Antlers, etc.) regardless the body appearance (manly/girly).",
						"tag": "male"
					},
					"Male hermaphrodite": {
						"desc": "An intersex character with masculine body type and [b]BOTH[/b] a penis and a pussy. Generally they lack breasts",
						"tag": "maleherm"
					}
				}
			}
		}
	},
	"Topwears": {
		"desc": "A garment that covers the upper body.",
		"image_tag": "topwear",
		"types": {
			"Coats": {
				"desc": "Coats are typically outerwear of the upper body, extending down to hip or further.",
				"image_tag": "coat",
				"types": {
					"Fur coat": {
						"desc": "A coat with the texture of fur.",
						"tag": "fur coat"
					},
					"Lab coat": {
						"desc": "A knee-length overcoat worn by professionals in the medical field or by those involved in laboratory work. The coat protects their street clothes, serves as a simple uniform and is usually white.",
						"tag": "lab coat"
					},
					"Parka": {
						"desc": "An insulated, heavy coat intended for wear in cold, snowy conditions, characterized by its large, furry hood.",
						"tag": "parka"
					},
					"Rain coat": {
						"desc": "A waterproof coat designed to protect the wearer from getting wet.",
						"tag": "raincoat"
					},
					"Trench coat": {
						"desc": "Trench coats are coats that extend all the way down to the lower legs.",
						"tag": "trenchcoat"
					}
				}
			},
			"Jackets": {
				"desc": "Jackets are a piece of clothing that usually end at the hip or higher. They are usually not heavy or as insulated as a coat.",
				"image_tag": "jacket",
				"types": {
					"Blazer": {
						"desc": "A type of jacket resembling a suit jacket, but cut more casually. Blazers often have naval-style metal buttons to reflect their origins as jackets worn by boating club members.",
						"tag": "blazer"
					},
					"Cropped Jacket": {
						"desc": "A cropped jacket describes any kind of jacket that is made to only cover the wearer's chest or upper torso, revealing their midriff.",
						"tag": "cropped jacket"
					},
					"Haori": {
						"desc": "Haori is a traditional Japanese hip- or thigh-length long-sleeved jacket, almost always worn as overwear. The front of haori are not made to close, but may be fastened together with string.",
						"tag": "haori"
					},
					"Leather Jacket": {
						"desc": "A leather jacket is a piece of clothing, commonly associated with bikers and similar folks.",
						"tag": "leather jacket"
					}
				}
			},
			"Shirts": {
				"desc": "A shirt is a cloth garment for the upper body usually featuring a collar, sleeves, and sometimes buttons down the front.",
				"image_tag": "shirt",
				"types": {
					"Blouse": {
						"desc": "Blouse describes a range of loose fitting topwear, generally worn by women in modern \"professional\" settings as a form of casual businesswear. It is typically gathered at the waist or hips so that it hangs loosely (\"blouses\") over the wearer's body.",
						"tag": "blouse"
					},
					"Collared shirt": {
						"desc": "A shirt that features a firm lining of fabric surrounding the neck area. This is a common feature of polo shirts, and dress shirts.",
						"tag": "collared shirt"
					},
					"Crop top": {
						"desc": "Crop top describes any kind of shirt that is made to only cover the upper torso, revealing the wearer's midriff. It should [b]NOT[/b] be applied to:\n[ul]Bandeau\nBikini tops\n\nBras\nTube tops\nSport bras\nTied shirts[/ul]",
						"tag": "crop top"
					},
					"Fishnet shirt": {
						"desc": "A shirt made out of hosiery with an open, diamond shaped knit",
						"tag": "fishnet shirt"
					},
					"T-Shirt": {
						"desc": "A unisex shirt with short sleeves and no collar.",
						"tag": "t-shirt"
					},
					"TankTop": {
						"desc": "A tank top is a shirt manufactured without sleeves, or one where the sleeves have been cut off.",
						"tag": "tank top"
					},
					"Tube top": {
						"desc": "A tube top is a shoulderless, sleeveless garment that wraps around the wearer's upper torso, exposing some or all of the midriff.",
						"tag": "tube top"
					}
				}
			}
		}
	}
}


func verify_prompt_list_structure() -> void:
	print("\n--- Starting PROMPT LIST structure verification ---")
	for main_category in prompt_list.keys():
		if not prompt_list[main_category].has("desc"):
			print("Category \"{0}\" is missing entry \"{1}\" ".format([main_category, "desc"]))
		else:
			if not typeof(prompt_list[main_category]["desc"]) == 4:
				print("Category \"{0}\", entry \"{1}\" is not of type String".format([main_category, "desc"]))
		
		if not prompt_list[main_category].has("image_tag"):
			print("Category \"{0}\" is missing entry \"{1}\" ".format([main_category, "image_tag"]))
		else:
			if not typeof(prompt_list[main_category]["image_tag"]) == 4:
				print("Category \"{0}\", entry \"{1}\" is not of type String".format([main_category, "image_tag"]))
		
		if not prompt_list[main_category].has("types"):
			print("Category \"{0}\", entry \"{1}\" is not of type String".format([main_category, "types"]))
		else:
			if typeof(prompt_list[main_category]["types"]) != 27:
				print("Category \"{0}\", entry \"{1}\" is not of type Dictionary".format([main_category, "types"]))
			else:
				for sub_cat in prompt_list[main_category]["types"].keys():
					if not prompt_list[main_category]["types"][sub_cat].has("desc"):
						print("Category \"{0}\", subcategory \"{1}\" is missing entry \"{2}\"".format([main_category, sub_cat, "desc"]))
					else:
						if not typeof(prompt_list[main_category]["types"][sub_cat]["desc"]) == 4:
							print("Category \"{0}\", subcategory \"{1}\", value \"{2}\" is not of type String".format([main_category, sub_cat, "desc"]))
					if not prompt_list[main_category]["types"][sub_cat].has("image_tag"):
						print("Category \"{0}\", subcategory \"{1}\" is missing entry \"{2}\"".format([main_category, sub_cat, "image_tag"]))
					
					if not prompt_list[main_category]["types"][sub_cat].has("types"):
						print("Category \"{0}\", subcategory \"{1}\" is missing entry \"{2}\"".format([main_category, sub_cat, "types"]))
					else:
						if typeof(prompt_list[main_category]["types"][sub_cat]["types"]) != 27:
							print("Category \"{0}\", subcategory \"{1}\", entry \"{2}\" is not of type Dictionary".format([main_category, sub_cat, "types"]))
						else:
							for specific_type in prompt_list[main_category]["types"][sub_cat]["types"].keys():
								if not prompt_list[main_category]["types"][sub_cat]["types"][specific_type].has("tag"):
									print("Category \"{0}\", subcategory \"{1}\", item \"{2}\" is missing entry \"{3}\"".format([main_category, sub_cat, specific_type, "tag"]))
								else:
									if typeof(prompt_list[main_category]["types"][sub_cat]["types"][specific_type]["tag"]) != 4:
										print("Category \"{0}\", subcategory \"{1}\", item \"{2}\" is not of type String".format([main_category, sub_cat, specific_type]))
								
								if not prompt_list[main_category]["types"][sub_cat]["types"][specific_type].has("desc"):
									print("Category \"{0}\", subcategory \"{1}\", item \"{2}\" is missing entry \"{3}\"".format([main_category, sub_cat, specific_type, "desc"]))
								else:
									if typeof(prompt_list[main_category]["types"][sub_cat]["types"][specific_type]["desc"]) != 4:
										print("Category \"{0}\", subcategory \"{1}\", item \"{2}\" is not of type String".format([main_category, sub_cat, specific_type]))
	print("--- Finished PROMPT LIST structure verification ---\n")


func register_category(category_name: String, desc := "", image_tag := "") -> void:
	category_name = Utils.just_capitalize(category_name)
	if prompt_list.has(category_name):
		return
	
	prompt_list[category_name] = {
		"image_tag": image_tag,
		"desc": desc,
		"types": {}
	}
	

func register_subcategory(category_name: String, subcategory: String, desc := "", image_tag := "") -> void:
	if not prompt_list.has(category_name):
		return
	
	if prompt_list[category_name]["types"].has(subcategory):
		return
	
	prompt_list[category_name]["types"][subcategory] = {
		"desc": desc,
		"image_tag": image_tag,
		"types": {}
	}


func register_title(category: String, subcat: String, title: String, tag: String, desc := "") -> void:
	if not prompt_list.has(category):
		return
	
	if not prompt_list[category]["types"].has(subcat):
		return
	
	if prompt_list[category]["types"][subcat]["types"].has(title):
		return
	
	prompt_list[category]["types"][subcat]["types"][title] = {
		"tag": tag,
		"desc": desc
	}


func save() -> void:
	ResourceSaver.save(self, Tagger.settings.database_location + "prompt_tags.tres")
