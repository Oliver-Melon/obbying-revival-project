extends Resource
class_name PlayerData

@export var fov:float = 70.0
@export var sensitivity:float = 1.0
@export var maxFPS:int = 120 : 
	set(new):
		ProjectSettings.set_setting("application/run/max_fps",new)
		maxFPS = new
@export var rendering:String = "opengl3"
# other types: vulkan, d3d12
