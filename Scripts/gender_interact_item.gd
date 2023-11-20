extends HBoxContainer

var final_selection: String = ""

@onready var submissive_opt_btn: OptionButton = $ReceivingGenderOptionButton
@onready var accept_button: Button = $AcceptButton
@onready var giving_label: Label = $GivingLabel
@onready var receiving_label: Label = $ReceivingLabel
@onready var giving_gender_option_button: OptionButton = $GivingGenderOptionButton

var edit_mode: bool = true

const correct_interactions: Dictionary = {
	"male/male": "male/male",
	"male/female": "male/female",
	"male/ambiguous": "male/ambiguous",
	"male/andromorph": "andromorph/male",
	"male/gynomorph": "gynomorph/male",
	"male/herm": "herm/male",
	"male/maleherm": "maleherm/male",
	"female/male": "male/female",
	"female/female": "female/female",
	"female/ambiguous": "female/ambiguous",
	"female/andromorph": "andromorph/female",
	"female/gynomorph": "gynomorph/female",
	"female/herm": "herm/female",
	"female/maleherm": "maleherm/female",
	"ambiguous/male": "male/ambiguous",
	"ambiguous/female": "female/ambiguous",
	"ambiguous/ambiguous": "ambiguous/ambiguous",
	"ambiguous/andromorph": "andromorph/ambiguous",
	"ambiguous/gynomorph": "gynomorph/ambiguous",
	"ambiguous/herm": "herm/ambiguous",
	"ambiguous/maleherm": "maleherm/ambiguous",
	"andromorph/male": "andromorph/male",
	"andromorph/female": "andromorph/female",
	"andromorph/ambiguous": "andromorph/ambiguous",
	"andromorph/andromorph": "andromorph/andromorph",
	"andromorph/gynomorph": "gynomorph/andromorph",
	"andromorph/herm": "herm/andromorph",
	"andromorph/maleherm": "maleherm/andromorph",
	"gynomorph/male": "gynomorph/male",
	"gynomorph/female": "gynomorph/female",
	"gynomorph/ambiguous": "gynomorph/ambiguous",
	"gynomorph/andromorph": "gynomorph/andromorph",
	"gynomorph/gynomorph": "gynomorph/gynomorph",
	"gynomorph/herm": "gynomorph/herm",
	"gynomorph/maleherm": "maleherm/gynomorph",
	"herm/male": "herm/male",
	"herm/female": "herm/female",
	"herm/ambiguous": "herm/ambiguous",
	"herm/andromorph": "herm/andromorph",
	"herm/gynomorph": "gynomorph/herm",
	"herm/herm": "herm/herm",
	"herm/maleherm": "maleherm/herm",
	"maleherm/male": "maleherm/male",
	"maleherm/female": "maleherm/female",
	"maleherm/ambiguous": "maleherm/ambiguous",
	"maleherm/andromorph": "maleherm/andromorph",
	"maleherm/gynomorph": "maleherm/gynomorph",
	"maleherm/herm": "maleherm/herm",
	"maleherm/maleherm": "maleherm/maleherm"
}



func _ready():
	accept_button.pressed.connect(save_pressed)


func save_pressed() -> void:
	if edit_mode:
		var string_make: String = giving_gender_option_button.get_item_text(giving_gender_option_button.selected) + "/" + submissive_opt_btn.get_item_text(submissive_opt_btn.selected)
		final_selection = correct_interactions[string_make]
		accept_button.text = "x"
		var giv_receive: Array = final_selection.split("/")
		giving_label.text = giv_receive[0]
		receiving_label.text = giv_receive[1]
		giving_label.show()
		receiving_label.show()
		giving_gender_option_button.hide()
		submissive_opt_btn.hide()
		edit_mode = false
		custom_minimum_size.x = 0
	else:
		queue_free()
