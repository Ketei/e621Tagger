class_name TagWizard
extends Control

signal wizard_tags_created(tags_array)

@onready var items_scroll_container: ScrollContainer = $MarginContainer/Margin
@onready var artist_line_edit: LineEdit =$MarginContainer/Margin/MarginContainer/All/BasicsHBox/ArtistHBox/ArtistLineHBox/LineEdit
@onready var known_artist_chkbtn: CheckButton =$MarginContainer/Margin/MarginContainer/All/BasicsHBox/ArtistHBox/ArtistLineHBox/KnownArtistCheckButton
@onready var work_year: SpinBox =$MarginContainer/Margin/MarginContainer/All/BasicsHBox/DateHBox/SpinBox

@onready var char_amount: SpinBox =$MarginContainer/Margin/MarginContainer/All/CharacterHBox/HBoxContainer/CharacterCountHBox/SpinBox
@onready var focus_amount: SpinBox =$MarginContainer/Margin/MarginContainer/All/CharacterHBox/HBoxContainer/CharacterFocusHBox/FocusSpinBox

@onready var male_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/MaleVBox/MaleCheckBox
@onready var female_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/FemaleVBox/FemaleCheckBox
@onready var ambig_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/AmbiguousVBox/AmbigCheckBox
@onready var andro_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/AndromorphVBox/AndroCheckBox
@onready var gyno_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/GynomorphVBox/GynoCheckBox
@onready var herm_check_box: CheckBox  =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/HermVBox/HermCheckBox
@onready var male_herm_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/MaleHermVBox/MaleHermCheckBox

@onready var male_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/MaleVBox/MaleFocusCheckBox
@onready var female_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/FemaleVBox/FemaleFocusCheckBox
@onready var ambig_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/AmbiguousVBox/AmbigFocusCheckBox
@onready var andro_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/AndromorphVBox/AndroFocusCheckBox
@onready var gyno_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/GynomorphVBox/GynoFocusCheckBox
@onready var herm_focus_check_box: CheckBox  =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/HermVBox/HermFocusCheckBox
@onready var male_focus_herm_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/MaleHermVBox/MaleHermFocusCheckBox

@onready var anthro_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/AnthroVBox/AnthroCheckBox
@onready var semi_anthro_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/SemiAnthroVBox/SemiAnthroCheckBox
@onready var feral_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/FeralVBox/FeralCheckBox
@onready var human_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/HumanVBox/HumanCheckBox
@onready var humanoid_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/HumanoidVBox/HumanoidCheckBox
@onready var taur_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/TaurVBox/TaurCheckBox

@onready var anthro_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/AnthroVBox/AnthroFocusCheckBox
@onready var semi_focus_anthro_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/SemiAnthroVBox/SemiAnthroFocusCheckBox
@onready var feral_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/FeralVBox/FeralFocusCheckBox
@onready var human_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/HumanVBox/HumanFocusCheckBox
@onready var humanoid_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/HumanoidVBox/HumanoidFocusCheckBox
@onready var taur_focus_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BodyTypes/BodyTypesHBox/TaurVBox/TaurFocusCheckBox

@onready var background_option_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/BgTypesHbox/BackgroundDetailsHBox/BackgroundOptionButton
@onready var background_dets_option_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/BgTypesHbox/BackgroundDetailsHBox/BGDetsOptionButton
@onready var daytime_option_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/BgTypesHbox/BackgroundDetailsHBox/DayTimeOptionButton

@onready var completion_option_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/CompletionTypes/ElementsHBox/CompletionOptionButton
@onready var color_types_option_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/CompletionTypes/ElementsHBox/ColorTypesOptionButton
@onready var is_shaded_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/CompletionTypes/ElementsHBox/IsShadedCheckBox
@onready var shaded_style_optbtn: OptionButton =$MarginContainer/Margin/MarginContainer/All/CompletionTypes/ElementsHBox/ShadingStyleOptionButton

@onready var angle_option_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/CompletionOptionButton

@onready var media_type_option_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/MediaTypeButton
@onready var defined_media_opt_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/DefinedMediaOptButton

