extends HBoxContainer

var final_selection: String = ""

@onready var submissive_opt_btn: OptionButton = $ReceivingOptionButton
@onready var accept_button: Button = $AcceptButton
@onready var giving_label: Label = $GivingLabel
@onready var receiving_label: Label = $ReceivingLabel
@onready var giving_gender_option_button: OptionButton = $GivingGenderOptionButton

var edit_mode: bool = true


var possible_interactions: Dictionary = {
	"male": ["male", "female", "ambiguous"],
	"female": ["female", "ambiguous"],
	"andromorph": ["male", "female", "ambiguous", "andromorph", "gynomorph"],
	"gynomorph": ["male", "female", "ambiguous", "gynomorph", "herm"],
	"herm": ["male", "female", "herm", "andromorph", "ambiguous"],
	"maleherm": ["male", "female", "ambiguous", "andromorph", "gynomorph", "herm", "maleherm"]
}


func _ready():
	for gender in possible_interactions.keys():
		giving_gender_option_button.add_item(gender)
	giving_gender_option_button.select(-1)
	
	giving_gender_option_button.item_selected.connect(gender_selected)
	accept_button.pressed.connect(save_pressed)


func gender_selected(item_index: int) -> void:
	submissive_opt_btn.clear()
	for possibility in possible_interactions[giving_gender_option_button.get_item_text(item_index)]:
		submissive_opt_btn.add_item(possibility)
	submissive_opt_btn.select(0)
	if submissive_opt_btn.disabled:
		submissive_opt_btn.disabled = false


func save_pressed() -> void:
	if edit_mode:
		final_selection = giving_gender_option_button.get_item_text(giving_gender_option_button.selected) + "/" + submissive_opt_btn.get_item_text(submissive_opt_btn.selected)
		accept_button.text = "x"
		giving_label.text = giving_gender_option_button.get_item_text(giving_gender_option_button.selected)
		receiving_label.text = submissive_opt_btn.get_item_text(submissive_opt_btn.selected)
		giving_label.show()
		receiving_label.show()
		giving_gender_option_button.hide()
		submissive_opt_btn.hide()
		edit_mode = false
		custom_minimum_size.x = 0
	else:
		queue_free()
