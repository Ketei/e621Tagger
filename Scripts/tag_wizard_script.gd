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

@onready var heigth_view: OptionButton = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/HeigthView
@onready var angle_option_button: OptionButton = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/AngleViewOptionButton
@onready var rear_view_check_button: CheckButton = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/VBoxContainer/RearViewCheckButton


@onready var media_type_option_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/MediaTypeButton
@onready var defined_media_opt_button: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/DefinedMediaOptButton

@onready var done_button: Button = $MarginContainer/Margin/MarginContainer/All/FinishButtonsHBox/DoneWizardButton
@onready var cancel_button: Button = $MarginContainer/Margin/MarginContainer/All/FinishButtonsHBox/CancelWizardButton
@onready var interactions_box: HBoxContainer = $MarginContainer/Margin/MarginContainer/All/Interactions/InterScrollBox/AllInteractions

#@onready var fur_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/FurCheckBox
#@onready var scales_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/ScalesCheckBox
#@onready var feathers_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/FeathersCheckBox
#@onready var wool_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/WoolCheckBox
#@onready var skin_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/SkinCheckBox
#@onready var exo_check_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/BdPropsHbox/CheckHBox/ExoCheckBox

@onready var fr_by_fr_anim_chk_btn: CheckBox =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/AnimationsHBox/FrByFrAnimChkBtn
@onready var loops_chk_btn: CheckBox =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/AnimationsHBox/LoopsChkBtn
@onready var sound_chk_box: CheckBox =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/AnimationsHBox/SoundChkBox

@onready var animation_types_btn: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/Animations2HBox/AnimationTypesBTN
@onready var playtime_opt_btn: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/Animations2HBox/PlaytimeOptBtn
@onready var format_opt_btn: OptionButton =$MarginContainer/Margin/MarginContainer/All/MediaTypes/ElementsHBox/AnimationsVBox/Animations2HBox/FormatOptBtn

@onready var topwear_checkbox: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/TopwearCheckBox
@onready var underwear_checkbox: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/UnderVBox/UnderwearCheckBox
@onready var visible_underwear: CheckBox =$MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/UnderVBox/VisibleUnderwear
@onready var bottomwear_checkbox: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/BottomwearCheckBox
@onready var leg_wear_checkbox: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/LegWearCheckBox
@onready var arm_wear_checkbox: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/ArmWearCheckBox
@onready var hand_wear_checkbox: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/HandWearCheckBox
@onready var foot_wear_checkbox: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/FootWearCheckBox
@onready var head_wear_checkbox: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/HeadWearCheckBox
@onready var collar_checkbox: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/CollarCheckBox
@onready var eyewear_check_box: CheckBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/ScrollContainer/HBoxContainer/EyewearCheckBox

@onready var is_comic: CheckButton = $MarginContainer/Margin/MarginContainer/All/Comics/Elements/IsComicCheckBox
@onready var has_multiple_scenes: CheckBox = $MarginContainer/Margin/MarginContainer/All/Comics/Elements/ScenesImages/ShowsMultipleCheckBox
@onready var has_multiple_images: CheckBox = $MarginContainer/Margin/MarginContainer/All/Comics/Elements/ScenesImages/MultipleImages

@onready var perspect_elements: HBoxContainer = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox
@onready var smart_checkboxes: HBoxContainer = $MarginContainer/Margin/MarginContainer/All/Stance/ScrollContainer/SmartCheckboxes
@onready var suggestions_flow_container: HFlowContainer = $MarginContainer/Margin/MarginContainer/All/IncludeSuggestions/FlowContainer
@onready var magic_container_2: HBoxContainer = $MarginContainer/Margin/MarginContainer/All/BdPropsHbox/ScrollContainer/CheckHBox

@onready var dim_lights = $DimLights
@onready var what_my_gender = $WhatMyGender
@onready var guess_my_g_button: Button = $MarginContainer/Margin/MarginContainer/All/GenderHBox/HBoxContainer/GuessMyGButton

