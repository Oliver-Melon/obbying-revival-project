extends Node3D

@onready var part = preload("res://assets/prefabs/building/Old/Part.tscn")
@onready var player = $Player

var spawn_point: Node3D = null


func load_level(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("failed to open file:", path)
		return null

	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		print("invalid json:", path)
		return null

	return json.data



func to_vec3(d):
	if d == null:
		return Vector3.ZERO
	return Vector3(d.get("X", 0), d.get("Y", 0), d.get("Z", 0))


func to_color(d):
	if d == null:
		return Color.WHITE
	return Color(d.get("R", 1), d.get("G", 1), d.get("B", 1))


func addPart(pos, rot, size, classname):
	var newpart = part.instantiate()
	add_child(newpart)

	var mesh = newpart.get_node("MeshInstance3D")
	var coll = newpart.get_node("CollisionShape3D")

	newpart.position = pos
	newpart.rotation = rot

	if coll.shape:
		coll.shape = coll.shape.duplicate() # <--- Crucial step
		var shape = coll.shape as BoxShape3D
		if shape:
			shape.size = size


	if mesh.mesh:
		mesh.mesh = mesh.mesh.duplicate() # <--- Crucial step
		var box_mesh = mesh.mesh as BoxMesh
		if box_mesh:
			box_mesh.size = size

	if classname == "Spawn":
		print("Spawn found at:", pos)
		spawn_point = newpart

func spawn_node(node_data):
	var classname = node_data.get("ClassName", "")

	if classname == "Part":
		var p = node_data.get("Properties", {})
		addPart(
			to_vec3(p.get("Position")),
			to_vec3(p.get("Rotation")),
			to_vec3(p.get("Size")),
			"Part"
		)

	elif classname == "Spawn":
		var p = node_data.get("Properties", {})
		addPart(
			to_vec3(p.get("Position")),
			to_vec3(p.get("Rotation")),
			to_vec3(p.get("Size")),
			"Spawn"
		)

	for child in node_data.get("Children", []):
		spawn_node(child)



func loadstuff(data):
	spawn_point = null

	print("Loading level...")

	for child in data.get("Children", []):
		spawn_node(child)

	print("Level loaded. Spawn =", spawn_point)



func _ready() -> void:
	var leveldata = load_level(GameManager.currentLevel)

	if leveldata == null:
		return

	loadstuff(leveldata)


	if spawn_point != null:
		player.spawn = spawn_point
		player.reset()
	else:
		print("WARNING: NO SPAWN FOUND IN LEVEL")
