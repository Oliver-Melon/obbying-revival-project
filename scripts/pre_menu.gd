extends Node2D

func _ready() -> void:
	if !GameManager.data: await GameManager.DataLoaded
	if RenderingServer.get_current_rendering_driver_name() != GameManager.data.rendering:
		OS.set_restart_on_exit(true,["--rendering-driver", GameManager.data.rendering])
		get_tree().quit()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
