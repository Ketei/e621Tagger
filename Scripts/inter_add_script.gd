extends HBoxContainer

@onready var add_interact_button: Button = $AddInteractButton
@onready var all_interactions: HBoxContainer = $AllInteractions

var interaction_scene = preload("res://Scenes/interact_selection_item_scene.tscn")


func _ready():
	add_interact_button.pressed.connect(add_interaction)


func add_interaction() -> void:
	var new_interaction = interaction_scene.instantiate()
	all_interactions.add_child(new_interaction)
