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


func array_to_string(array_to_stringify: Array, divisor_char: String = ", ") -> String:
	var return_string: String = ""
	
	for item in array_to_stringify:
		return_string += item
		return_string += divisor_char
	
	if not return_string.is_empty():
		return_string = return_string.left(-divisor_char.length())
	
	return return_string


func just_capitalize(input_string: String, body_to_lower: bool = true) -> String:
	var building_string: String = input_string.left(1).to_upper()
	if body_to_lower:
		building_string += input_string.right(-1).to_lower()
	else:
		building_string += input_string.right(-1)
	return building_string
