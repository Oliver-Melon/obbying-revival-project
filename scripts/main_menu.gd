extends Node2D

@onready var Main:Node2D = $Main
@onready var Settings:Node2D = $Settings
@onready var cam:Camera2D = $Camera2D
var button = preload("res://assets/prefabs/UI/LevelCard.tscn")

@onready var list = $Main/Panel/ScrollContainer/VBoxContainer

func _ready():
	var levels = load_all_levels()
	for i in levels:
		var level = load_level(i)
		var buttonthing = button.instantiate()
		buttonthing.text = level.ObbyName
		list.add_child(buttonthing)
		buttonthing.pressed.connect(func():
			GameManager.currentLevel = i
			print(GameManager.currentLevel)
			)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://custom.tscn")

func _on_settings_pressed() -> void:
	cam.global_position = Settings.global_position

func _on_return_to_main_pressed() -> void:
	cam.global_position = Main.global_position


func load_level(path):
	var file = FileAccess.open(path,FileAccess.READ)
	if file == null:
		print("failed to open file " + path)
		return
	var text = file.get_as_text()
	var json = JSON.new()
	if json.parse(text) != OK:
		print("invalid json ", path)
		return
	var data = json.data
	return data

func load_all_levels():
	var levels = []
	var dir = DirAccess.open("user://levels")
	
	if dir == null:
		print("no levels folder gng")
		return levels
	
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		if file.ends_with(".json"):
			levels.append("user://levels/" + file)
		file = dir.get_next()
	
	dir.list_dir_end()
	return levels
