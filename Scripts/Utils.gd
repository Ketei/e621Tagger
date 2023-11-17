extends Node


var integers: Array[String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]


func better_capitalize(what: String, underscore_to_spaces: bool = false, separate_numbers_from_letters: bool = false) -> String:
	var first_letter: String = what.left(1).to_upper()
	
	var rest_of_string = what.erase(0, 1)
	
	var construct_string: String = first_letter
	
	for character in rest_of_string:
		if separate_numbers_from_letters:
			if not construct_string.right(1) in integers and character in integers:
				construct_string += " "
			elif construct_string.right(1) in integers and not character in integers:
				construct_string += " "
		
		if character == "_" and underscore_to_spaces:
			character = " "

		construct_string += character
	
	return construct_string