@onready var done_button: Button = $MarginContainer/Margin/MarginContainer/All/FinishButtonsHBox/DoneWizardButton
@onready var cancel_button: Button = $MarginContainer/Margin/MarginContainer/All/FinishButtonsHBox/CancelWizardButton
@onready var interactions_box: HBoxContainer =$MarginContainer/Margin/MarginContainer/All/InteractionHBox

@onready var fur_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/FurCheckBox
@onready var scales_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/ScalesCheckBox
@onready var feathers_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/FeathersCheckBox
@onready var wool_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/WoolCheckBox
@onready var skin_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/SkinCheckBox
@onready var exo_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/ExoCheckBox

@onready var fr_by_fr_anim_chk_btn: CheckBox =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/AnimationsHBox/FrByFrAnimChkBtn
@onready var loops_chk_btn: CheckBox =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/AnimationsHBox/LoopsChkBtn
@onready var sound_chk_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/AnimationsHBox/SoundChkBox

@onready var animation_types_btn: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/Animations2HBox/AnimationTypesBTN
@onready var playtime_opt_btn: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/Animations2HBox/PlaytimeOptBtn
@onready var format_opt_btn: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/Animations2HBox/FormatOptBtn

@onready var topwear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/TopwearCheckBox
@onready var underwear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/UnderVBox/UnderwearCheckBox
@onready var visible_underwear: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/UnderVBox/VisibleUnderwear
@onready var bottomwear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/BottomwearCheckBox
@onready var leg_wear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/LegWearCheckBox
@onready var arm_wear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/ArmWearCheckBox
@onready var hand_wear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/HandWearCheckBox
@onready var foot_wear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/FootWearCheckBox
@onready var head_wear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/HeadWearCheckBox
@onready var collar_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/HBoxContainer/CollarCheckBox

@onready var is_comic: CheckButton =$MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/IsComicCheckBox
@onready var has_multiple_scenes: CheckBox =$MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/ShowsMultipleCheckBox

var background_types = ["simple background", "detailed background"]
var angle_types: Array = ["front view", "three-quarter view", "side view", "rear view", "high-angle view", "low-angle view"]
var media_types: Array = ["digital media (artwork)", "traditional media (artwork)", "photography (artwork)", "animated"]

var suggestions_types: Array = []


func _ready():
	done_button.pressed.connect(create_basic_tags)
	cancel_button.pressed.connect(cancel_button_pressed)
	items_scroll_container.set_deferred("scroll_vertical", 0)


