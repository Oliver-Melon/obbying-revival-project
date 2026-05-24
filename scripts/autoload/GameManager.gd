extends Node

@onready var window = get_window()
@export var data:PlayerData = PlayerData.new()
signal DataLoaded
signal CharacterAdded(Player)
@export var currentLevel:String
@export var Camera:CamStuff
@export var shiftlocked:bool = false
@export var alljump:bool = false
const TARGETRATIO = 16.0/9.0
var windowedMode = Window.MODE_WINDOWED
var exclusiveFullscreenMode = Window.MODE_EXCLUSIVE_FULLSCREEN
var notificationWmCloseRequest = NOTIFICATION_WM_CLOSE_REQUEST

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F11:
			toggle_fullscreen()

func toggle_fullscreen():
	if window.mode == windowedMode:
		window.mode = exclusiveFullscreenMode
	else:
		window.mode = windowedMode

func copy_default_levels():
	var source_dir = DirAccess.open("res://mainlevels")
	if source_dir == null:
		print("Failed to open res://mainlevels")
		return

	source_dir.list_dir_begin()

	while true:
		var file_name = source_dir.get_next()

		if file_name == "":
			break

		if source_dir.current_is_dir():
			continue

		var source_path = "res://mainlevels/" + file_name
		var target_path = "user://levels/" + file_name

		if FileAccess.file_exists(target_path):
			continue

		var source_file = FileAccess.open(source_path, FileAccess.READ)
		if source_file == null:
			continue

		var data = source_file.get_buffer(source_file.get_length())

		var target_file = FileAccess.open(target_path, FileAccess.WRITE)
		if target_file == null:
			continue

		target_file.store_buffer(data)

		print("Copied level:", file_name)

	source_dir.list_dir_end()

func ensure_levels_folder():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("levels"):
		dir.make_dir("levels")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_window().mode = windowedMode
	ensure_levels_folder()
	copy_default_levels()

	if FileAccess.file_exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = PlayerData.new()
		ResourceSaver.save(data,"user://data.tres")
	DataLoaded.emit()
	
	data.MaxFPSChanged.connect(func(new):
		Engine.max_fps = int(new)
		pass)
	Engine.max_fps = int(data.maxFPS)
	
	CharacterAdded.connect(func(new):
		var rand = get_tree().get_nodes_in_group("SpawnLocation").pick_random()
		new.global_position = rand.global_position + Vector3(0,1,0)
		pass)
	
func _notification(what: int) -> void:
	if what == notificationWmCloseRequest:
		if !OS.is_restart_on_exit_set():
			data.rendering = "d312"
			ResourceSaver.save(data,"user://data.tres")
		get_tree().quit()