@onready var cover_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/Comics/Elements/ComicElements/Covers/CoverCheck
@onready var back_cover_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/Comics/Elements/ComicElements/Covers/BackCoverCheck
@onready var first_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/Comics/Elements/ComicElements/Pages/FirstCheck
@onready var end_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/Comics/Elements/ComicElements/Pages/EndCheck
@onready var page_num_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/Comics/Elements/ComicElements/Extras/PageNumCheck

@onready var threesome_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/InteractionAmount/Base/SinContainer/ThreesomeCheck
@onready var gangbang_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/InteractionAmount/Base/SinContainer/GangbangType/GangbangCheck
@onready var reverse_gb_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/InteractionAmount/Base/SinContainer/GangbangType/ReverseGBCheck
@onready var foursome_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/InteractionAmount/Base/SinContainer/FoursomeCheck
@onready var fivesome_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/InteractionAmount/Base/SinContainer/FivesomeCheck
@onready var orgy_check: CheckBox = $MarginContainer/Margin/MarginContainer/All/InteractionAmount/Base/SinContainer/OrgyCheck

@onready var worm_box: CheckBox = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/AbgleTyles/WormBox
@onready var low_box: CheckBox = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/AbgleTyles/LowBox
@onready var high_box: CheckBox = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/AbgleTyles/HighBox
@onready var bird_box: CheckBox = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/AbgleTyles/BirdBox
@onready var front_box: CheckBox = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/ViewTypes/FrontBox
@onready var side_box: CheckBox = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/ViewTypes/SideBox
@onready var three_fourths_box: CheckBox = $"MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/ViewTypes/34Box"
@onready var rear_box: CheckBox = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/ViewTypes/RearBox
@onready var help_angle_button: Button = $MarginContainer/Margin/MarginContainer/All/AngleTypes/ElementsHBox/MultipleAngles/HelpAngleButton
@onready var what_my_angle = $WhatMyAngle

@onready var male_lore: CheckBox = $MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/MaleVBox/MaleLore
@onready var female_lore: CheckBox = $MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/FemaleVBox/FemaleLore
@onready var andro_lore: CheckBox = $MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/AndromorphVBox/AndroLore
@onready var gyno_lore: CheckBox = $MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/GynomorphVBox/GynoLore
@onready var herm_lore: CheckBox = $MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/HermVBox/HermLore
@onready var male_herm_lore: CheckBox = $MarginContainer/Margin/MarginContainer/All/GenderHBox/VBoxContainer/HBoxContainer/MaleHermVBox/MaleHermLore

@onready var character_clothes: SpinBox = $MarginContainer/Margin/MarginContainer/All/ClothingHBox/VBoxContainer/HBoxContainer/CharacterClothes


const background_types = ["simple background", "detailed background"]
const angle_types: Array = ["front view", "three-quarter view", "side view", "rear view", "high-angle view", "low-angle view"]
const media_types: Array = ["digital media (artwork)", "traditional media (artwork)", "photography (artwork)", "animated"]

#var suggestions_types: Array = []


func _ready():
	done_button.pressed.connect(create_basic_tags)
	cancel_button.pressed.connect(cancel_button_pressed)
	items_scroll_container.set_deferred("scroll_vertical", 0)
	guess_my_g_button.pressed.connect(guess_my_gender)
	help_angle_button.pressed.connect(what_my_angle.show)


func magic_clean() -> void:
	items_scroll_container.scroll_vertical = 0
	daytime_option_button.select(0)
	is_comic.button_pressed = false
	has_multiple_scenes.set_pressed_no_signal(false)
	has_multiple_images.set_pressed_no_signal(false)
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
	media_type_option_button.select(0)
	media_type_option_button.item_selected.emit(0)
	defined_media_opt_button.select(0)

	magic_container_2.magic_cleanup()
	
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
	perspect_elements.clean_pls()
	
	is_shaded_checkbox.button_pressed = false
	
	media_type_option_button.selected = 0
	
	for child in smart_checkboxes.get_children(): # Stances
		if not child is WizzardCheckbox:
			continue
		child.reset_selections()
	
	for child in suggestions_flow_container.get_children():
		if not child is SuggetionTagCheckbox:
			continue
		child.button_pressed = false
	
	cover_check.set_pressed_no_signal(false)
	back_cover_check.set_pressed_no_signal(false)
	first_check.set_pressed_no_signal(false)
	end_check.set_pressed_no_signal(false)
	page_num_check.set_pressed_no_signal(false)
	
	threesome_check.set_pressed_no_signal(false)
	gangbang_check.set_pressed_no_signal(false)
	reverse_gb_check.set_pressed_no_signal(false)
	foursome_check.set_pressed_no_signal(false)
	fivesome_check.set_pressed_no_signal(false)
	orgy_check.set_pressed_no_signal(false)
	male_lore.set_pressed_no_signal(false)
	female_lore.set_pressed_no_signal(false)
	andro_lore.set_pressed_no_signal(false)
	gyno_lore.set_pressed_no_signal(false)
	herm_lore.set_pressed_no_signal(false)
	male_herm_lore.set_pressed_no_signal(false)
	character_clothes.clothing_opt_dict.clear()
	character_clothes.value = 0
	character_clothes.max_value = 0
	character_clothes.max_memory = 0