func magic_clean() -> void:
	items_scroll_container.scroll_vertical = 0
	daytime_option_button.select(0)
	is_comic.button_pressed = false
	has_multiple_scenes.set_pressed_no_signal(false)
	artist_line_edit.clear()
	known_artist_chkbtn.button_pressed = true
	work_year.set_art_year()
	char_amount.value = 0
	male_check_box.set_pressed_no_signal(false)
	female_check_box.set_pressed_no_signal(false)
	ambig_check_box.set_pressed_no_signal(false)
	andro_check_box.set_pressed_no_signal(false)
	gyno_check_box.set_pressed_no_signal(false)
	herm_check_box.set_pressed_no_signal(false)
	male_herm_check_box.set_pressed_no_signal(false)
	
	male_focus_check_box.set_pressed_no_signal(false)
	female_focus_check_box.set_pressed_no_signal(false)
	ambig_focus_check_box.set_pressed_no_signal(false)
	andro_focus_check_box.set_pressed_no_signal(false)
	gyno_focus_check_box.set_pressed_no_signal(false)
	herm_focus_check_box.set_pressed_no_signal(false)
	male_focus_herm_check_box.set_pressed_no_signal(false)
	
	for child in interactions_box.get_children():
		child.queue_free()
	
	anthro_check_box.set_pressed_no_signal(false)
	semi_anthro_check_box.set_pressed_no_signal(false)
	feral_check_box.set_pressed_no_signal(false)
	human_check_box.set_pressed_no_signal(false)
	humanoid_check_box.set_pressed_no_signal(false)
	taur_check_box.set_pressed_no_signal(false)
	
	anthro_focus_check_box.set_pressed_no_signal(false)
	semi_focus_anthro_check_box.set_pressed_no_signal(false)
	feral_focus_check_box.set_pressed_no_signal(false)
	human_focus_check_box.set_pressed_no_signal(false)
	humanoid_focus_check_box.set_pressed_no_signal(false)
	taur_focus_check_box.set_pressed_no_signal(false)
	
	background_option_button.select(0)
	background_dets_option_button.select(0)
	completion_option_button.select(0)
	color_types_option_button.select(0)
	angle_option_button.select(0)
	media_type_option_button.select(0)
	
	fur_check_box.set_pressed_no_signal(false)
	scales_check_box.set_pressed_no_signal(false)
	feathers_check_box.set_pressed_no_signal(false)
	wool_check_box.set_pressed_no_signal(false)
	skin_check_box.set_pressed_no_signal(false)
	exo_check_box.set_pressed_no_signal(false)
	
	fr_by_fr_anim_chk_btn.set_pressed_no_signal(false)
	loops_chk_btn.set_pressed_no_signal(false)
	sound_chk_box.set_pressed_no_signal(false)
	animation_types_btn.select(0)
	playtime_opt_btn.select(0)
	format_opt_btn.select(0)
	
	topwear_checkbox.set_pressed_no_signal(false)
	underwear_checkbox.set_pressed_no_signal(false)
	visible_underwear.set_pressed_no_signal(false)
	bottomwear_checkbox.set_pressed_no_signal(false)
	leg_wear_checkbox.set_pressed_no_signal(false)
	arm_wear_checkbox.set_pressed_no_signal(false)
	hand_wear_checkbox.set_pressed_no_signal(false)
	foot_wear_checkbox.set_pressed_no_signal(false)
	head_wear_checkbox.set_pressed_no_signal(false)
	collar_checkbox.set_pressed_no_signal(false)
	
	is_shaded_checkbox.button_pressed = false
	
	media_type_option_button.selected = 0


