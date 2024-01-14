extends HBoxContainer

var suggestion_chkbx_preload = preload("res://Scenes/suggesstion_check_box.tscn")
@onready var flow_container: HFlowContainer = $FlowContainer


var suggestions_dictionary: Dictionary = {
	"eyes": ["*color* eyes", "*color* sclera"],
	"looking at": ["looking at *looking-at*"],
	"looking direction": ["|looking back,looking down,looking up,looking forward,looking aside,looking through|"],
	"penetration": ["*sex-pen* penetration", "*body-type* penetrating *body-type*", "*gender* penetrating *gender*", "*gender* penetrating *body-type*"],
}


func _ready():
	for sug_type in suggestions_dictionary.keys():
		var new_checkbox: SuggetionTagCheckbox = suggestion_chkbx_preload.instantiate()
		new_checkbox.checkbox_tags = suggestions_dictionary[sug_type]
		new_checkbox.text = Utils.better_capitalize(sug_type)
		new_checkbox.tooltip_text = "This includes: " + Utils.array_to_string(suggestions_dictionary[sug_type])
		flow_container.add_child(new_checkbox)
