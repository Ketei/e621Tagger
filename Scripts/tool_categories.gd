extends MarginContainer

var cat_item_preload = preload("res://Scenes/category_item.tscn")

var loaded_category: String = ""
var loaded_subcat: String = ""
var loaded_title: String = ""

@onready var category_items = $AllElements/Categories/ScrollContainer/CategoryItems
@onready var sub_category_items = $AllElements/SubCategories/ScrollContainer/SubCategoryItems
@onready var title_items = $AllElements/Titles/ScrollContainer/TitleItems
@onready var promt_includer = $AllElements/PromtIncluder

@onready var add_cat_line_edit: LineEdit = $AllElements/Categories/AddCat/AddCatLineEdit
@onready var add_cat_button: Button = $AllElements/Categories/AddCat/AddCatButton

@onready var sub_cat_line_edit: LineEdit = $AllElements/SubCategories/AddSubCat/SubCatLineEdit
@onready var add_sub_cat_btn: Button = $AllElements/SubCategories/AddSubCat/AddSubCatBtn

@onready var title_line_edit: LineEdit = $AllElements/Titles/AddTitle/TitleLineEdit
@onready var add_title_cat_btn: Button = $AllElements/Titles/AddTitle/AddTitleCatBtn


func _ready():
	load_categories()
	add_cat_button.pressed.connect(create_category)
	add_sub_cat_btn.pressed.connect(create_subcategory)
	add_title_cat_btn.pressed.connect(create_title)
	Tagger.reload_prompts.connect(load_categories)


func load_categories() -> void:
	loaded_category = ""
	loaded_subcat = ""
	loaded_title = ""
	sub_cat_line_edit.editable = false
	add_sub_cat_btn.disabled = true
	title_line_edit.editable = false
	add_title_cat_btn.disabled = true
	promt_includer.disable_editing()
	promt_includer.clear_fields()
	clear_categories()
	clear_subcategories()
	clear_titles()

	for category in Tagger.prompt_resources.prompt_list.keys():
		var new_category = cat_item_preload.instantiate()
		new_category.tag_category = category
		new_category.load_subcategory.connect(load_subcategory)
		new_category.delete_category.connect(delete_category)
		category_items.add_child(new_category)


func create_category():
	var category_key: String = Utils.just_capitalize(add_cat_line_edit.text.strip_edges())
	add_cat_line_edit.clear()
	if Tagger.prompt_resources.prompt_list.has(category_key):
		return
	
	Tagger.prompt_resources.prompt_list[category_key] = {
		"image_tag": "",
		"desc": "",
		"types": {}
	}
	
	var created_category = cat_item_preload.instantiate()
	created_category.tag_category = category_key
	created_category.load_subcategory.connect(load_subcategory)
	created_category.delete_category.connect(delete_category)
	category_items.add_child(created_category)


func load_subcategory(category_key: String) -> void:
	if loaded_category == category_key:
		return
	
	loaded_category = category_key
	loaded_subcat = ""
	loaded_title = ""
	sub_cat_line_edit.editable = false
	add_sub_cat_btn.disabled = true
	title_line_edit.editable = false
	add_title_cat_btn.disabled = true
	promt_includer.disable_editing()
	promt_includer.clear_fields()
	clear_subcategories()
	clear_titles()
	for subcat in Tagger.prompt_resources.prompt_list[loaded_category]["types"].keys():
		var new_subcategory = cat_item_preload.instantiate()
		new_subcategory.tag_category = subcat
		new_subcategory.load_subcategory.connect(load_titles)
		new_subcategory.delete_category.connect(delete_subcategory)
		sub_category_items.add_child(new_subcategory)
	add_sub_cat_btn.disabled = false
	sub_cat_line_edit.editable = true


func create_subcategory() -> void:
	var subcategory_key = Utils.just_capitalize(sub_cat_line_edit.text.strip_edges())
	sub_cat_line_edit.clear()
	
	if Tagger.prompt_resources.prompt_list[loaded_category]["types"].has(subcategory_key):
		return
	
	Tagger.prompt_resources.prompt_list[loaded_category]["types"][subcategory_key] = {
		"image_tag": "",
		"desc": "",
		"types": {}
	}
	
	var created_subcategory = cat_item_preload.instantiate()
	created_subcategory.tag_category = subcategory_key
	created_subcategory.load_subcategory.connect(load_titles)
	created_subcategory.delete_category.connect(delete_subcategory)
	sub_category_items.add_child(created_subcategory)


