extends Control

@onready var load_api = $LoadAPI
@onready var log_in_api = $LogInAPI


func _ready():
	load_api.successful_load.connect(log_in_api.clear_and_disable)
	log_in_api.successful_log_in.connect(load_api.clear_and_disable)
	
	load_api.fields_disabled.connect(log_in_api.disable_fields)
	load_api.fields_enabled.connect(log_in_api.enable_fields)
	
	log_in_api.fields_disabled.connect(load_api.disable_fields)
	log_in_api.fields_enabled.connect(load_api.enable_fields)