func create_basic_tags() -> void:
	var return_dict: Dictionary = {
		"actions_and_interactions": [],
		"artist": [],
		"body_types": [],
		"characters": [],
		"clothing": [],
		"genders": [],
		"general": [],
		"location": [],
		"meta": [],
		"poses_and_stances": [],
		"sex_and_positions": [],
		"species": [],
		"suggestions": [],
		"lore": [],
	}
	
	if known_artist_chkbtn.button_pressed:
		if not artist_line_edit.text.strip_edges().is_empty():
			return_dict["artist"].append(artist_line_edit.text.to_lower())
	else:
		return_dict["artist"].append("unknown artist")
	
	if work_year.editable:
		return_dict["meta"].append(str(work_year.value))
	
	if char_amount.value == 0:
		return_dict["general"].append("zero pictured")
	elif  char_amount.value == 1:
		return_dict["general"].append("solo")
	elif char_amount.value == 2:
		return_dict["general"].append("duo")
	elif char_amount.value == 3:
		return_dict["general"].append("trio")
		return_dict["general"].append("group")
	elif 3 < char_amount.value:
		return_dict["general"].append("group")
	
	if char_amount.value != focus_amount.value and focus_amount.value != 0:
		if focus_amount.value == 1:
			return_dict["general"].append("solo focus")
		elif focus_amount.value == 2:
			return_dict["general"].append("duo focus")
		elif focus_amount.value == 3:
			return_dict["general"].append("trio focus")
	
	if male_check_box.button_pressed:
		return_dict["genders"].append("male")
	if female_check_box.button_pressed:
		return_dict["genders"].append("female")
	if ambig_check_box.button_pressed:
		return_dict["genders"].append("ambiguous gender")
	if andro_check_box.button_pressed:
		return_dict["genders"].append("andromorph")
		return_dict["genders"].append("intersex")
	if gyno_check_box.button_pressed:
		return_dict["genders"].append("gynomorph")
		return_dict["genders"].append("intersex")
	if herm_check_box.button_pressed:
		return_dict["genders"].append("herm")
		return_dict["genders"].append("intersex")
	if male_herm_check_box.button_pressed:
		return_dict["genders"].append("maleherm")
		return_dict["genders"].append("intersex")
	
	if male_focus_check_box.button_pressed:
		return_dict["general"].append("male focus")
	elif female_check_box.button_pressed:
		return_dict["general"].append("female focus")
	elif ambig_focus_check_box.button_pressed:
		return_dict["general"].append("ambiguous focus")
	elif andro_focus_check_box.button_pressed:
		return_dict["general"].append("andromorph focus")
		return_dict["general"].append("intersex focus")
	elif gyno_focus_check_box.button_pressed:
		return_dict["general"].append("gynomorph focus")
		return_dict["general"].append("intersex focus")
	elif herm_focus_check_box.button_pressed:
		return_dict["general"].append("herm focus")
		return_dict["general"].append("intersex focus")
	elif male_focus_herm_check_box.button_pressed:
		return_dict["general"].append("maleherm focus")
		return_dict["general"].append("intersex focus")

	if anthro_check_box.button_pressed:
		return_dict["body_types"].append("anthro")
	if semi_anthro_check_box.button_pressed:
		return_dict["body_types"].append("semi-anthro")
	if feral_check_box.button_pressed:
		return_dict["body_types"].append("feral")
	if human_check_box.button_pressed:
		return_dict["body_types"].append("human")
	if humanoid_check_box.button_pressed:
		return_dict["body_types"].append("humanoid")
	if taur_check_box.button_pressed:
		return_dict["body_types"].append("taur")
	
	if anthro_focus_check_box.button_pressed:
		return_dict["general"].append("anthro focus")
	elif semi_focus_anthro_check_box.button_pressed:
		return_dict["general"].append("semi-anthro focus")
	elif feral_focus_check_box.button_pressed:
		return_dict["general"].append("feral focus")
	elif human_focus_check_box.button_pressed:
		return_dict["general"].append("human focus")
	elif humanoid_focus_check_box.button_pressed:
		return_dict["general"].append("humanoid focus")
	elif taur_focus_check_box.button_pressed:
		return_dict["general"].append("taur focus")
	
	for child in interactions_box.get_children():
		if not child.final_selection.is_empty():
			return_dict["actions_and_interactions"].append(child.final_selection)
	
	if not threesome_check.disabled and threesome_check.button_pressed:
		return_dict["sex_and_positions"].append("threesome")
	if not foursome_check.disabled and foursome_check.button_pressed:
		return_dict["sex_and_positions"].append("foursome")
	if not fivesome_check.disabled and fivesome_check.button_pressed:
		return_dict["sex_and_positions"].append("fivesome")
	
	if not gangbang_check.disabled and gangbang_check.button_pressed:
		return_dict["sex_and_positions"].append("gangbang")
	elif not reverse_gb_check.disabled and reverse_gb_check.button_pressed:
		return_dict["sex_and_positions"].append("gangbang")
		return_dict["sex_and_positions"].append("reverse gangbang")
	
	return_dict["general"].append(background_types[background_option_button.selected])
	if background_dets_option_button.selected == 0:
		if background_dets_option_button.selected != 0:
			return_dict["general"].append(background_dets_option_button.get_item_text(
					background_dets_option_button.selected).to_lower())
	else:
		return_dict["general"].append(background_dets_option_button.get_item_text(
					background_dets_option_button.selected).to_lower())
			
	if daytime_option_button.selected != 0:
		return_dict["general"].append(daytime_option_button.get_item_text(
				daytime_option_button.selected).to_lower())
	
	if is_shaded_checkbox.button_pressed:
		return_dict["meta"].append("shaded")
		if shaded_style_optbtn.selected != 0:
			return_dict["meta"].append(
					shaded_style_optbtn.get_item_text(
							shaded_style_optbtn.selected).to_lower())
	
	if completion_option_button.selected == 3: # Lineless
		return_dict["meta"].append("lineless")
		if color_types_option_button.selected == 1 and not is_shaded_checkbox.button_pressed:
			return_dict["meta"].append("flat colors")
	
	if completion_option_button.selected == 2: # Lineart
		if color_types_option_button.selected == 1 and not is_shaded_checkbox.button_pressed:
			return_dict["meta"].append("flat colors")
		elif color_types_option_button.selected == 0:
			return_dict["meta"].append("line art")
	
	if completion_option_button.selected == 1: # Sketch
		return_dict["meta"].append("sketch")
		if color_types_option_button.selected == 1:
			return_dict["meta"].append("colored sketch")
	
	if color_types_option_button.selected == 0: # Monochrome
		return_dict["meta"].append("monochrome")
		
	elif color_types_option_button.selected == 2: # Colored
		if completion_option_button.selected == 1:
			return_dict["meta"].append("colored sketch")
		elif completion_option_button.selected == 2 or completion_option_button.selected == 3:
			if not is_shaded_checkbox.button_pressed:
				return_dict["meta"].append("flat colors")
	
	var selected_height: int = heigth_view.get_selected_id()
	if selected_height == 6:
		return_dict["general"].append("multiple angles")
		if worm_box.button_pressed:
			return_dict["general"].append("worm's-eye view")
			if not low_box.button_pressed:
				return_dict["general"].append("low-angle view")
		if low_box.button_pressed:
			return_dict["general"].append("low-angle view")
		if high_box.button_pressed:
			return_dict["general"].append("high-angle view")
		if bird_box.button_pressed:
			return_dict["general"].append("bird's-eye view")
		if front_box.button_pressed:
			return_dict["general"].append("front view")
		if side_box.button_pressed:
			return_dict["general"].append("side view")
		if three_fourths_box.button_pressed:
			return_dict["general"].append("three-quarter view")
		if rear_box.button_pressed:
			return_dict["general"].append("rear view")
	else:
		if selected_height != 5 and selected_height != 0:
			return_dict["general"].append(
				heigth_view.get_item_text(heigth_view.selected).to_lower())
			if selected_height == 4:
				return_dict["general"].append("high-angle view")
			elif selected_height == 1:
				return_dict["general"].append("low-angle view")
		
		if not selected_height == 1 and not selected_height == 4:
			if angle_option_button.get_selected_id() == 1:
				if rear_view_check_button.button_pressed:
					return_dict["general"].append("rear view")
				else:
					return_dict["general"].append("front view")
			elif angle_option_button.get_selected_id() == 2:
				if rear_view_check_button.button_pressed:
					return_dict["general"].append("rear view")
				return_dict["general"].append("three-quarter view")
			elif angle_option_button.get_selected_id() == 3:
				return_dict["general"].append("side view")
		
	return_dict["meta"].append(media_types[media_type_option_button.selected])
	
	if media_type_option_button.selected == 3:
		if fr_by_fr_anim_chk_btn.button_pressed:
			return_dict["meta"].append("frame by frame")
		if loops_chk_btn.button_pressed:
			return_dict["meta"].append("loop")
		if sound_chk_box.button_pressed:
			return_dict["meta"].append("sound")
		
		if animation_types_btn.selected != 0:
			return_dict["meta"].append(
					animation_types_btn.get_item_text(
							animation_types_btn.selected).to_lower())
		
		return_dict["meta"].append(playtime_opt_btn.get_item_text(playtime_opt_btn.selected).to_lower())
		
		if format_opt_btn.selected == 1:
			return_dict["meta"].append("webm")
		elif format_opt_btn.selected == 2:
			return_dict["meta"].append("animated png")
	if not defined_media_opt_button.get_item_text(defined_media_opt_button.selected).is_empty():
		return_dict["meta"].append(defined_media_opt_button.get_item_text(defined_media_opt_button.selected).to_lower())
	
	for child in magic_container_2.get_children(): # Body properties
		if not child is WizzardCheckbox:
			continue
		if child.button_pressed:
			return_dict["general"].append_array(Array(child.get_tags()))
			return_dict["suggestions"].append_array(Array(child.get_suggestions()))
	
	var clothing_dict: Dictionary = calculate_clothing_level()
	return_dict["general"].append_array(clothing_dict["general"])
	return_dict["clothing"].append_array(clothing_dict["clothing"])
	return_dict["suggestions"].append_array(clothing_dict["suggestions"])
	
	if is_comic.button_pressed:
		return_dict["meta"].append("comic")
		if cover_check.button_pressed:
			return_dict["meta"].append("cover page")
		elif back_cover_check.button_pressed:
			return_dict["meta"].append("back cover")
		elif first_check.button_pressed:
			return_dict["meta"].append("first page")
		elif end_check.button_pressed:
			return_dict["meta"].append("end page")
		if page_num_check.button_pressed:
			return_dict["general"].append("page number")

	if has_multiple_scenes.button_pressed:
		return_dict["meta"].append("multiple scenes")
	
	if has_multiple_images.button_pressed:
		return_dict["meta"].append("multiple images")
	
	for child in smart_checkboxes.get_children():  # Stances
		if not child is WizzardCheckbox:
			continue
		if child.button_pressed:
			return_dict["poses_and_stances"].append_array(Array(child.get_tags()))
			return_dict["suggestions"].append_array(Array(child.get_suggestions()))

	for child in suggestions_flow_container.get_children():
		if not child is SuggetionTagCheckbox:
			continue
		if child.button_pressed:
			return_dict["suggestions"].append_array(child.checkbox_tags)
	
	if male_lore.button_pressed:
		return_dict["lore"].append("male (lore)")
	if female_lore.button_pressed:
		return_dict["lore"].append("female (lore)")
	if andro_lore.button_pressed:
		return_dict["lore"].append("andromorph (lore)")
	if gyno_lore.button_pressed:
		return_dict["lore"].append("gynomorph (lore)")
	if herm_lore.button_pressed:
		return_dict["lore"].append("herm (lore)")
	if male_herm_lore.button_pressed:
		return_dict["lore"].append("maleherm (lore)")
	
	wizard_tags_created.emit(return_dict)


