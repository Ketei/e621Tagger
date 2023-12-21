extends HBoxContainer

#@onready var h_slider: HSlider = $HSlider
@onready var strength_value_spinbox: SpinBox = $PercentageSpinBox


func _ready():
	#h_slider.drag_ended.connect(_drag_ended)
	#h_slider.value_changed.connect(_display_update)
	strength_value_spinbox.value_changed.connect(_update_percentage)


func _update_percentage(new_value: int) -> void:
	#h_slider.value = new_value
	Tagger.settings.suggestion_strength = new_value


#func _drag_ended(value_changed: bool) -> void:
	#if value_changed:
		#Tagger.settings.suggestion_strength = h_slider.value


#func _display_update(value) -> void:
	#if value != strength_value_spinbox.value:
		#strength_value_spinbox.value = value

