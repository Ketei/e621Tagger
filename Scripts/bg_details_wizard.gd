extends OptionButton


@onready var bg_dets_option_button: OptionButton = $"../BGDetsOptionButton"
@onready var day_time_option_button: OptionButton = $"../DayTimeOptionButton"

const simple_bacground: Array = [
	"Abstract background",
	"Spiral background",
	"Geometric background",
	"Heart background",
	"Gradient background",
	"Monotone background",
	"Pattern background",
	"Dotted background",
	"Stripped background",
	"Textured background",
	"Transparent background"
]

const detailed_background: Array = [
	"Inside",
	"Outside"
]


func _ready():
	option_selected(0)
	item_selected.connect(option_selected)


func option_selected(option_index: int) -> void:
	bg_dets_option_button.clear()
	if option_index == 0:
		for bg_item in simple_bacground:
			bg_dets_option_button.add_item(bg_item)
	elif option_index == 1:
		for bg_det in detailed_background:
			bg_dets_option_button.add_item(bg_det)
	
	bg_dets_option_button.select(0)