func calculate_clothing_level() -> Dictionary:
	var clothing_score: int = 0
	
	var clothing_dictionary: Dictionary = {
		"general": [],
		"clothing": [],
		"suggestions": []
	}
	
	var tags_added: Dictionary = {
		"topwear": false,
		"bottomwear": false,
		"underwear": false,
		"legwear": false,
		"armwear": false,
		"handwear": false,
		"footwear": false,
		"headwear": false,
		"collar": false,
		"eyewear": false,
		"mostly nude": false,
		"mostly clothed": false,
		"nude": false,
		"fully clothed": false,
		"topless": false,
		"no underwear": false,
		"bottomless": false,
		"pantsless": false,
		"collar only": false,
		"eyewear only": false,
		"footwear only": false,
		"handwear only": false,
		"headwear only": false,
		"underwear only": false,
		"topwear only": false,		
	}
	
	for entry in character_clothes.clothing_opt_dict.keys():
		clothing_score = 0
		if character_clothes.clothing_opt_dict[entry]["topwear"]:
			clothing_score += 100
			if not tags_added["topwear"]:
				clothing_dictionary["clothing"].append("topwear")
				tags_added["topwear"] = true
		
		if character_clothes.clothing_opt_dict[entry]["bottomwear"]:
			clothing_score += 100
			if not tags_added["bottomwear"]:
				clothing_dictionary["clothing"].append("bottomwear")
				tags_added["bottomwear"] = true
		
		if character_clothes.clothing_opt_dict[entry]["underwear"]:
			clothing_score += 100
			if character_clothes.clothing_opt_dict[entry]["visible_underwear"]\
					or clothing_score == 100:
				if not tags_added["underwear"]:
					clothing_dictionary["clothing"].append("underwear")
					clothing_dictionary["suggestions"].append("*color* underwear")
					tags_added.underwear = true
		
		if character_clothes.clothing_opt_dict[entry]["legwear"]:
			clothing_score += 1
			if not tags_added["legwear"]:
				clothing_dictionary["clothing"].append("legwear")
				tags_added.legwear = true
		if character_clothes.clothing_opt_dict[entry]["armwear"]:
			clothing_score += 1
			if not tags_added["armwear"]:
				clothing_dictionary["clothing"].append("armwear")
				tags_added.armwear = true
		if character_clothes.clothing_opt_dict[entry]["handwear"]:
			clothing_score += 1
			if not tags_added["handwear"]:
				clothing_dictionary["clothing"].append("handwear")
				tags_added.handwear = true
		if character_clothes.clothing_opt_dict[entry]["footwear"]:
			clothing_score += 1
			if not tags_added["footwear"]:
				clothing_dictionary["clothing"].append("footwear")
				tags_added.footwear = true
		if character_clothes.clothing_opt_dict[entry]["headwear"]:
			clothing_score += 1
			if not tags_added["headwear"]:
				clothing_dictionary["clothing"].append("headwear")
				clothing_dictionary["clothing"].append("headgear")
				tags_added.headwear = true
		if character_clothes.clothing_opt_dict[entry]["collar"]: # Non-clothing
	#		clothing_score += 1
			if not tags_added["collar"]:
				clothing_dictionary["clothing"].append("collar")
				clothing_dictionary["suggestions"].append("*color* collar")
				tags_added.collar = true
		if character_clothes.clothing_opt_dict[entry]["eyewear"]: # Non-clothing
	#		clothing_score += 1
			if not tags_added["eyewear"]:
				clothing_dictionary["clothing"].append("eyewear")
				tags_added.eyewear = true

		if 0 < clothing_score and clothing_score < 100:
			if not tags_added["mostly nude"]:
				clothing_dictionary["general"].append("mostly nude")
				tags_added["mostly nude"] = true
		elif 200 < clothing_score and clothing_score < 300:
			if not tags_added["mostly clothed"]:
				clothing_dictionary["general"].append("mostly clothed")
				tags_added["mostly clothed"] = true
		
		if clothing_score == 0:
			if not tags_added["nude"]:
				clothing_dictionary["general"].append("nude")
				tags_added["nude"] = true
		elif 300 <= clothing_score:
			if not tags_added["fully clothed"]:
				clothing_dictionary["general"].append("fully clothed")
				tags_added["fully clothed"] = true
		
		if character_clothes.clothing_opt_dict[entry]["bottomwear"]\
		and not character_clothes.clothing_opt_dict[entry]["underwear"]\
		and not character_clothes.clothing_opt_dict[entry]["topwear"]:
			if not tags_added["topless"]:
				clothing_dictionary["general"].append("topless")
				tags_added["topless"] = true
			if not tags_added["no underwear"]:
				clothing_dictionary["general"].append("no underwear")
				tags_added["no underwear"] = true

		
		if not character_clothes.clothing_opt_dict[entry]["topwear"]\
		and character_clothes.clothing_opt_dict[entry]["underwear"]\
		and character_clothes.clothing_opt_dict[entry]["bottomwear"]:
			if not tags_added["topless"]:
				clothing_dictionary["general"].append("topless")
				tags_added["topless"] = true
		
		if character_clothes.clothing_opt_dict[entry]["topwear"]\
		and not character_clothes.clothing_opt_dict[entry]["underwear"]\
		and not character_clothes.clothing_opt_dict[entry]["bottomwear"]:
			if not tags_added["bottomless"]:
				clothing_dictionary["general"].append("bottomless")
				tags_added["bottomless"] = true
		
		if not character_clothes.clothing_opt_dict[entry]["underwear"]\
		and character_clothes.clothing_opt_dict[entry]["topwear"]\
		and character_clothes.clothing_opt_dict[entry]["bottomwear"]:
			if not tags_added["no underwear"]:
				clothing_dictionary["general"].append("no underwear")
				tags_added["no underwear"] = true
		
		if not character_clothes.clothing_opt_dict[entry]["bottomwear"]\
		and character_clothes.clothing_opt_dict[entry]["underwear"]\
		and character_clothes.clothing_opt_dict[entry]["topwear"]:
			if not tags_added["pantsless"]:
				clothing_dictionary["general"].append("pantsless")
				tags_added["pantsless"] = true
		
		if clothing_score == 0: # Only Accessories
			if collar_checkbox.button_pressed:
				if not tags_added["collar only"]:
					clothing_dictionary["general"].append("collar only")
					tags_added["collar only"] = true
			elif eyewear_check_box.button_pressed:
				if not tags_added["eyewear only"]:
					clothing_dictionary["general"].append("eyewear only")
					tags_added["eyewear only"] = true
		elif clothing_score == 1: # Only small dress
			if foot_wear_checkbox.button_pressed:
				if not tags_added["footwear only"]:
					clothing_dictionary["general"].append("footwear only")
					tags_added["footwear only"] = true
			elif hand_wear_checkbox.button_pressed:
				if not tags_added["handwear only"]:
					clothing_dictionary["general"].append("handwear only")
					tags_added["handwear only"] = true
			elif head_wear_checkbox.button_pressed:
				if not tags_added["headwear only"]:
					clothing_dictionary["general"].append("headwear only")
					tags_added["headwear only"] = true
		elif clothing_score == 100:
			if underwear_checkbox.button_pressed:
				if not tags_added["underwear only"]:
					clothing_dictionary["general"].append("underwear only")
					tags_added["underwear only"] = true
			elif topwear_checkbox.button_pressed:
				if not tags_added["topwear only"]:
					clothing_dictionary["general"].append("topwear only")
					tags_added["topwear only"] = true

	return clothing_dictionary


func cancel_button_pressed() -> void:
	wizard_tags_created.emit({})


func guess_my_gender() -> void:
	what_my_gender.clear_fields()
	dim_lights.show()
	what_my_gender.show()

