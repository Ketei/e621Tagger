extends Control

@onready var load_api = $LoadAPI
@onready var log_in_api = $LogInAPI


func _ready():
	load_api.successful_load.connect(log_in_api.clear_and_disable)
	log_in_api.successful_log_in.connect(load_api.clear_and_disable)
