extends Node

@export var data:PlayerData = PlayerData.new()
signal DataLoaded

func _ready():
	if FileAccess.file_exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = PlayerData.new()
		ResourceSaver.save(data,"user://data.tres")
	DataLoaded.emit()
