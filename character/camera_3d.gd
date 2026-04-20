extends Camera3D

@export var target: Player
@export var distance := 10.0
@export var max_distance := 20.0
@export var zoom_speed := 1
@export var smooth_speed := 10

var yaw := 0.0
var pitch := 0.0
var rotating := false
	
enum CameraMode {NORMAL, FIRSTPERSON}
@export var shiftlocked:bool = false
@export var mode: CameraMode = CameraMode.NORMAL

@onready var ray: RayCast3D = target.get_node("Focus/ray")

var target_distance := 10.0 :
	set(new):
		if new <= 0:
			mode = CameraMode.FIRSTPERSON
		target_distance = new

func _ready():
	target_distance = distance

func _input(event):
	if Input.is_action_just_pressed("shift_lock"):
		shiftlocked = !shiftlocked
	if not shiftlocked:
		rotating = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if rotating else Input.MOUSE_MODE_VISIBLE
		)
	if Input.is_action_pressed("zoom_in"):
		target_distance -= zoom_speed
	elif Input.is_action_pressed("zoom_out"):
		target_distance += zoom_speed

	target_distance = clamp(target_distance, 0, max_distance)
	mode = CameraMode.NORMAL if target_distance > 0 else CameraMode.FIRSTPERSON

	if not shiftlocked and mode == CameraMode.NORMAL:
		rotating = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if rotating else Input.MOUSE_MODE_VISIBLE
		)

		target_distance = clamp(target_distance, 0, max_distance)
	else:
		rotating = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	target.visible = mode == CameraMode.NORMAL
	target.shiftlockLogo.visible = shiftlocked
	target.follow_camera = shiftlocked or mode == CameraMode.FIRSTPERSON

	if event is InputEventMouseMotion:
		if rotating or shiftlocked:
			yaw -= event.relative.x * GameManager.data.sensitivity/200
			pitch -= event.relative.y * GameManager.data.sensitivity/200
			pitch = clamp(pitch, -1.5, 1.5)

func _process(delta):
	if target == null:
		return
	yaw += Input.get_axis("look_left","look_right")*delta
	
	var max_desired_pos = target.get_node("Focus").global_position + global_basis.z*target_distance
	
	ray.target_position = ray.to_local(max_desired_pos)
	ray.force_raycast_update()
	
	var final_distance = target_distance
	if ray.is_colliding():
		var origin = ray.global_position
		var hit = ray.get_collision_point()
		final_distance = origin.distance_to(hit)-.1
	
	distance = min(lerp(distance, target_distance, smooth_speed * delta),final_distance)
	rotation = Vector3(pitch,yaw,0)
	
	global_position = target.get_node("Focus").global_position + global_basis.z * distance
