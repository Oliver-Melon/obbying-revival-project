extends Node

@onready var window = get_window()
@export var data:PlayerData = PlayerData.new()
signal DataLoaded
signal CharacterAdded(Player)
@export var currentLevel:String
@export var Camera:CamStuff
@export var shiftlocked:bool = false

const TARGETRATIO = 16.0/9.0
func ensure_levels_folder(): # makes sure that levels exists lol
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("levels"):
		dir.make_dir("levels")

func _ready():
	# Window + Mouse Setup
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_window().mode = Window.MODE_WINDOWED
	ensure_levels_folder()

	# Loading playerdata
	if FileAccess.file_exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = PlayerData.new()
		ResourceSaver.save(data,"user://data.tres")
	DataLoaded.emit() # Telling game its done loading
	
	# Fps handling thing
	data.MaxFPSChanged.connect(func(new):
		Engine.max_fps = int(new)
		pass)
	Engine.max_fps = int(data.maxFPS)
	
	# Yep
	CharacterAdded.connect(func(new):
		var rand = get_tree().get_nodes_in_group("SpawnLocation").pick_random()
		new.global_position = rand.global_position + Vector3(0,1,0)
		pass)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		ResourceSaver.save(data,"user://data.tres")
		get_tree().quit()