func load_titles(subcategory_key: String) -> void:
	if loaded_subcat == subcategory_key:
		return
	loaded_subcat = subcategory_key
	loaded_title = ""
	title_line_edit.editable = false
	add_title_cat_btn.disabled = true
	promt_includer.disable_editing()
	promt_includer.clear_fields()
	clear_titles()
	for title in Tagger.prompt_resources.prompt_list[loaded_category]["types"][loaded_subcat]["types"].keys():
		var new_title = cat_item_preload.instantiate()
		new_title.tag_category = title
		new_title.load_subcategory.connect(load_to_prompt)
		new_title.delete_category.connect(delete_title)
		title_items.add_child(new_title)
	title_line_edit.editable = true
	add_title_cat_btn.disabled = false


func create_title() -> void:
	var title_key = Utils.just_capitalize(title_line_edit.text.strip_edges())
	title_line_edit.clear()
	if Tagger.prompt_resources.prompt_list[loaded_category]["types"][loaded_subcat]["types"].has(title_key):
		return
	
	Tagger.prompt_resources.prompt_list[loaded_category]["types"][loaded_subcat]["types"][title_key] = {
		"tag": "",
		"desc": ""
	}
	
	var created_title = cat_item_preload.instantiate()
	created_title.tag_category = title_key
	created_title.load_subcategory.connect(load_to_prompt)
	created_title.delete_category.connect(delete_title)
	title_items.add_child(created_title)


func load_to_prompt(title_key: String) -> void:
	if loaded_title == title_key:
		return
	loaded_title = title_key
	promt_includer.load_prompt(loaded_category, loaded_subcat, title_key)
	promt_includer.enable_editing()


func delete_category(category_key: String, caller_node: Node) -> void:
	if loaded_category == category_key:
		loaded_category = ""
		clear_subcategories()
		clear_titles()
		
		sub_cat_line_edit.editable = false
		add_sub_cat_btn.disabled = true
		
		if not loaded_subcat.is_empty():
			loaded_subcat = ""
			clear_titles()
			title_line_edit.editable = false
			add_title_cat_btn.disabled = true
			if not loaded_title.is_empty():
				loaded_title = ""
				promt_includer.disable_editing()
				promt_includer.clear_fields()
	
	caller_node.load_subcategory.disconnect(load_subcategory)
	caller_node.delete_category.disconnect(delete_category)
	caller_node.queue_free()
	Tagger.prompt_resources.prompt_list.erase(category_key)


func delete_subcategory(subcat_key: String, caller_node: Node) -> void:
	if loaded_subcat == subcat_key:
		loaded_subcat = ""
		clear_titles()
		title_line_edit.editable = false
		add_title_cat_btn.disabled = true
		if not loaded_title.is_empty():
			loaded_title = ""
			promt_includer.disable_editing()
			promt_includer.clear_fields()
	
	caller_node.load_subcategory.disconnect(load_titles)
	caller_node.delete_category.disconnect(delete_subcategory)
	Tagger.prompt_resources.prompt_list[loaded_category]["types"].erase(subcat_key)
	caller_node.queue_free()


func delete_title(title_key: String, caller_node: Node) -> void:
	if title_key == loaded_title:
		promt_includer.disable_editing()
		promt_includer.clear_fields()
		loaded_title = ""
	Tagger.prompt_resources.prompt_list[loaded_category]["types"][loaded_subcat]["types"].erase(title_key)
	caller_node.queue_free()


func clear_categories() -> void:
	for child in category_items.get_children():
		if child.load_subcategory.is_connected(load_subcategory):
			child.load_subcategory.disconnect(load_subcategory)
		if child.delete_category.is_connected(delete_category):
			child.delete_category.disconnect(delete_category)
		child.queue_free()


func clear_subcategories() -> void:
	for child in sub_category_items.get_children():
		if child.load_subcategory.is_connected(load_titles):
			child.load_subcategory.disconnect(load_titles)
		if child.delete_category.is_connected(delete_subcategory):
			child.delete_category.disconnect(delete_subcategory)
		child.queue_free()


func clear_titles() -> void:
	promt_includer.disable_editing()
	for child in title_items.get_children():
		if child.load_subcategory.is_connected(load_to_prompt):
			child.load_subcategory.disconnect(load_to_prompt)
		if child.delete_category.is_connected(delete_title):
			child.delete_category.disconnect(delete_title)
		child.queue_free()