func create_basic_tags() -> void:
	var return_array: Array = []
	
	if known_artist_chkbtn.button_pressed:
		if not artist_line_edit.text.strip_edges().is_empty():
			return_array.append(artist_line_edit.text.to_lower())
	else:
		return_array.append("unknown artist")
	
	return_array.append(str(work_year.value))
	
	if char_amount.value == 0:
		return_array.append("zero pictured")
	elif  char_amount.value == 1:
		return_array.append("solo")
	elif char_amount.value == 2:
		return_array.append("duo")
	elif char_amount.value == 3:
		return_array.append("trio")
		return_array.append("group")
	elif 3 < char_amount.value:
		return_array.append("group")
	
	if char_amount.value != focus_amount.value and focus_amount.value != 0:
		if focus_amount.value == 1:
			return_array.append("solo focus")
		elif focus_amount.value == 2:
			return_array.append("duo focus")
		elif focus_amount.value == 3:
			return_array.append("trio focus")
	
	if male_check_box.button_pressed:
		return_array.append("male")
	if female_check_box.button_pressed:
		return_array.append("female")
	if ambig_check_box.button_pressed:
		return_array.append("ambiguous gender")
	if andro_check_box.button_pressed:
		return_array.append("andromorph")
		return_array.append("intersex")
	if gyno_check_box.button_pressed:
		return_array.append("gynomorph")
		return_array.append("intersex")
	if herm_check_box.button_pressed:
		return_array.append("herm")
		return_array.append("intersex")
	if male_herm_check_box.button_pressed:
		return_array.append("maleherm")
		return_array.append("intersex")
	
	if male_focus_check_box.button_pressed:
		return_array.append("male focus")
	elif female_check_box.button_pressed:
		return_array.append("female focus")
	elif ambig_focus_check_box.button_pressed:
		return_array.append("ambiguous focus")
	elif andro_focus_check_box.button_pressed:
		return_array.append("andromorph focus")
		return_array.append("intersex focus")
	elif gyno_focus_check_box.button_pressed:
		return_array.append("gynomorph focus")
		return_array.append("intersex focus")
	elif herm_focus_check_box.button_pressed:
		return_array.append("herm focus")
		return_array.append("intersex focus")
	elif male_focus_herm_check_box.button_pressed:
		return_array.append("maleherm focus")
		return_array.append("intersex focus")
		
			
	if anthro_check_box.button_pressed:
		return_array.append("anthro")
	if semi_anthro_check_box.button_pressed:
		return_array.append("semi-anthro")
	if feral_check_box.button_pressed:
		return_array.append("feral")
	if human_check_box.button_pressed:
		return_array.append("human")
	if humanoid_check_box.button_pressed:
		return_array.append("humanoid")
	if taur_check_box.button_pressed:
		return_array.append("taur")
	
	if anthro_focus_check_box.button_pressed:
		return_array.append("anthro focus")
	elif semi_focus_anthro_check_box.button_pressed:
		return_array.append("semi-anthro focus")
	elif feral_focus_check_box.button_pressed:
		return_array.append("feral focus")
	elif human_focus_check_box.button_pressed:
		return_array.append("human focus")
	elif humanoid_focus_check_box.button_pressed:
		return_array.append("humanoid focus")
	elif taur_focus_check_box.button_pressed:
		return_array.append("taur focus")
	
	for child in interactions_box.get_children():
		if not child.final_selection.is_empty():
			return_array.append(child.final_selection)
	
	return_array.append(background_types[background_option_button.selected])
	return_array.append(background_dets_option_button.get_item_text(
			background_dets_option_button.selected).to_lower())
			
	if daytime_option_button.selected != 0:
		return_array.append(daytime_option_button.get_item_text(
				daytime_option_button.selected).to_lower())
	
	if is_shaded_checkbox.button_pressed:
		return_array.append("shaded")
		if shaded_style_optbtn.selected != 0:
			return_array.append(
					shaded_style_optbtn.get_item_text(
							shaded_style_optbtn.selected).to_lower())
	
	if completion_option_button.selected == 3: # Lineless
		return_array.append("lineless")
		if color_types_option_button.selected == 1 and not is_shaded_checkbox.button_pressed:
			return_array.append("flat colors")
	
	if completion_option_button.selected == 2: # Lineart
		if color_types_option_button.selected == 1 and not is_shaded_checkbox.button_pressed:
			return_array.append("flat colors")
		elif color_types_option_button.selected == 0:
			return_array.append("lineart")
	
	if completion_option_button.selected == 1: # Sketch
		if color_types_option_button.selected == 1:
			return_array.append("colored sketch")
		else:
			return_array.append("sketch")
	
	if color_types_option_button.selected == 0: # Monochrome
		return_array.append("monochrome")
		
	
	elif color_types_option_button.selected == 2: # Colored
		if completion_option_button.selected == 1:
			return_array.append("colored sketch")
		elif completion_option_button.selected == 2 or completion_option_button.selected == 3:
			if not is_shaded_checkbox.button_pressed:
				return_array.append("flat colors")
	
	if angle_option_button.selected != 0:
		return_array.append(
			angle_types[angle_option_button.selected - 1]
		)
	
	return_array.append(media_types[media_type_option_button.selected])
	
	if media_type_option_button.selected == 3:
		if fr_by_fr_anim_chk_btn.button_pressed:
			return_array.append("frame by frame")
		if loops_chk_btn.button_pressed:
			return_array.append("loop")
		if sound_chk_box.button_pressed:
			return_array.append("sound")
		
		if animation_types_btn.selected != 0:
			return_array.append(
					animation_types_btn.get_item_text(
							animation_types_btn.selected).to_lower())
		
		return_array.append(playtime_opt_btn.get_item_text(playtime_opt_btn.selected).to_lower())
		if format_opt_btn.selected == 1:
			return_array.append("webm")
		elif format_opt_btn.selected == 2:
			return_array.append("animated png")
		
	return_array.append(defined_media_opt_button.get_item_text(defined_media_opt_button.selected).to_lower())
	
	if fur_check_box.button_pressed:
		suggestions_types.append("*color* fur")
	if scales_check_box.button_pressed:
		suggestions_types.append("*color* scales")
	if feathers_check_box.button_pressed:
		suggestions_types.append("*color* feathers")
	if wool_check_box.button_pressed:
		suggestions_types.append("*color* wool")
	if skin_check_box.button_pressed:
		suggestions_types.append("*color* skin")
	if exo_check_box.button_pressed:
		suggestions_types.append("*color* exoskeleton")
	
	if 0 < char_amount.value:
		for cloth_tag in calculate_clothing_level():
			return_array.append(cloth_tag)
	
	if is_comic.button_pressed:
		return_array.append("comic")
	if has_multiple_scenes.button_pressed:
		return_array.append("multiple scenes")
	
	wizard_tags_created.emit(return_array)


