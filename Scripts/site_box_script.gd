class_name SiteBoxContainer
extends HBoxContainer

var site_name: String = ""
var site_whitespace: String = ""
var site_separator: String = ""

@onready var site_line_edit: LineEdit = $SitesHBox/SiteLineEdit
@onready var white_space_text_edit: TextEdit = $WhitespaceHBox/WhiteSpaceTextEdit
@onready var separator_text_edit: TextEdit = $SeparatorHBox/SeparatorTextEdit


func _ready():
	site_line_edit.text = site_name
	white_space_text_edit.text = site_whitespace
	separator_text_edit.text = site_separator
