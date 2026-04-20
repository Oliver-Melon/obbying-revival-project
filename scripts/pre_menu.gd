extends Control

func _ready() -> void:
	$Label.text = "Loading data"
	if !GameManager.data: await GameManager.DataLoaded
	$Label.text = "Checking rendering engine"
	if RenderingServer.get_current_rendering_driver_name() != GameManager.data.rendering:
		OS.set_restart_on_exit(true,["--rendering-driver", GameManager.data.rendering])
		get_tree().quit()
	$Label.text = "Changing to main menu scene"
	get_tree().call_deferred("change_scene_to_file","res://scenes/MainMenu.tscn")
	
