class_name PromptTagResource
extends Resource

@export var prompt_list: Dictionary = {
	"Genders": {
		"desc": "",
		"image_tag": "",
		"types": {
			"Male": {
				"tag": "male",
				"desc": "If a character only has apparent [b]male[/b] genitalia or otherwise exclusivly male physical traits that are in some way visible, traits befitting of its species( ex. mane, Antlers...) regardless the body appearance (manly/girly)."
			},
			"Female": {
				"tag": "female",
				"desc": "If a character [b]only[/b] has apparent female genitalia or otherwise exclusively female physical traits that are in some way visible, or traits befitting of its species (ex. breasts/teats, pseudo-penis, eyelashes...) regardless the body appearance (tomboy)."
			},
			"Ambiguous gender": {
				"tag": "ambiguous gender",
				"desc": "Used when the gender of a character in the image is not apparent from the image (no genitals or other clues are visible), and/or when there are mixed signs as to whether the character is male or female (wide hips plus broad shoulders, etc.)."
			},
			"Andromorph": {
				"tag": "andromorph",
				"desc": "An intersex character with a masculine body type, a pussy, but without breasts.\nMasculine characteristics may include wide shoulders, narrow hips, musculature, jaw line, facial hair, and so on. Not to be confused with flat-chested female characters."
			},
			"Gynomorph": {
				"tag": "gynomorph",
				"desc": "An intersex character with a feminine body type, penis / balls, breasts, but no pussy.\nFeminine characteristics may include wide hips, eyelashes, lack of facial hair, and so on. Not to be confused with a herm, who has a pussy in addition to a penis."
			},
			"Hermaphrodite": {
				"tag": "herm",
				"desc": "An intersex character with feminine body type and [b]BOTH[/b] a penis and a pussy. Generally they also have breasts"
			},
			"Male hermaphrodite":
				{
					"tag": "maleherm",
					"desc": "An intersex character with masculine body type and [b]BOTH[/b] a penis and a pussy. Generally they lack breasts"
				}
		}
	},
	"Simple backgrounds":
		{
			"desc": "Images where the background is simplistic and there [b]ISN'T[/b] enough scenery that you can discern the location. Generally just a single color or shape.",
			"image_tag": "simple background",
			"types": {
				"Abstract background": {
					"tag": "abstract background",
					"desc": "Images or animations that don't feature a distinct background. It usually entails having a solid color background with some formless, artistic design or possibly a kind of abstract imagery."
				},
				"Geometric background": {
					"tag": "geometric background",
					"desc": "A background that primarily consists of simple geometric shapes (Circles, polygons, parallelograms, hearts, stars, etc.). It can be one or many."
				},
				"Gradient background": {
					"tag": "gradient background",
					"desc": "A background in which is generally a single color which slowly fades or transitions into a different color, usually black, white, or a deeper shade of the primary color. Sometimes multiple fades or transitions are visible."
				},
				"Monotone background": {
					"tag": "monotone background",
					"desc": "A background consisting of a single, solid(no shades) colour with no details, shapes or patterns."
				},
				"Pattern background": {
					"tag": "pattern background",
					"desc": "A background that has a repeated pattern on it, usualy seen as dots, squares(checkered), lines(stripped), or a pattern that fades/shrinks into a normal unpatterned background(halftone)"
				},
				"Textured background": {
					"tag": "textured background",
					"desc": "Images with a non-repeating, non-geometric pattern for background. Usually seen as textures"
				}
			}
		}
	}


func verify_prompt_list_structure() -> void:
	print("--- Starting PROMPT LIST structure verification ---")
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
		
		for sub_cat in prompt_list[main_category]["types"].keys():
			if not prompt_list[main_category]["types"][sub_cat].has("tag"):
				print("Category \"{0}\", subcategory \"{1}\" is missing entry \"{2}\"".format([main_category, sub_cat, "tag"]))
			else:
				if not typeof(prompt_list[main_category]["types"][sub_cat]["tag"]) == 4:
					print("Category \"{0}\", subcategory \"{1}\", value \"{2}\" is not of type String".format([main_category, sub_cat, "tag"]))
			
			if not prompt_list[main_category]["types"][sub_cat].has("desc"):
				print("Category \"{0}\", subcategory \"{1}\" is missing entry \"{2}\"".format([main_category, sub_cat, "desc"]))
			else:
				if not typeof(prompt_list[main_category]["types"][sub_cat]["desc"]) == 4:
					print("Category \"{0}\", subcategory \"{1}\", value \"{2}\" is not of type String".format([main_category, sub_cat, "desc"]))
	print("--- Finished PROMPT LIST structure verification ---")