func calculate_clothing_level() -> Array:
	var clothing_score: int = 0
	var clothing_array: Array = []
	
	if topwear_checkbox.button_pressed:
		clothing_score += 10
		clothing_array.append("topwear")
	
	if bottomwear_checkbox.button_pressed:
		clothing_score += 10
		clothing_array.append("bottomwear")
	
	if underwear_checkbox.button_pressed:
		clothing_score += 10
		if visible_underwear.button_pressed or clothing_score == 10:
			clothing_array.append("underwear")
			suggestions_types.append("*color* underwear")
	
	if leg_wear_checkbox.button_pressed:
		clothing_score += 1
		clothing_array.append("legwear")
	if arm_wear_checkbox.button_pressed:
		clothing_score += 1
		clothing_array.append("armwear")
	if hand_wear_checkbox.button_pressed:
		clothing_score += 1
		clothing_array.append("gloves")
	if foot_wear_checkbox.button_pressed:
		clothing_score += 1
		clothing_array.append("footwear")
	if head_wear_checkbox.button_pressed:
		clothing_score += 1
		clothing_array.append("headwear")
		clothing_array.append("headgear")
	if collar_checkbox.button_pressed:
		clothing_score += 1
		clothing_array.append("collar")
		suggestions_types.append("*color* collar")
	
	if 0 < clothing_score and clothing_score < 10:
		clothing_array.append("mostly nude")
	elif 20 < clothing_score and clothing_score < 30:
		clothing_array.append("mostly clothed")
	
	if clothing_score == 0:
		clothing_array.append("nude")
	elif 0 < clothing_score and clothing_score < 30:
		clothing_array.append("partially clothed")
	elif 30 <= clothing_score:
		clothing_array.append("fully clothed")
	
	if bottomwear_checkbox.button_pressed\
	and not underwear_checkbox.button_pressed\
	and not topwear_checkbox.button_pressed:
		clothing_array.append("topless")
		clothing_array.append("no underwear")

	
	if not topwear_checkbox.button_pressed\
	and underwear_checkbox.button_pressed\
	and bottomwear_checkbox.button_pressed:
		clothing_array.append("topless")
	
	if topwear_checkbox.button_pressed\
	and not underwear_checkbox.button_pressed\
	and not bottomwear_checkbox.button_pressed:
		clothing_array.append("bottomless")
	
	if not underwear_checkbox.button_pressed\
	and topwear_checkbox.button_pressed\
	and bottomwear_checkbox.button_pressed:
		clothing_array.append("no underwear")
	
	if not bottomwear_checkbox.button_pressed\
	and underwear_checkbox.button_pressed\
	and topwear_checkbox.button_pressed:
		clothing_array.append("pantsless")
	
	if underwear_checkbox.button_pressed and clothing_score == 10:
		clothing_array.append("underwear_only")
		clothing_array.append("clothed")
	elif clothing_score == 1 and collar_checkbox.button_pressed:
		clothing_array.append("collar only")
		clothing_array.append("nude")
		if clothing_array.has("mostly nude"):
			clothing_array.erase("mostly nude")
	elif foot_wear_checkbox.button_pressed and clothing_score == 1:
		clothing_array.append("footwear only")
	elif hand_wear_checkbox.button_pressed and clothing_score == 1:
		clothing_array.append("handwear only")
	elif head_wear_checkbox.button_pressed and clothing_score == 1:
		clothing_array.append("headwear only")

	return clothing_array


func cancel_button_pressed() -> void:
	wizard_tags_created.emit([])
